import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_runtime_config.dart';
import '../../shared/monetization/ads_controller.dart';
import '../../shared/monetization/purchase_controller.dart';
import '../../core/theme/theme_mode_notifier.dart';
import '../campaign/presentation/viewmodels/campaign_map_view_model.dart';
import '../campaign/presentation/viewmodels/campaign_progress_notifier.dart';
import '../progress/presentation/viewmodels/player_progress_controller.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.read(themeModeProvider.future),
    ref.read(campaignProgressProvider.future),
    ref.read(playerProgressControllerProvider.future),
    ref.read(purchaseControllerProvider.notifier).initialize(),
  ]);
  unawaited(
    (() async {
      // Configurações remotas nunca seguram a splash. Offline, o jogo segue com
      // os padrões locais e tenta atualizar novamente na próxima abertura.
      await ref.read(appRuntimeConfigProvider.notifier).initialize();
      await ref
          .read(adsControllerProvider.notifier)
          .initialize(
            isPremium: ref.read(purchaseControllerProvider).isPremium,
          );
    })(),
  );
  await ref.read(campaignMapViewModelProvider.future);
});
