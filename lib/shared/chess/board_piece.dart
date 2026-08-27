import 'chess_asset_paths.dart';

class BoardPiece {
  const BoardPiece({required this.color, required this.kind});

  final ChessPieceColor color;
  final ChessPieceKind kind;

  String get assetPath {
    return ChessAssetPaths.piece(color: color, kind: kind);
  }
}
