import 'package:audioplayers/audioplayers.dart';

import 'app_feedback_tone.dart';

final Map<AppFeedbackTone, Future<AudioPlayer>> _players = {};
final Map<AppFeedbackTone, Future<void>> _playQueues = {};

Future<void> playFeedbackTone(AppFeedbackTone tone) async {
  final previous = _playQueues[tone] ?? Future<void>.value();
  final next = previous.catchError((_) {}).then((_) => _playToneNow(tone));
  _playQueues[tone] = next;

  return next;
}

Future<void> _playToneNow(AppFeedbackTone tone) async {
  try {
    final player = await (_players[tone] ??= _createPlayer(tone));

    await player.stop();
    await player.play(AssetSource(_assetFor(tone)));
  } catch (_) {
    _players.remove(tone);
    rethrow;
  }
}

Future<AudioPlayer> _createPlayer(AppFeedbackTone tone) async {
  final player = AudioPlayer();

  try {
    await player.setPlayerMode(_playerModeFor(tone));
    await player.setReleaseMode(ReleaseMode.stop);
    return player;
  } catch (_) {
    await player.dispose();
    rethrow;
  }
}

PlayerMode _playerModeFor(AppFeedbackTone tone) {
  return switch (tone) {
    AppFeedbackTone.tap || AppFeedbackTone.success => PlayerMode.mediaPlayer,
    _ => PlayerMode.lowLatency,
  };
}

String _assetFor(AppFeedbackTone tone) {
  return switch (tone) {
    AppFeedbackTone.tap => 'audio/level_click.mp3',
    AppFeedbackTone.pieceSelect => 'audio/piece_select.mp3',
    AppFeedbackTone.move => 'audio/piece_move.mp3',
    AppFeedbackTone.check => 'audio/error.mp3',
    AppFeedbackTone.success => 'audio/success.mp3',
    AppFeedbackTone.failure => 'audio/error.mp3',
  };
}
