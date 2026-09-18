import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/chess_rules_service.dart';
import '../../../bot_game/domain/bot_difficulty.dart';
import '../../../bot_game/domain/bot_move_calculator.dart';
import '../../../bot_game/data/isolate_bot_move_calculator.dart';
import '../../data/objective_challenge_data_source.dart';
import '../../domain/objective_challenge_level.dart';
import 'objective_challenge_game_state.dart';

final objectiveChallengeGameViewModelProvider = NotifierProvider.autoDispose
    .family<
      ObjectiveChallengeGameViewModel,
      ObjectiveChallengeGameState,
      ObjectiveChallengeLevel
    >(ObjectiveChallengeGameViewModel.new);

class ObjectiveChallengeGameViewModel
    extends Notifier<ObjectiveChallengeGameState> {
  ObjectiveChallengeGameViewModel(this.level);

  final ObjectiveChallengeLevel level;

  late ChessRulesService _rules;
  late BotMoveCalculator _botMoveCalculator;
  int _plyCount = 0;
  int _gameGeneration = 0;

  @override
  ObjectiveChallengeGameState build() {
    _gameGeneration++;
    _rules = ChessRulesService.fromFen(level.fen);
    _botMoveCalculator = ref.watch(botMoveCalculatorProvider);
    _plyCount = 0;

    return _stateFromRules(
      status: ObjectiveChallengeSessionStatus.playing,
      playerMoveCount: 0,
      earnedStars: 0,
      botThinking: false,
      lastMove: null,
      lastMateAttemptMissed: false,
      missedMateAttemptCount: 0,
      moveSoundCount: 0,
    );
  }

  void resetSession() {
    _gameGeneration++;
    _rules = ChessRulesService.fromFen(level.fen);
    _plyCount = 0;

    state = _stateFromRules(
      status: ObjectiveChallengeSessionStatus.playing,
      playerMoveCount: 0,
      earnedStars: 0,
      botThinking: false,
      lastMove: null,
      lastMateAttemptMissed: false,
      missedMateAttemptCount: state.missedMateAttemptCount,
      moveSoundCount: state.moveSoundCount,
    );
  }

  void onSquareTapped(String square) {
    if (!state.canInteract(level.playerColor)) {
      return;
    }

    final selectedSquare = state.selectedSquare;

    if (selectedSquare == square) {
      state = state.copyWith(selectedSquare: null, legalTargets: {});
      return;
    }

    if (selectedSquare != null && state.legalTargets.contains(square)) {
      moveSelectedTo(square);
      return;
    }

    final piece = _rules.pieceAt(square);
    if (piece?.color != level.playerColor ||
        !_rules.isCurrentTurnPiece(square)) {
      state = state.copyWith(selectedSquare: null, legalTargets: {});
      return;
    }

    final targets = _rules.legalTargetsFrom(square).toSet();
    state = state.copyWith(
      selectedSquare: targets.isEmpty ? null : square,
      legalTargets: targets,
    );
  }

  bool isSelectedMovePromotion(String to) {
    final selectedSquare = state.selectedSquare;
    return selectedSquare != null &&
        state.legalTargets.contains(to) &&
        _rules.isPromotionMove(from: selectedSquare, to: to);
  }

  void moveSelectedTo(String to, {ChessPieceKind? promotion}) {
    final selectedSquare = state.selectedSquare;
    if (selectedSquare == null || !state.legalTargets.contains(to)) {
      return;
    }

    _attemptPlayerMove(from: selectedSquare, to: to, promotion: promotion);
  }

  void _attemptPlayerMove({
    required String from,
    required String to,
    ChessPieceKind? promotion,
  }) {
    final moved = _rules.applyMove(
      from: from,
      to: to,
      promotion: promotionCodeFor(promotion ?? ChessPieceKind.queen),
    );

    if (!moved) {
      state = state.copyWith(selectedSquare: null, legalTargets: {});
      return;
    }

    if (level.isMateInOne) {
      _afterMateInOneAttempt(from: from, to: to);
      return;
    }

    final playerMoveCount = state.playerMoveCount + 1;
    _plyCount++;
    state = _stateFromRules(
      status: ObjectiveChallengeSessionStatus.playing,
      playerMoveCount: playerMoveCount,
      earnedStars: 0,
      botThinking: false,
      lastMove: BoardMove(from: from, to: to),
      lastMateAttemptMissed: false,
      missedMateAttemptCount: state.missedMateAttemptCount,
      moveSoundCount: state.moveSoundCount + 1,
    );

    _afterPlayerMove(playerMoveCount);
  }

  void _afterMateInOneAttempt({required String from, required String to}) {
    final playerMoveCount = state.playerMoveCount + 1;

    if (_objectiveReached()) {
      state = _stateFromRules(
        status: ObjectiveChallengeSessionStatus.completed,
        playerMoveCount: playerMoveCount,
        earnedStars: _starsFor(playerMoveCount),
        botThinking: false,
        lastMove: BoardMove(from: from, to: to),
        lastMateAttemptMissed: false,
        missedMateAttemptCount: state.missedMateAttemptCount,
        moveSoundCount: state.moveSoundCount + 1,
      );
      return;
    }

    _rules = ChessRulesService.fromFen(level.fen);
    _plyCount = 0;

    if (playerMoveCount >= level.oneStarLimit) {
      state = _stateFromRules(
        status: ObjectiveChallengeSessionStatus.failed,
        playerMoveCount: playerMoveCount,
        earnedStars: 0,
        botThinking: false,
        lastMove: null,
        lastMateAttemptMissed: false,
        missedMateAttemptCount: state.missedMateAttemptCount,
        moveSoundCount: state.moveSoundCount,
      );
      return;
    }

    state = _stateFromRules(
      status: ObjectiveChallengeSessionStatus.playing,
      playerMoveCount: playerMoveCount,
      earnedStars: 0,
      botThinking: false,
      lastMove: null,
      lastMateAttemptMissed: true,
      missedMateAttemptCount: state.missedMateAttemptCount + 1,
      moveSoundCount: state.moveSoundCount,
    );
  }

  void _afterPlayerMove(int playerMoveCount) {
    if (_objectiveReached()) {
      state = state.copyWith(
        status: ObjectiveChallengeSessionStatus.completed,
        earnedStars: _starsFor(playerMoveCount),
        selectedSquare: null,
        legalTargets: {},
        botThinking: false,
      );
      return;
    }

    if (playerMoveCount >= level.oneStarLimit ||
        _rules.inCheckmate ||
        _rules.inDraw ||
        _rules.gameOver) {
      state = state.copyWith(
        status: ObjectiveChallengeSessionStatus.failed,
        earnedStars: 0,
        selectedSquare: null,
        legalTargets: {},
        botThinking: false,
      );
      return;
    }

    if (_rules.turnColor == level.botColor) {
      unawaited(_playBotMove(_plyCount, _rules.fen, _gameGeneration));
    }
  }

  Future<void> _playBotMove(
    int expectedPly,
    String expectedFen,
    int playGeneration,
  ) async {
    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != ObjectiveChallengeSessionStatus.playing ||
        _rules.turnColor != level.botColor ||
        state.botThinking) {
      return;
    }

    state = state.copyWith(
      selectedSquare: null,
      legalTargets: {},
      botThinking: true,
    );

    await Future<void>.delayed(_botThinkingDelay);

    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != ObjectiveChallengeSessionStatus.playing ||
        expectedPly != _plyCount ||
        expectedFen != _rules.fen ||
        _rules.turnColor != level.botColor) {
      return;
    }

    final scriptedMove = level.scriptedBotMoveAt(_plyCount);
    final BoardMove? appliedMove;

    if (scriptedMove != null && _rules.isLegalUciMove(scriptedMove)) {
      appliedMove = _applyBotUciMove(scriptedMove);
    } else {
      appliedMove = await _chooseAndApplyAdvancedBotMove(
        expectedPly: expectedPly,
        expectedFen: expectedFen,
        playGeneration: playGeneration,
      );
    }

    if (!ref.mounted) {
      return;
    }

    // The user may restart or leave while the bot is being calculated. Never
    // let a stale worker result mutate the new session.
    if (playGeneration != _gameGeneration ||
        expectedPly != _plyCount ||
        expectedFen != _rules.fen ||
        state.status != ObjectiveChallengeSessionStatus.playing ||
        _rules.turnColor != level.botColor) {
      return;
    }

    if (appliedMove == null) {
      state = state.copyWith(botThinking: false);
      if (_rules.gameOver) {
        state = state.copyWith(status: ObjectiveChallengeSessionStatus.failed);
      }
      return;
    }

    _plyCount++;
    state = _stateFromRules(
      status: ObjectiveChallengeSessionStatus.playing,
      playerMoveCount: state.playerMoveCount,
      earnedStars: state.earnedStars,
      botThinking: false,
      lastMove: appliedMove,
      lastMateAttemptMissed: false,
      missedMateAttemptCount: state.missedMateAttemptCount,
      moveSoundCount: state.moveSoundCount + 1,
    );

    if (_rules.inCheckmate || _rules.inDraw || _rules.gameOver) {
      state = state.copyWith(
        status: ObjectiveChallengeSessionStatus.failed,
        earnedStars: 0,
        botThinking: false,
      );
    }
  }

  Future<BoardMove?> _chooseAndApplyAdvancedBotMove({
    required int expectedPly,
    required String expectedFen,
    required int playGeneration,
  }) async {
    ChessMove? botMove;

    try {
      botMove = await _botMoveCalculator.chooseMove(
        fen: expectedFen,
        difficulty: BotDifficulty.advanced,
      );
    } catch (_) {
      botMove = null;
    }

    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != ObjectiveChallengeSessionStatus.playing ||
        expectedPly != _plyCount ||
        expectedFen != _rules.fen ||
        _rules.turnColor != level.botColor) {
      return null;
    }

    if (botMove != null && _rules.isLegalUciMove(botMove.uci)) {
      return _applyBotUciMove(botMove.uci);
    }

    final fallbackMoves = _rules.legalMoves();
    if (fallbackMoves.isEmpty) {
      return null;
    }

    return _applyBotUciMove(fallbackMoves.first.uci);
  }

  BoardMove? _applyBotUciMove(String uciMove) {
    final parsed = UciMove.parse(uciMove);
    final moved = _rules.applyUciMove(uciMove);
    if (!moved) {
      return null;
    }

    return BoardMove(from: parsed.from, to: parsed.to);
  }

  bool _objectiveReached() {
    return switch (level.goal.type) {
      ObjectiveChallengeGoalType.checkmate =>
        _rules.inCheckmate && _winnerFromCheckmate() == level.playerColor,
      ObjectiveChallengeGoalType.materialGain =>
        materialBalance(_rules, level.playerColor) -
                level.startMaterialBalance >=
            level.goal.targetMaterialGain,
    };
  }

  ChessPieceColor? _winnerFromCheckmate() {
    if (!_rules.inCheckmate) {
      return null;
    }

    return _rules.turnColor == ChessPieceColor.white
        ? ChessPieceColor.black
        : ChessPieceColor.white;
  }

  int _starsFor(int playerMoves) {
    return level.starsFor(playerMoves);
  }

  ObjectiveChallengeGameState _stateFromRules({
    required ObjectiveChallengeSessionStatus status,
    required int playerMoveCount,
    required int earnedStars,
    required bool botThinking,
    required BoardMove? lastMove,
    required bool lastMateAttemptMissed,
    required int missedMateAttemptCount,
    required int moveSoundCount,
  }) {
    return ObjectiveChallengeGameState(
      pieces: _rules.pieces,
      turn: _rules.turnColor,
      status: status,
      inCheck: _rules.inCheck,
      selectedSquare: null,
      legalTargets: {},
      playerMoveCount: playerMoveCount,
      earnedStars: earnedStars,
      botThinking: botThinking,
      lastMove: lastMove,
      lastMateAttemptMissed: lastMateAttemptMissed,
      missedMateAttemptCount: missedMateAttemptCount,
      moveSoundCount: moveSoundCount,
    );
  }

  static const _botThinkingDelay = Duration(milliseconds: 520);
}
