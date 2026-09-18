import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_runtime_config.dart';
import '../../shared/monetization/ads_view_model.dart';
import '../../shared/monetization/purchase_view_model.dart';
import '../../core/theme/theme_mode_view_model.dart';
import '../campaign/presentation/viewmodels/campaign_map_view_model.dart';
import '../campaign/presentation/viewmodels/campaign_progress_view_model.dart';
import '../progress/presentation/viewmodels/player_progress_view_model.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.read(themeModeViewModelProvider.future),
    ref.read(campaignProgressViewModelProvider.future),
    ref.read(playerProgressViewModelProvider.future),
    ref.read(purchaseViewModelProvider.notifier).initialize(),
  ]);
  unawaited(
    (() async {
      // Configurações remotas nunca seguram a splash. Offline, o jogo segue com
      // os padrões locais e tenta atualizar novamente na próxima abertura.
      await ref.read(appRuntimeConfigViewModelProvider.notifier).initialize();
      await ref
          .read(adsViewModelProvider.notifier)
          .initialize(isPremium: ref.read(purchaseViewModelProvider).isPremium);
    })(),
  );
  await ref.read(campaignMapViewModelProvider.future);
});
