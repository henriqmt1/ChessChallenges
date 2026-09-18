import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_dimensions.dart';
import 'board_move.dart';
import 'board_piece.dart';
import 'chess_asset_paths.dart';

enum ChessBoardOrientation { white, black }

class ChessBoard extends StatelessWidget {
  const ChessBoard({
    super.key,
    required this.pieces,
    required this.selectedSquare,
    required this.legalTargets,
    required this.onSquareTap,
    this.orientation = ChessBoardOrientation.white,
    this.highlightedMove,
  });

  final Map<String, BoardPiece> pieces;
  final String? selectedSquare;
  final Set<String> legalTargets;
  final ValueChanged<String> onSquareTap;
  final ChessBoardOrientation orientation;
  final BoardMove? highlightedMove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.standard),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.16),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.board),
            child: Column(
              children: List.generate(8, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(8, (column) {
                      final square = _squareAt(row, column, orientation);
                      final piece = pieces[square];
                      final isLastMove =
                          highlightedMove?.squares.contains(square) ?? false;

                      return Expanded(
                        child: _BoardCell(
                          square: square,
                          row: row,
                          column: column,
                          piece: piece,
                          isSelected: selectedSquare == square,
                          isMoveHint: legalTargets.contains(square),
                          isLastMove: isLastMove,
                          onTap: () => onSquareTap(square),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  static String _squareAt(
    int row,
    int column,
    ChessBoardOrientation orientation,
  ) {
    const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    final fileIndex = orientation == ChessBoardOrientation.white
        ? column
        : 7 - column;
    final rank = orientation == ChessBoardOrientation.white ? 8 - row : row + 1;

    return '${files[fileIndex]}$rank';
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.square,
    required this.row,
    required this.column,
    required this.piece,
    required this.isSelected,
    required this.isMoveHint,
    required this.isLastMove,
    required this.onTap,
  });

  final String square;
  final int row;
  final int column;
  final BoardPiece? piece;
  final bool isSelected;
  final bool isMoveHint;
  final bool isLastMove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final squareColor = (row + column).isEven
        ? ChessBoardSquareColor.light
        : ChessBoardSquareColor.dark;
    final squareState = isSelected
        ? ChessBoardSquareState.selected
        : isMoveHint
        ? ChessBoardSquareState.moveHint
        : ChessBoardSquareState.normal;

    final l10n =
        AppLocalizations.of(context) ??
        lookupAppLocalizations(const Locale('en'));
    final currentPiece = piece;
    final description = currentPiece == null
        ? l10n.boardEmptySquare
        : '${currentPiece.color == ChessPieceColor.white ? l10n.boardWhitePieces : l10n.boardBlackPieces}, ${switch (currentPiece.kind) {
            ChessPieceKind.pawn => l10n.boardPawn,
            ChessPieceKind.king => l10n.boardKing,
            ChessPieceKind.queen => l10n.promotionQueen,
            ChessPieceKind.rook => l10n.promotionRook,
            ChessPieceKind.bishop => l10n.promotionBishop,
            ChessPieceKind.knight => l10n.promotionKnight,
          }}';
    return Semantics(
      label: '${square.toUpperCase()}, $description',
      selected: isSelected,
      button: true,
      hint: isMoveHint ? l10n.boardLegalTarget : null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('chess-square-$square'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset(
              ChessAssetPaths.square(color: squareColor, state: squareState),
              fit: BoxFit.cover,
            ),
            if (isLastMove) const _LastMoveHighlightOverlay(),
            if (piece != null)
              Padding(
                padding: const EdgeInsets.all(AppSizes.chessPiecePadding),
                child: SvgPicture.asset(piece!.assetPath, fit: BoxFit.contain),
              ),
            if (isMoveHint && piece != null) const _CaptureHintOverlay(),
            if (column == 0)
              Positioned(
                left: 5,
                top: 3,
                child: Text(square[1], style: _coordinateStyle(squareColor)),
              ),
            if (row == 7)
              Positioned(
                right: 5,
                bottom: 2,
                child: Text(
                  square[0].toUpperCase(),
                  style: _coordinateStyle(squareColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static TextStyle _coordinateStyle(ChessBoardSquareColor squareColor) {
    final isDarkSquare = squareColor == ChessBoardSquareColor.dark;

    return TextStyle(
      color: isDarkSquare
          ? AppColors.boardCoordinateDark
          : AppColors.boardCoordinateLight,
      fontSize: AppFontSizes.caption,
      fontWeight: FontWeight.w900,
      height: 1,
      shadows: [
        Shadow(
          color: isDarkSquare
              ? AppColors.blackShadow40
              : AppColors.whiteShadow40,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}

class _LastMoveHighlightOverlay extends StatelessWidget {
  const _LastMoveHighlightOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      key: const ValueKey('chess-last-move-highlight'),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.74),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureHintOverlay extends StatelessWidget {
  const _CaptureHintOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      key: const ValueKey('chess-capture-hint'),
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.fireActive, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fireActive.withValues(alpha: 0.32),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
