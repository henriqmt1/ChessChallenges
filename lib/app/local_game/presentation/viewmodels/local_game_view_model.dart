import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/chess/board_move.dart';
import '../../../../shared/chess/chess_asset_paths.dart';
import '../../../../shared/chess/chess_rules_service.dart';
import 'local_game_state.dart';

final localGameViewModelProvider =
    NotifierProvider.autoDispose<LocalGameViewModel, LocalGameState>(
      LocalGameViewModel.new,
    );

class LocalGameViewModel extends Notifier<LocalGameState> {
  late ChessRulesService _rules;
  Timer? _lastMovePreviewTimer;

  @override
  LocalGameState build() {
    _rules = ChessRulesService.standard();
    ref.onDispose(() => _lastMovePreviewTimer?.cancel());
    return _stateFromRules(
      moveCount: 0,
      boardFlipped: false,
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

    if (!_rules.isCurrentTurnPiece(square)) {
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

    _attemptMove(from: selectedSquare, to: to, promotion: promotion);
  }

  void resetGame() {
    _rules = ChessRulesService.standard();
    _lastMovePreviewTimer?.cancel();
    state = _stateFromRules(
      moveCount: 0,
      boardFlipped: state.boardFlipped,
      lastMove: null,
      showLastMove: false,
    );
  }

  void toggleBoard() {
    state = state.copyWith(boardFlipped: !state.boardFlipped);
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

  void _attemptMove({
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

    state = _stateFromRules(
      moveCount: state.moveCount + 1,
      boardFlipped: state.boardFlipped,
      lastMove: BoardMove(from: from, to: to),
      showLastMove: false,
    );
  }

  LocalGameState _stateFromRules({
    required int moveCount,
    required bool boardFlipped,
    required BoardMove? lastMove,
    required bool showLastMove,
  }) {
    return LocalGameState(
      pieces: _rules.pieces,
      turn: _rules.turnColor,
      status: _statusFromRules(),
      inCheck: _rules.inCheck,
      selectedSquare: null,
      legalTargets: {},
      moveCount: moveCount,
      boardFlipped: boardFlipped,
      lastMove: lastMove,
      showLastMove: showLastMove,
    );
  }

  LocalGameStatus _statusFromRules() {
    if (_rules.inCheckmate) {
      return LocalGameStatus.checkmate;
    }

    if (_rules.inDraw) {
      return LocalGameStatus.draw;
    }

    return LocalGameStatus.playing;
  }

  static const _lastMovePreviewDuration = Duration(milliseconds: 1500);
}
