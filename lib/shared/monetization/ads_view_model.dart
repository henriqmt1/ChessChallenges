import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_runtime_config.dart';
import '../../core/config/monetization_config.dart';

class AdsState {
  const AdsState({
    this.isInitialized = false,
    this.canRequestAds = false,
    this.privacyOptionsRequired = false,
  });

  final bool isInitialized;
  final bool canRequestAds;
  final bool privacyOptionsRequired;

  AdsState copyWith({
    bool? isInitialized,
    bool? canRequestAds,
    bool? privacyOptionsRequired,
  }) {
    return AdsState(
      isInitialized: isInitialized ?? this.isInitialized,
      canRequestAds: canRequestAds ?? this.canRequestAds,
      privacyOptionsRequired:
          privacyOptionsRequired ?? this.privacyOptionsRequired,
    );
  }
}

final adsViewModelProvider = NotifierProvider<AdsViewModel, AdsState>(
  AdsViewModel.new,
);

class AdsViewModel extends Notifier<AdsState> {
  static const _completionCountKey = 'ad_new_completion_count_v1';
  static const _lastShownAtKey = 'ad_last_shown_at_v1';
  static const _shownInterstitialCountKey = 'ad_shown_count_v1';
  static const _lastPremiumOfferAtKey = 'ad_last_premium_offer_at_v1';

  InterstitialAd? _interstitial;
  bool _initializing = false;
  bool _loadingInterstitial = false;

  @override
  AdsState build() {
    ref.listen<AppRuntimeConfig>(appRuntimeConfigViewModelProvider, (_, next) {
      if (!next.adsEnabled) {
        _disposeInterstitial();
        state = state.copyWith(
          isInitialized: false,
          canRequestAds: false,
          privacyOptionsRequired: false,
        );
      }
    });
    ref.onDispose(_disposeInterstitial);
    return const AdsState();
  }

  Future<void> initialize({required bool isPremium}) async {
    if (isPremium || _initializing || state.isInitialized || !_adsEnabled) {
      return;
    }
    _initializing = true;

    try {
      final consentCompleter = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!consentCompleter.isCompleted) {
            consentCompleter.complete();
          }
        },
        (_) {
          if (!consentCompleter.isCompleted) {
            consentCompleter.complete();
          }
        },
      );
      await consentCompleter.future;

      final canRequestAds = await ConsentInformation.instance.canRequestAds();
      final privacyStatus = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      state = state.copyWith(
        canRequestAds: canRequestAds,
        privacyOptionsRequired:
            privacyStatus == PrivacyOptionsRequirementStatus.required,
      );

      if (!canRequestAds) {
        return;
      }

      await MobileAds.instance.initialize();
      state = state.copyWith(isInitialized: true);
      _loadInterstitial();
    } on Object {
      // Monetização é fail-open: sem rede/SDK, o jogo segue normalmente.
    } finally {
      _initializing = false;
    }
  }

  Future<void> showPrivacyOptions() async {
    if (!_adsEnabled) {
      return;
    }

    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      state = state.copyWith(
        privacyOptionsRequired:
            status == PrivacyOptionsRequirementStatus.required,
      );
    } on Object {
      // A ausência do formulário não pode impedir o uso do app.
    }
  }

  Future<bool> showAfterLevelIfEligible({
    required bool isNewCompletion,
    required bool isPremium,
  }) async {
    if (!isNewCompletion) {
      return false;
    }

    return _showAfterCompletionIfEligible(isPremium: isPremium);
  }

  Future<bool> showAfterLocalGameIfEligible({required bool isPremium}) {
    return _showAfterCompletionIfEligible(isPremium: isPremium);
  }

  Future<bool> showAfterBotGameIfEligible({required bool isPremium}) {
    return _showAfterCompletionIfEligible(isPremium: isPremium);
  }

  Future<bool> _showAfterCompletionIfEligible({required bool isPremium}) async {
    if (isPremium || !_adsEnabled) {
      return false;
    }

    if (!state.isInitialized) {
      unawaited(initialize(isPremium: false));
    }

    final preferences = await SharedPreferences.getInstance();
    final completionCount = (preferences.getInt(_completionCountKey) ?? 0) + 1;
    await preferences.setInt(_completionCountKey, completionCount);

    if (completionCount < MonetizationConfig.completionsPerAd ||
        completionCount % MonetizationConfig.completionsPerAd != 0) {
      return false;
    }

    final lastShownAt = preferences.getInt(_lastShownAtKey);
    final now = DateTime.now();
    if (lastShownAt != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(lastShownAt)) <
            MonetizationConfig.minimumAdInterval) {
      return false;
    }

    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    _interstitial = null;

    var didShow = false;
    final dismissed = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        didShow = true;
      },
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        if (!dismissed.isCompleted) {
          dismissed.complete(didShow);
        }
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        failedAd.dispose();
        if (!dismissed.isCompleted) {
          dismissed.complete(false);
        }
        _loadInterstitial();
      },
    );

    await preferences.setInt(_lastShownAtKey, now.millisecondsSinceEpoch);
    try {
      await ad.show();
    } on Object {
      ad.dispose();
      _loadInterstitial();
      return false;
    }
    final wasShown = await dismissed.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () => didShow,
    );
    if (wasShown) {
      await preferences.setInt(
        _shownInterstitialCountKey,
        (preferences.getInt(_shownInterstitialCountKey) ?? 0) + 1,
      );
    }
    return wasShown;
  }

  Future<bool> shouldShowPremiumOfferAfterAd({required bool isPremium}) async {
    if (isPremium || !_adsEnabled) {
      return false;
    }

    final preferences = await SharedPreferences.getInstance();
    final shownAdCount = preferences.getInt(_shownInterstitialCountKey) ?? 0;
    if (shownAdCount <= 0) {
      return false;
    }

    final isFirstOffer = preferences.getInt(_lastPremiumOfferAtKey) == null;
    final isRepeatOffer =
        shownAdCount % MonetizationConfig.premiumOfferRepeatAdInterval == 0;
    if (!isFirstOffer && !isRepeatOffer) {
      return false;
    }

    final lastOfferAt = preferences.getInt(_lastPremiumOfferAtKey);
    final now = DateTime.now();
    if (lastOfferAt != null &&
        now.difference(DateTime.fromMillisecondsSinceEpoch(lastOfferAt)) <
            MonetizationConfig.premiumOfferMinimumInterval) {
      return false;
    }

    await preferences.setInt(
      _lastPremiumOfferAtKey,
      now.millisecondsSinceEpoch,
    );
    return true;
  }

  void _loadInterstitial() {
    final adUnitId = MonetizationConfig.interstitialId;
    if (!state.isInitialized ||
        !state.canRequestAds ||
        !_adsEnabled ||
        _loadingInterstitial ||
        _interstitial != null ||
        adUnitId == null) {
      return;
    }

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) {
          _loadingInterstitial = false;
        },
      ),
    );
  }

  void _disposeInterstitial() {
    _interstitial?.dispose();
    _interstitial = null;
  }

  bool get _adsEnabled =>
      MonetizationConfig.adsEnabled &&
      ref.read(appRuntimeConfigViewModelProvider).adsEnabled;
}
