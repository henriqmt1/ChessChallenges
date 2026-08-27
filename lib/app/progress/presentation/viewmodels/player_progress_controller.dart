import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../bot_game/domain/bot_difficulty.dart';
import '../../../campaign/data/datasources/local_campaign_progress_storage.dart';
import '../../../campaign/presentation/viewmodels/campaign_progress_state.dart';
import '../../data/local_player_progress_storage.dart';
import '../../data/remote_player_progress_repository.dart';
import '../../domain/player_progress.dart';

final playerProgressControllerProvider =
    AsyncNotifierProvider<PlayerProgressController, PlayerProgress>(
      PlayerProgressController.new,
    );

class PlayerProgressController extends AsyncNotifier<PlayerProgress> {
  late LocalPlayerProgressStorage _localStorage;
  late RemotePlayerProgressRepository _remoteRepository;

  @override
  Future<PlayerProgress> build() async {
    _localStorage = ref.watch(localPlayerProgressStorageProvider);
    _remoteRepository = ref.watch(remotePlayerProgressRepositoryProvider);

    final localProgress = await _localStorage.load();
    final campaignProgress = await ref
        .read(localCampaignProgressStorageProvider)
        .load();
    final migratedProgress = localProgress.recordCampaignSnapshot(
      completedLevelIndexes: campaignProgress.completedLevelIndexes,
      currentOffensiveCount: campaignProgress.offensiveCount,
      lastActivityDate: campaignProgress.lastActivityDate,
    );

    await _localStorage.save(migratedProgress);
    unawaited(_mergeRemoteProgress(migratedProgress));

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
    final current = await _currentProgress();
    await _mergeRemoteProgress(current);
  }

  Future<PlayerProgress> _currentProgress() async {
    return switch (state) {
      AsyncData(:final value) => value,
      _ => await future,
    };
  }

  Future<void> _update(
    PlayerProgress Function(PlayerProgress current) update,
  ) async {
    final current = await _currentProgress();
    final next = update(current).normalizeForToday(DateTime.now());

    state = AsyncValue.data(next);
    await _localStorage.save(next);
    unawaited(_saveRemoteProgress(next));
  }

  Future<void> _mergeRemoteProgress(PlayerProgress localProgress) async {
    final remoteProgress = await _remoteRepository.load();
    final mergedProgress = remoteProgress == null
        ? localProgress
        : localProgress
              .mergeWith(remoteProgress)
              .normalizeForToday(DateTime.now());

    await _localStorage.save(mergedProgress);
    if (ref.mounted) {
      state = AsyncValue.data(mergedProgress);
    }

    unawaited(_saveRemoteProgress(mergedProgress));
  }

  Future<void> _saveRemoteProgress(PlayerProgress progress) async {
    final saved = await _remoteRepository.save(progress);
    if (!saved) {
      return;
    }

    final syncedProgress = progress.markSynced(DateTime.now());
    await _localStorage.save(syncedProgress);

    if (!ref.mounted) {
      return;
    }

    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current?.updatedAt == progress.updatedAt) {
      state = AsyncValue.data(syncedProgress);
    }
  }
}
