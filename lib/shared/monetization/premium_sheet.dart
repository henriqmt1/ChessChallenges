import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../feedback/app_toast.dart';
import 'ads_controller.dart';
import 'purchase_controller.dart';

enum PremiumSheetVariant { standard, afterAd }

Future<void> showPremiumSheet(
  BuildContext context, {
  PremiumSheetVariant variant = PremiumSheetVariant.standard,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (_) => _PremiumSheet(variant: variant),
  );
}

class _PremiumSheet extends ConsumerWidget {
  const _PremiumSheet({required this.variant});

  final PremiumSheetVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseControllerProvider);
    final ads = ref.watch(adsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final premium = purchase.isPremium;
    final afterAd = variant == PremiumSheetVariant.afterAd && !premium;

    ref.listen<Object?>(
      purchaseControllerProvider.select((value) => value.lastError),
      (previous, next) {
        if (next != null && next != previous && context.mounted) {
          AppToast.showError(context, context.l10n.premiumPurchaseFailed);
        }
      },
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.standard * 3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        key: const ValueKey('premium-sheet-close-button'),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.72),
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.standard * 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryGlow,
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const SizedBox.square(
                    dimension: 72,
                    child: Icon(
                      Icons.diamond_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                premium
                    ? context.l10n.premiumActiveTitle
                    : afterAd
                    ? context.l10n.premiumAfterAdTitle
                    : context.l10n.premiumSheetTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                premium
                    ? context.l10n.premiumActiveDescription
                    : afterAd
                    ? context.l10n.premiumAfterAdDescription
                    : context.l10n.premiumDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              _BenefitRow(
                icon: Icons.block_rounded,
                label: context.l10n.premiumBenefitNoAds,
              ),
              const SizedBox(height: AppSpacing.sm),
              _BenefitRow(
                icon: Icons.all_inclusive_rounded,
                label: context.l10n.premiumBenefitLifetime,
              ),
              const SizedBox(height: AppSpacing.sm),
              _BenefitRow(
                icon: Icons.emoji_events_rounded,
                label: context.l10n.premiumBenefitSameProgress,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!premium) ...[
                FilledButton.icon(
                  key: const ValueKey('buy-premium-button'),
                  onPressed: purchase.isPurchasePending
                      ? null
                      : () => _purchase(context, ref),
                  icon: purchase.isPurchasePending
                      ? const SizedBox.square(
                          dimension: AppIconSizes.small,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.diamond_rounded),
                  label: Text(_purchaseLabel(context, purchase)),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  key: const ValueKey('restore-premium-button'),
                  onPressed: purchase.isPurchasePending
                      ? null
                      : () => _restore(context, ref),
                  child: Text(context.l10n.premiumRestoreAction),
                ),
              ] else
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('PRO'),
                ),
              if (ads.privacyOptionsRequired) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  key: const ValueKey('privacy-options-button'),
                  onPressed: () {
                    ref
                        .read(adsControllerProvider.notifier)
                        .showPrivacyOptions();
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: Text(context.l10n.privacyOptionsAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _purchaseLabel(BuildContext context, PurchaseState state) {
    if (state.isPurchasePending) {
      return context.l10n.premiumPendingAction;
    }
    final price = state.product?.price;
    return price == null
        ? context.l10n.premiumPriceLoading
        : context.l10n.premiumBuyAction(price);
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(purchaseControllerProvider.notifier)
        .purchasePremium();
    if (!context.mounted) {
      return;
    }
    _showActionError(context, result);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(purchaseControllerProvider.notifier)
        .restorePurchases();
    if (!context.mounted) {
      return;
    }
    _showActionError(context, result);
  }

  void _showActionError(BuildContext context, PurchaseActionResult result) {
    final message = switch (result) {
      PurchaseActionResult.storeUnavailable =>
        context.l10n.premiumStoreUnavailable,
      PurchaseActionResult.productUnavailable =>
        context.l10n.premiumProductUnavailable,
      PurchaseActionResult.failed => context.l10n.premiumPurchaseFailed,
      PurchaseActionResult.started ||
      PurchaseActionResult.alreadyPremium => null,
    };
    if (message != null) {
      AppToast.showError(context, message);
    }
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.standard * 1.5),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 38,
                child: Icon(icon, color: AppColors.primaryDark, size: 21),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
