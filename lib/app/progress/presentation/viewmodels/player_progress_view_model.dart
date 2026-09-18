import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/async/async_task_queue.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../bot_game/domain/bot_difficulty.dart';
import '../../../campaign/data/datasources/local_campaign_progress_storage.dart';
import '../../../campaign/presentation/viewmodels/campaign_progress_state.dart';
import '../../data/local_player_progress_storage.dart';
import '../../data/remote_player_progress_repository.dart';
import '../../domain/player_progress.dart';

final playerProgressViewModelProvider =
    AsyncNotifierProvider<PlayerProgressViewModel, PlayerProgress>(
      PlayerProgressViewModel.new,
    );

class PlayerProgressViewModel extends AsyncNotifier<PlayerProgress> {
  late LocalPlayerProgressStorage _localStorage;
  late RemotePlayerProgressRepository _remoteRepository;
  final _updateQueue = AsyncTaskQueue();
  late LatestValueQueue<PlayerProgress> _remoteSaveQueue;

  @override
  Future<PlayerProgress> build() async {
    _localStorage = ref.watch(localPlayerProgressStorageProvider);
    _remoteRepository = ref.watch(remotePlayerProgressRepositoryProvider);
    _remoteSaveQueue = LatestValueQueue(_saveRemoteProgress);

    final localProgress = await _localStorage.load();
    final campaignProgress = await ref
        .read(localCampaignProgressStorageProvider)
        .load();
    final migratedProgress = localProgress
        .recordCampaignSnapshot(
          completedLevelIndexes: campaignProgress.completedLevelIndexes,
          currentOffensiveCount: campaignProgress.offensiveCount,
          lastActivityDate: campaignProgress.lastActivityDate,
        )
        .copyWith(lastSyncedAt: null);

    await _localStorage.save(migratedProgress);
    unawaited(refreshInBackground());

    return migratedProgress;
  }

  Future<void> syncCampaignProgress(CampaignProgressState progress) async {
    await _update((current) {
      return current.recordCampaignSnapshot(
        completedLevelIndexes: progress.completedLevelIndexes,
        currentOffensiveCount: progress.offensiveCount,
        lastActivityDate: progress.lastActivityDate,
      );
    });
  }

  Future<void> recordBotGameFinished({
    required BotDifficulty difficulty,
    required ChessPieceColor? winner,
    required bool draw,
  }) async {
    await _update((current) {
      return current.recordBotGameFinished(
        difficultyKey: difficulty.name,
        playerWon: winner == ChessPieceColor.white,
        draw: draw,
      );
    });
  }

  Future<void> recordLocalGameFinished({
    required ChessPieceColor? winner,
    required bool draw,
  }) async {
    await _update((current) {
      return current.recordLocalGameFinished(
        winnerKey: winner?.name,
        draw: draw,
      );
    });
  }

  Future<void> recordObjectiveStars({
    required int level,
    required int stars,
  }) async {
    await _update((current) {
      return current.recordObjectiveStars(level: level, stars: stars);
    });
  }

  Future<void> refreshRemote() async {
    await _mergeRemoteProgress();
    await _remoteSaveQueue.idle;
    final current = await _currentProgress();
    if (current.lastSyncedAt == null) {
      throw StateError(
        'Progress is saved locally, but remote sync is pending.',
      );
    }
  }

  Future<PlayerProgress> _currentProgress() async {
    return switch (state) {
      AsyncData(:final value) => value,
      _ => await future,
    };
  }

  Future<void> _update(PlayerProgress Function(PlayerProgress current) update) {
    return _updateQueue.add<void>(() async {
      final current = await _currentProgress();
      final next = update(current).normalizeForToday(DateTime.now());

      final pending = next.copyWith(lastSyncedAt: null);
      await _localStorage.save(pending);
      if (!ref.mounted) return;
      state = AsyncValue.data(pending);
      _enqueueRemoteSave(pending);
    });
  }

  Future<void> refreshInBackground() async {
    try {
      await _mergeRemoteProgress();
    } on Object {
      // Local play remains available; explicit sync reports the failure.
    }
  }

  Future<void> _mergeRemoteProgress() async {
    final remoteProgress = await _remoteRepository.load();
    if (!ref.mounted) return;
    await _updateQueue.add<void>(() async {
      if (!ref.mounted) return;
      final current = await _currentProgress();
      final merged =
          (remoteProgress == null ? current : current.mergeWith(remoteProgress))
              .normalizeForToday(DateTime.now())
              .copyWith(lastSyncedAt: null);
      await _localStorage.save(merged);
      if (!ref.mounted) return;
      state = AsyncValue.data(merged);
      _enqueueRemoteSave(merged);
    });
  }

  void _enqueueRemoteSave(PlayerProgress progress) {
    _remoteSaveQueue.add(progress);
  }

  Future<void> _saveRemoteProgress(PlayerProgress progress) async {
    final saved = await _remoteRepository.save(progress);
    if (!saved) {
      return;
    }

    if (!ref.mounted) return;
    await _updateQueue.add<void>(() async {
      if (!ref.mounted) return;
      final current = await _currentProgress();
      // Identity checks the exact snapshot, even when timestamps coincide.
      if (!identical(current, progress)) return;
      final syncedProgress = current.markSynced(DateTime.now());
      await _localStorage.save(syncedProgress);
      if (ref.mounted) state = AsyncValue.data(syncedProgress);
    });
  }
}
