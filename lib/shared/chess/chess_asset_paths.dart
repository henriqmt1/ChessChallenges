enum ChessPieceColor { white, black }

enum ChessPieceKind { king, queen, rook, bishop, knight, pawn }

enum ChessBoardSquareColor { light, dark }

enum ChessBoardSquareState { normal, selected, moveHint }

final class ChessAssetPaths {
  const ChessAssetPaths._();

  static const lightSquare = 'assets/chess/board/light_square.svg';
  static const darkSquare = 'assets/chess/board/dark_square.svg';
  static const lightSelectedSquare =
      'assets/chess/board/light_selected_square.svg';
  static const darkSelectedSquare =
      'assets/chess/board/dark_selected_square.svg';
  static const lightMoveHintSquare =
      'assets/chess/board/light_move_hint_square.svg';
  static const darkMoveHintSquare =
      'assets/chess/board/dark_move_hint_square.svg';

  static String piece({
    required ChessPieceColor color,
    required ChessPieceKind kind,
  }) {
    return 'assets/chess/pieces/${color.name}/${kind.name}.svg';
  }

  static String square({
    required ChessBoardSquareColor color,
    ChessBoardSquareState state = ChessBoardSquareState.normal,
  }) {
    return switch ((color, state)) {
      (ChessBoardSquareColor.light, ChessBoardSquareState.normal) =>
        lightSquare,
      (ChessBoardSquareColor.dark, ChessBoardSquareState.normal) => darkSquare,
      (ChessBoardSquareColor.light, ChessBoardSquareState.selected) =>
        lightSelectedSquare,
      (ChessBoardSquareColor.dark, ChessBoardSquareState.selected) =>
        darkSelectedSquare,
      (ChessBoardSquareColor.light, ChessBoardSquareState.moveHint) =>
        lightMoveHintSquare,
      (ChessBoardSquareColor.dark, ChessBoardSquareState.moveHint) =>
        darkMoveHintSquare,
    };
  }
}
