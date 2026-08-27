import 'package:flutter/foundation.dart';

abstract final class MonetizationConfig {
  /// Atalho somente para builds internos. A versão publicada mantém `false`.
  static const forcePremium = bool.fromEnvironment(
    'FORCE_PREMIUM',
    defaultValue: false,
  );

  static const premiumProductId = String.fromEnvironment(
    'PREMIUM_PRODUCT_ID',
    defaultValue: 'chess_chalenges_pro_lifetime',
  );

  /// Mantém anúncios de teste até que os IDs de produção sejam informados.
  static const useTestAds = bool.fromEnvironment(
    'USE_TEST_ADS',
    defaultValue: true,
  );
  static const enableAds = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: kReleaseMode,
  );

  static const androidInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: '',
  );
  static const iosInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: '',
  );

  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static const completionsPerAd = 3;
  static const minimumAdInterval = Duration(seconds: 90);
  static const premiumOfferRepeatAdInterval = 3;
  static const premiumOfferMinimumInterval = Duration(hours: 12);

  static bool get supportsMobileStore =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get adsEnabled => enableAds && supportsMobileStore;

  static String? get interstitialId {
    if (!adsEnabled) {
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (useTestAds) {
        return _androidTestInterstitial;
      }
      return androidInterstitialId.isEmpty ? null : androidInterstitialId;
    }

    if (useTestAds) {
      return _iosTestInterstitial;
    }
    return iosInterstitialId.isEmpty ? null : iosInterstitialId;
  }
}
