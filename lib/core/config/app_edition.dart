import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/monetization/purchase_controller.dart';
import 'monetization_config.dart';

enum AppEdition { free, premium }

final appEditionProvider = Provider<AppEdition>((ref) {
  final entitlement = ref.watch(purchaseControllerProvider);
  return MonetizationConfig.forcePremium || entitlement.isPremium
      ? AppEdition.premium
      : AppEdition.free;
});
