import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/chess_rules_service.dart';
import '../../domain/bot_difficulty.dart';
import '../../domain/bot_move_calculator.dart';
import '../../data/isolate_bot_move_calculator.dart';
import 'bot_game_state.dart';

final botGameViewModelProvider =
    NotifierProvider.autoDispose<BotGameViewModel, BotGameState>(
      BotGameViewModel.new,
    );

class BotGameViewModel extends Notifier<BotGameState> {
  late ChessRulesService _rules;
  late BotMoveCalculator _botMoveCalculator;
  Timer? _lastMovePreviewTimer;
  int _gameGeneration = 0;

  @override
  BotGameState build() {
    _gameGeneration++;
    _rules = ChessRulesService.standard();
    _botMoveCalculator = ref.watch(botMoveCalculatorProvider);
    ref.onDispose(() => _lastMovePreviewTimer?.cancel());

    return _stateFromRules(
      status: BotGameStatus.choosingDifficulty,
      difficulty: null,
      moveCount: 0,
      botThinking: false,
      lastMove: null,
      showLastMove: false,
    );
  }

  void startGame(BotDifficulty difficulty) {
    _gameGeneration++;
    _rules = ChessRulesService.standard();
    state = _stateFromRules(
      status: BotGameStatus.playing,
      difficulty: difficulty,
      moveCount: 0,
      botThinking: false,
      lastMove: null,
      showLastMove: false,
    );
  }

  void resetGame() {
    final difficulty = state.difficulty;
    _gameGeneration++;
    _lastMovePreviewTimer?.cancel();
    if (difficulty == null) {
      _rules = ChessRulesService.standard();
      state = _stateFromRules(
        status: BotGameStatus.choosingDifficulty,
        difficulty: null,
        moveCount: 0,
        botThinking: false,
        lastMove: null,
        showLastMove: false,
      );
      return;
    }

    _rules = ChessRulesService.standard();
    state = _stateFromRules(
      status: BotGameStatus.playing,
      difficulty: difficulty,
      moveCount: 0,
      botThinking: false,
      lastMove: null,
      showLastMove: false,
    );
  }

  void returnToDifficultySelection() {
    _gameGeneration++;
    _lastMovePreviewTimer?.cancel();
    _rules = ChessRulesService.standard();
    state = _stateFromRules(
      status: BotGameStatus.choosingDifficulty,
      difficulty: null,
      moveCount: 0,
      botThinking: false,
      lastMove: null,
      showLastMove: false,
    );
  }

  void onSquareTapped(String square) {
    if (!state.canInteract) {
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
    if (piece?.color != ChessPieceColor.white ||
        !_rules.isCurrentTurnPiece(square)) {
      state = state.copyWith(selectedSquare: null, legalTargets: {});
      return;
    }

    final targets = _rules.legalTargetsFrom(square).toSet();
    if (targets.isEmpty) {
      state = state.copyWith(selectedSquare: null, legalTargets: {});
      return;
    }

    state = state.copyWith(selectedSquare: square, legalTargets: targets);
  }

  void showLastMovePreview() {
    if (state.lastMove == null) {
      return;
    }

    _lastMovePreviewTimer?.cancel();
    state = state.copyWith(showLastMove: true);
    _lastMovePreviewTimer = Timer(_lastMovePreviewDuration, () {
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(showLastMove: false);
    });
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

    final difficulty = state.difficulty!;
    final nextState = _stateFromRules(
      status: _statusFromRules(),
      difficulty: difficulty,
      moveCount: state.moveCount + 1,
      botThinking: false,
      lastMove: BoardMove(from: from, to: to),
      showLastMove: false,
    );
    state = nextState;

    if (nextState.status == BotGameStatus.playing &&
        nextState.turn == ChessPieceColor.black) {
      unawaited(_playBotMove(difficulty, _gameGeneration));
    }
  }

  Future<void> _playBotMove(
    BotDifficulty difficulty,
    int playGeneration,
  ) async {
    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != BotGameStatus.playing ||
        state.turn != ChessPieceColor.black) {
      return;
    }

    final fenBeforeThinking = _rules.fen;
    state = state.copyWith(
      selectedSquare: null,
      legalTargets: {},
      botThinking: true,
    );

    await Future<void>.delayed(_botThinkingDelay);

    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != BotGameStatus.playing ||
        state.difficulty != difficulty ||
        state.turn != ChessPieceColor.black ||
        _rules.fen != fenBeforeThinking) {
      return;
    }

    ChessMove? move;
    try {
      move = await _botMoveCalculator.chooseMove(
        fen: fenBeforeThinking,
        difficulty: difficulty,
      );
    } on Object {
      // A failed worker must not leave the game stuck on "thinking".
    }

    if (!ref.mounted ||
        playGeneration != _gameGeneration ||
        state.status != BotGameStatus.playing ||
        state.difficulty != difficulty ||
        state.turn != ChessPieceColor.black ||
        _rules.fen != fenBeforeThinking) {
      return;
    }

    if (move == null || !_rules.isLegalUciMove(move.uci)) {
      final fallbackMoves = _rules.legalMoves();
      move = fallbackMoves.isEmpty ? null : fallbackMoves.first;
    }

    if (move == null) {
      state = _stateFromRules(
        status: _statusFromRules(),
        difficulty: difficulty,
        moveCount: state.moveCount,
        botThinking: false,
        lastMove: state.lastMove,
        showLastMove: false,
      );
      return;
    }

    final moved = _rules.applyChessMove(move);
    state = _stateFromRules(
      status: moved ? _statusFromRules() : BotGameStatus.playing,
      difficulty: difficulty,
      moveCount: moved ? state.moveCount + 1 : state.moveCount,
      botThinking: false,
      lastMove: moved
          ? BoardMove(from: move.from, to: move.to)
          : state.lastMove,
      showLastMove: false,
    );
  }

  BotGameState _stateFromRules({
    required BotGameStatus status,
    required BotDifficulty? difficulty,
    required int moveCount,
    required bool botThinking,
    required BoardMove? lastMove,
    required bool showLastMove,
  }) {
    return BotGameState(
      pieces: _rules.pieces,
      turn: _rules.turnColor,
      status: status,
      inCheck: _rules.inCheck,
      selectedSquare: null,
      legalTargets: {},
      moveCount: moveCount,
      difficulty: difficulty,
      botThinking: botThinking,
      lastMove: lastMove,
      showLastMove: showLastMove,
    );
  }

  BotGameStatus _statusFromRules() {
    if (_rules.inCheckmate) {
      return BotGameStatus.checkmate;
    }

    if (_rules.inDraw) {
      return BotGameStatus.draw;
    }

    return BotGameStatus.playing;
  }

  static const _botThinkingDelay = Duration(milliseconds: 650);
  static const _lastMovePreviewDuration = Duration(milliseconds: 1500);
}
