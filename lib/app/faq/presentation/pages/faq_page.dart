import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

const _faqHelpAccent = AppColors.primary;
const _faqHelpGlow = AppColors.primaryGlow;
const _faqGeneralIconAccent = Color(0xFF0EA5E9);
const _faqPurchasesIconAccent = Color(0xFFF59E0B);
const _faqAccountIconAccent = Color(0xFF22C55E);

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      _FaqSection(
        title: context.l10n.faqGeneralSection,
        iconAccentColor: _faqGeneralIconAccent,
        items: [
          _FaqItem(
            keyName: 'free-pro',
            icon: Icons.workspace_premium_rounded,
            question: context.l10n.faqFreeProQuestion,
            answer: context.l10n.faqFreeProAnswer,
          ),
          _FaqItem(
            keyName: 'internet',
            icon: Icons.wifi_rounded,
            question: context.l10n.faqInternetQuestion,
            answer: context.l10n.faqInternetAnswer,
          ),
          _FaqItem(
            keyName: 'ads',
            icon: Icons.ad_units_rounded,
            question: context.l10n.faqAdsQuestion,
            answer: context.l10n.faqAdsAnswer,
          ),
        ],
      ),
      _FaqSection(
        title: context.l10n.faqPurchasesSection,
        iconAccentColor: _faqPurchasesIconAccent,
        items: [
          _FaqItem(
            keyName: 'lifetime',
            icon: Icons.all_inclusive_rounded,
            question: context.l10n.faqLifetimeQuestion,
            answer: context.l10n.faqLifetimeAnswer,
          ),
          _FaqItem(
            keyName: 'restore',
            icon: Icons.restore_rounded,
            question: context.l10n.faqRestoreQuestion,
            answer: context.l10n.faqRestoreAnswer,
          ),
          _FaqItem(
            keyName: 'refund',
            icon: Icons.currency_exchange_rounded,
            question: context.l10n.faqRefundQuestion,
            answer: context.l10n.faqRefundAnswer,
          ),
        ],
      ),
      _FaqSection(
        title: context.l10n.faqAccountSection,
        iconAccentColor: _faqAccountIconAccent,
        items: [
          _FaqItem(
            keyName: 'account',
            icon: Icons.account_circle_rounded,
            question: context.l10n.faqAccountQuestion,
            answer: context.l10n.faqAccountAnswer,
          ),
          _FaqItem(
            keyName: 'new-device',
            icon: Icons.phonelink_rounded,
            question: context.l10n.faqNewDeviceQuestion,
            answer: context.l10n.faqNewDeviceAnswer,
          ),
          _FaqItem(
            keyName: 'cross-platform',
            icon: Icons.sync_alt_rounded,
            question: context.l10n.faqCrossPlatformQuestion,
            answer: context.l10n.faqCrossPlatformAnswer,
          ),
          _FaqItem(
            keyName: 'updates',
            icon: Icons.system_update_rounded,
            question: context.l10n.faqUpdatesQuestion,
            answer: context.l10n.faqUpdatesAnswer,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.faqPageTitle),
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.contentMaxWidth,
            ),
            child: ListView(
              key: const ValueKey('faq-list'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                const _FaqHero(),
                const SizedBox(height: AppSpacing.xl),
                for (final section in sections) ...[
                  _FaqSectionView(section: section),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _FaqFooter(message: context.l10n.faqFooterMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqHero extends StatelessWidget {
  const _FaqHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_faqHelpAccent, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppRadii.standard * 3),
        boxShadow: const [
          BoxShadow(color: _faqHelpGlow, blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.whiteOverlay15,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(
                dimension: 58,
                child: Icon(
                  Icons.question_answer_rounded,
                  color: AppColors.white,
                  size: AppIconSizes.extraLarge,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.faqHeroTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.faqPageSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primaryOnDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqSectionView extends StatelessWidget {
  const _FaqSectionView({required this.section});

  final _FaqSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs),
          child: Text(
            section.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var index = 0; index < section.items.length; index++) ...[
          _FaqTile(
            item: section.items[index],
            iconAccentColor: section.iconAccentColor,
          ),
          if (index != section.items.length - 1)
            const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item, required this.iconAccentColor});

  final _FaqItem item;
  final Color iconAccentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: AppColors.transparent),
          child: ExpansionTile(
            key: ValueKey('faq-item-${item.keyName}'),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: colorScheme.onSurfaceVariant,
            leading: DecoratedBox(
              decoration: BoxDecoration(
                color: iconAccentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(
                  item.icon,
                  color: iconAccentColor,
                  size: AppIconSizes.status,
                ),
              ),
            ),
            title: Text(
              item.question,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w800,
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.answer,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqFooter extends StatelessWidget {
  const _FaqFooter({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadii.standard * 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqSection {
  const _FaqSection({
    required this.title,
    required this.iconAccentColor,
    required this.items,
  });

  final String title;
  final Color iconAccentColor;
  final List<_FaqItem> items;
}

class _FaqItem {
  const _FaqItem({
    required this.keyName,
    required this.icon,
    required this.question,
    required this.answer,
  });

  final String keyName;
  final IconData icon;
  final String question;
  final String answer;
}
