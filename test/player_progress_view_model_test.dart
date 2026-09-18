import 'dart:async';

import 'package:chess_chalenges/app/progress/data/local_player_progress_storage.dart';
import 'package:chess_chalenges/app/progress/data/remote_player_progress_repository.dart';
import 'package:chess_chalenges/app/progress/domain/player_progress.dart';
import 'package:chess_chalenges/app/progress/presentation/viewmodels/player_progress_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'failed remote reads preserve local data and do not upload blindly',
    () async {
      final local = _MemoryStorage()
        ..value = PlayerProgress.empty()
            .recordObjectiveStars(level: 1, stars: 3)
            .markSynced(DateTime.now());
      var uploads = 0;
      final remote = _RemoteStorage()
        ..onLoad = () async {
          throw StateError('offline');
        }
        ..onSave = (_) async {
          uploads++;
          return true;
        };
      final container = ProviderContainer(
        overrides: [
          localPlayerProgressStorageProvider.overrideWithValue(local),
          remotePlayerProgressRepositoryProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);
      await container.read(playerProgressViewModelProvider.future);
      final viewModel = container.read(
        playerProgressViewModelProvider.notifier,
      );
      await viewModel.refreshInBackground();
      await expectLater(viewModel.refreshRemote(), throwsStateError);
      final progress = container
          .read(playerProgressViewModelProvider)
          .requireValue;
      expect(progress.objectiveStarsByLevel[1], 3);
      expect(progress.lastSyncedAt, isNull);
      expect(uploads, 0);
    },
  );

  test(
    'remote merge cannot overwrite a local update made during persistence',
    () async {
      final local = _MemoryStorage();
      final remote = _RemoteStorage();
      final container = ProviderContainer(
        overrides: [
          localPlayerProgressStorageProvider.overrideWithValue(local),
          remotePlayerProgressRepositoryProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);
      await container.read(playerProgressViewModelProvider.future);
      final viewModel = container.read(
        playerProgressViewModelProvider.notifier,
      );
      await viewModel.refreshRemote();

      final started = Completer<void>();
      final release = Completer<void>();
      local.beforeSave = (_) async {
        local.beforeSave = null;
        started.complete();
        await release.future;
      };
      final syncing = viewModel.refreshRemote();
      await started.future;
      final updating = viewModel.recordObjectiveStars(level: 1, stars: 3);
      release.complete();
      await updating;
      await syncing;

      expect(
        container
            .read(playerProgressViewModelProvider)
            .requireValue
            .objectiveStarsByLevel[1],
        3,
      );
      expect(local.value.objectiveStarsByLevel[1], 3);
      expect(local.maxConcurrentWrites, 1);
    },
  );

  test(
    'late upload acknowledgement does not mark a newer snapshot synced',
    () async {
      final local = _MemoryStorage();
      final remote = _RemoteStorage();
      final container = ProviderContainer(
        overrides: [
          localPlayerProgressStorageProvider.overrideWithValue(local),
          remotePlayerProgressRepositoryProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);
      await container.read(playerProgressViewModelProvider.future);
      final viewModel = container.read(
        playerProgressViewModelProvider.notifier,
      );
      await viewModel.refreshRemote();

      final uploadStarted = Completer<void>();
      final uploadFinished = Completer<bool>();
      remote.onSave = (_) {
        uploadStarted.complete();
        remote.onSave = (_) async => false;
        return uploadFinished.future;
      };
      await viewModel.recordObjectiveStars(level: 1, stars: 1);
      await uploadStarted.future;
      await viewModel.recordObjectiveStars(level: 1, stars: 3);
      uploadFinished.complete(true);
      // Explicit sync waits until queued uploads settle, and reports failure.
      await expectLater(viewModel.refreshRemote(), throwsStateError);
      final progress = container
          .read(playerProgressViewModelProvider)
          .requireValue;
      expect(progress.objectiveStarsByLevel[1], 3);
      expect(progress.lastSyncedAt, isNull);
      expect(local.value.lastSyncedAt, isNull);
    },
  );

  test(
    'offline explicit sync reports failure and preserves local play',
    () async {
      final remote = _RemoteStorage()..onSave = (_) async => false;
      final container = ProviderContainer(
        overrides: [
          remotePlayerProgressRepositoryProvider.overrideWithValue(remote),
        ],
      );
      addTearDown(container.dispose);
      await container.read(playerProgressViewModelProvider.future);
      final viewModel = container.read(
        playerProgressViewModelProvider.notifier,
      );
      await viewModel.recordObjectiveStars(level: 2, stars: 2);
      await expectLater(viewModel.refreshRemote(), throwsStateError);
      expect(
        container
            .read(playerProgressViewModelProvider)
            .requireValue
            .objectiveStarsByLevel[2],
        2,
      );
    },
  );
}

class _MemoryStorage extends LocalPlayerProgressStorage {
  PlayerProgress value = PlayerProgress.empty();
  Future<void> Function(PlayerProgress)? beforeSave;
  int concurrentWrites = 0;
  int maxConcurrentWrites = 0;

  @override
  Future<PlayerProgress> load({DateTime? now}) async => value;

  @override
  Future<void> save(PlayerProgress progress) async {
    concurrentWrites++;
    if (concurrentWrites > maxConcurrentWrites) {
      maxConcurrentWrites = concurrentWrites;
    }
    try {
      await beforeSave?.call(progress);
      value = progress;
    } finally {
      concurrentWrites--;
    }
  }
}

class _RemoteStorage extends RemotePlayerProgressRepository {
  _RemoteStorage() : super(auth: null, firestore: null);
  Future<bool> Function(PlayerProgress)? onSave;
  Future<PlayerProgress?> Function()? onLoad;

  @override
  Future<PlayerProgress?> load() async => await onLoad?.call();

  @override
  Future<bool> save(PlayerProgress progress) async =>
      await onSave?.call(progress) ?? true;
}
