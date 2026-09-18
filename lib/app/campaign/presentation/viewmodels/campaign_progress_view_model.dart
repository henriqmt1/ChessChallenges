import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../progress/presentation/viewmodels/player_progress_view_model.dart';
import '../../data/datasources/local_campaign_progress_storage.dart';
import 'campaign_progress_state.dart';

final campaignProgressViewModelProvider =
    AsyncNotifierProvider<CampaignProgressViewModel, CampaignProgressState>(
      CampaignProgressViewModel.new,
    );

class CampaignProgressViewModel extends AsyncNotifier<CampaignProgressState> {
  @override
  Future<CampaignProgressState> build() {
    return ref.watch(localCampaignProgressStorageProvider).load();
  }

  Future<void> completeLevel(int index) async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    if (current == null) {
      return;
    }

    final next = current.recordActivity(
      completedLevelIndex: index,
      now: DateTime.now(),
    );

    state = AsyncValue.data(next);
    await ref.read(localCampaignProgressStorageProvider).save(next);
    unawaited(
      ref
          .read(playerProgressViewModelProvider.notifier)
          .syncCampaignProgress(next),
    );
  }

  Future<void> recordActivity({DateTime? now}) async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    if (current == null) {
      return;
    }

    final next = current.recordDailyActivity(now: now ?? DateTime.now());

    state = AsyncValue.data(next);
    await ref.read(localCampaignProgressStorageProvider).save(next);
    unawaited(
      ref
          .read(playerProgressViewModelProvider.notifier)
          .syncCampaignProgress(next),
    );
  }

  Future<void> reset() async {
    final next = CampaignProgressState.empty();

    state = AsyncValue.data(next);
    await ref.read(localCampaignProgressStorageProvider).clear();
  }
}
