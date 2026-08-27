import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/monetization_config.dart';

enum PurchaseActionResult {
  started,
  alreadyPremium,
  storeUnavailable,
  productUnavailable,
  failed,
}

class PurchaseState {
  const PurchaseState({
    this.isPremium = false,
    this.isStoreAvailable = false,
    this.isLoadingStore = false,
    this.isPurchasePending = false,
    this.product,
    this.lastError,
  });

  final bool isPremium;
  final bool isStoreAvailable;
  final bool isLoadingStore;
  final bool isPurchasePending;
  final ProductDetails? product;
  final Object? lastError;

  PurchaseState copyWith({
    bool? isPremium,
    bool? isStoreAvailable,
    bool? isLoadingStore,
    bool? isPurchasePending,
    ProductDetails? product,
    Object? lastError,
    bool clearError = false,
  }) {
    return PurchaseState(
      isPremium: isPremium ?? this.isPremium,
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoadingStore: isLoadingStore ?? this.isLoadingStore,
      isPurchasePending: isPurchasePending ?? this.isPurchasePending,
      product: product ?? this.product,
      lastError: clearError ? null : lastError ?? this.lastError,
    );
  }
}

final purchaseControllerProvider =
    NotifierProvider<PurchaseController, PurchaseState>(PurchaseController.new);

class PurchaseController extends Notifier<PurchaseState> {
  static const _premiumPreferenceKey = 'premium_entitlement_v1';

  final InAppPurchase _store = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _initialized = false;

  @override
  PurchaseState build() {
    ref.onDispose(() => unawaited(_purchaseSubscription?.cancel()));
    return PurchaseState(isPremium: MonetizationConfig.forcePremium);
  }

  /// Carrega primeiro o direito salvo localmente e consulta a loja em segundo
  /// plano. Assim uma falha de internet nunca prende a splash nem o jogo.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final preferences = await SharedPreferences.getInstance();
    final cachedPremium = preferences.getBool(_premiumPreferenceKey) ?? false;
    state = state.copyWith(
      isPremium: MonetizationConfig.forcePremium || cachedPremium,
    );

    if (!MonetizationConfig.supportsMobileStore) {
      return;
    }

    _purchaseSubscription = _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(isPurchasePending: false, lastError: error);
      },
    );
    unawaited(_connectToStore());
  }

  Future<void> _connectToStore() async {
    state = state.copyWith(isLoadingStore: true, clearError: true);

    try {
      final available = await _store.isAvailable();
      if (!available) {
        state = state.copyWith(isStoreAvailable: false, isLoadingStore: false);
        return;
      }

      final response = await _store.queryProductDetails({
        MonetizationConfig.premiumProductId,
      });
      final product = response.productDetails.isEmpty
          ? null
          : response.productDetails.first;
      state = state.copyWith(
        isStoreAvailable: true,
        isLoadingStore: false,
        product: product,
        lastError: response.error,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isStoreAvailable: false,
        isLoadingStore: false,
        lastError: error,
      );
    }
  }

  Future<PurchaseActionResult> purchasePremium() async {
    if (state.isPremium) {
      return PurchaseActionResult.alreadyPremium;
    }
    if (!state.isStoreAvailable) {
      unawaited(_connectToStore());
      return PurchaseActionResult.storeUnavailable;
    }

    final product = state.product;
    if (product == null) {
      return PurchaseActionResult.productUnavailable;
    }

    state = state.copyWith(isPurchasePending: true, clearError: true);
    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        state = state.copyWith(isPurchasePending: false);
        return PurchaseActionResult.failed;
      }
      return PurchaseActionResult.started;
    } on Object catch (error) {
      state = state.copyWith(isPurchasePending: false, lastError: error);
      return PurchaseActionResult.failed;
    }
  }

  Future<PurchaseActionResult> restorePurchases() async {
    if (state.isPremium) {
      return PurchaseActionResult.alreadyPremium;
    }
    if (!state.isStoreAvailable) {
      unawaited(_connectToStore());
      return PurchaseActionResult.storeUnavailable;
    }

    state = state.copyWith(isPurchasePending: true, clearError: true);
    try {
      await _store.restorePurchases();
      // Compras restauradas chegam pelo purchaseStream.
      state = state.copyWith(isPurchasePending: false);
      return PurchaseActionResult.started;
    } on Object catch (error) {
      state = state.copyWith(isPurchasePending: false, lastError: error);
      return PurchaseActionResult.failed;
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != MonetizationConfig.premiumProductId) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isPurchasePending: true, clearError: true);
          continue;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Para uma proteção antifraude forte, a verificação do recibo deve
          // migrar para um backend antes de liberar funcionalidades valiosas.
          await _unlockPremium();
          if (purchase.pendingCompletePurchase) {
            await _store.completePurchase(purchase);
          }
          continue;
        case PurchaseStatus.error:
          state = state.copyWith(
            isPurchasePending: false,
            lastError: purchase.error,
          );
          continue;
        case PurchaseStatus.canceled:
          state = state.copyWith(isPurchasePending: false, clearError: true);
          continue;
      }
    }
  }

  Future<void> _unlockPremium() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_premiumPreferenceKey, true);
    state = state.copyWith(
      isPremium: true,
      isPurchasePending: false,
      clearError: true,
    );
  }
}
