import 'package:flutter/services.dart';

import 'app_feedback_tone.dart';
import 'tone_player.dart';

final class AppFeedback {
  const AppFeedback._();

  static Future<void> levelTap() async {
    await _play(
      tone: AppFeedbackTone.tap,
      haptic: HapticFeedback.selectionClick,
      systemSoundType: SystemSoundType.click,
    );
  }

  static Future<void> movePiece() async {
    await _play(
      tone: AppFeedbackTone.move,
      haptic: HapticFeedback.selectionClick,
      systemSoundType: SystemSoundType.click,
    );
  }

  static Future<void> selectPiece() async {
    await _play(
      tone: AppFeedbackTone.pieceSelect,
      haptic: HapticFeedback.selectionClick,
      systemSoundType: SystemSoundType.click,
    );
  }

  static Future<void> success() async {
    await _play(
      tone: AppFeedbackTone.success,
      haptic: HapticFeedback.mediumImpact,
      systemSoundType: SystemSoundType.click,
    );
  }

  static Future<void> check() async {
    await _play(
      tone: AppFeedbackTone.check,
      haptic: HapticFeedback.mediumImpact,
      systemSoundType: SystemSoundType.alert,
    );
  }

  static Future<void> failure() async {
    await _play(
      tone: AppFeedbackTone.failure,
      haptic: HapticFeedback.mediumImpact,
      systemSoundType: SystemSoundType.alert,
    );
  }

  static Future<void> _play({
    required AppFeedbackTone tone,
    required Future<void> Function() haptic,
    required SystemSoundType systemSoundType,
  }) async {
    try {
      await playFeedbackTone(tone);
    } catch (_) {
      try {
        await SystemSound.play(systemSoundType);
      } catch (_) {
        // Feedback must never interrupt gameplay if audio is unavailable.
      }
    }

    try {
      await haptic();
    } catch (_) {
      // Some devices and test environments do not expose haptic feedback.
    }
  }
}
