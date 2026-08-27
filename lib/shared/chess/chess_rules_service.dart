import 'package:chess/chess.dart' as chess;

import 'board_piece.dart';
import 'chess_asset_paths.dart';

class ChessRulesService {
  ChessRulesService.standard() : _game = chess.Chess();

  ChessRulesService.fromFen(String fen) : _game = chess.Chess.fromFEN(fen);

  final chess.Chess _game;

  String get fen => _game.fen;

  ChessPieceColor get turnColor => _pieceColor(_game.turn);

  bool get inCheck => _game.in_check;

  bool get inCheckmate => _game.in_checkmate;

  bool get inDraw => _game.in_draw;

  bool get inThreefoldRepetition => _game.in_threefold_repetition;

  bool get inStalemate => _game.in_stalemate;

  bool get gameOver => _game.game_over;

  Map<String, BoardPiece> get pieces {
    final pieces = <String, BoardPiece>{};

    for (final file in files) {
      for (var rank = 1; rank <= 8; rank++) {
        final square = '$file$rank';
        final piece = _game.get(square);

        if (piece != null) {
          pieces[square] = BoardPiece(
            color: _pieceColor(piece.color),
            kind: _pieceKind(piece.type),
          );
        }
      }
    }

    return pieces;
  }

  BoardPiece? pieceAt(String square) {
    final piece = _game.get(square);

    if (piece == null) {
      return null;
    }

    return BoardPiece(
      color: _pieceColor(piece.color),
      kind: _pieceKind(piece.type),
    );
  }

  bool isCurrentTurnPiece(String square) {
    return pieceAt(square)?.color == turnColor;
  }

  List<String> legalTargetsFrom(String square) {
    final moves = _verboseMoves();

    return moves
        .where((move) => move['from'] == square)
        .map((move) => move['to'] as String)
        .toSet()
        .toList(growable: false);
  }

  bool isPromotionMove({required String from, required String to}) {
    final piece = pieceAt(from);
    if (piece?.kind != ChessPieceKind.pawn ||
        !legalTargetsFrom(from).contains(to)) {
      return false;
    }

    final promotionRank = piece!.color == ChessPieceColor.white ? '8' : '1';
    return to.endsWith(promotionRank);
  }

  List<ChessMove> legalMoves() {
    final movesByUci = <String, ChessMove>{};

    for (final rawMove in _verboseMoves()) {
      final flags = rawMove['flags'] as String? ?? '';
      final promotion = flags.contains('p') ? 'q' : null;
      final move = ChessMove(
        from: rawMove['from'] as String,
        to: rawMove['to'] as String,
        promotion: promotion,
        san: rawMove['san'] as String? ?? '',
        flags: flags,
      );

      movesByUci[move.uci] = move;
    }

    return movesByUci.values.toList(growable: false);
  }

  bool isLegalUciMove(String uciMove) {
    final parsed = UciMove.parse(uciMove);
    final candidate = chess.Chess.fromFEN(_game.fen);
    final move = <String, String>{'from': parsed.from, 'to': parsed.to};

    if (parsed.promotion != null) {
      move['promotion'] = parsed.promotion!;
    }

    return candidate.move(move);
  }

  bool applyUciMove(String uciMove) {
    final parsed = UciMove.parse(uciMove);
    final move = <String, String>{'from': parsed.from, 'to': parsed.to};

    if (parsed.promotion != null) {
      move['promotion'] = parsed.promotion!;
    }

    return _game.move(move);
  }

  bool applyMove({
    required String from,
    required String to,
    String promotion = 'q',
  }) {
    return _game.move({'from': from, 'to': to, 'promotion': promotion});
  }

  bool applyChessMove(ChessMove move) {
    return applyMove(
      from: move.from,
      to: move.to,
      promotion: move.promotion ?? 'q',
    );
  }

  bool wouldMoveCauseThreefoldRepetition(ChessMove move) {
    final moved = _game.move({
      'from': move.from,
      'to': move.to,
      'promotion': move.promotion ?? 'q',
    });

    if (!moved) {
      return false;
    }

    final causesRepetition = _game.in_threefold_repetition;
    _game.undo();
    return causesRepetition;
  }

  List<Map<String, dynamic>> _verboseMoves() {
    return _game
        .moves({'verbose': true})
        .cast<Map>()
        .map((move) => Map<String, dynamic>.from(move))
        .toList(growable: false);
  }

  static const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  static ChessPieceColor _pieceColor(chess.Color color) {
    return color == chess.Color.WHITE
        ? ChessPieceColor.white
        : ChessPieceColor.black;
  }

  static ChessPieceKind _pieceKind(chess.PieceType type) {
    return switch (type.name) {
      'k' => ChessPieceKind.king,
      'q' => ChessPieceKind.queen,
      'r' => ChessPieceKind.rook,
      'b' => ChessPieceKind.bishop,
      'n' => ChessPieceKind.knight,
      'p' => ChessPieceKind.pawn,
      _ => throw ArgumentError.value(type.name, 'type.name'),
    };
  }
}

String promotionCodeFor(ChessPieceKind kind) {
  return switch (kind) {
    ChessPieceKind.queen => 'q',
    ChessPieceKind.rook => 'r',
    ChessPieceKind.bishop => 'b',
    ChessPieceKind.knight => 'n',
    ChessPieceKind.king || ChessPieceKind.pawn => throw ArgumentError.value(
      kind,
      'kind',
      'Only queen, rook, bishop, or knight can be used for promotion.',
    ),
  };
}

class ChessMove {
  const ChessMove({
    required this.from,
    required this.to,
    this.promotion,
    this.san = '',
    this.flags = '',
  });

  final String from;
  final String to;
  final String? promotion;
  final String san;
  final String flags;

  String get uci => '$from$to${promotion ?? ''}';

  bool get isCapture => flags.contains('c') || flags.contains('e');

  bool get isPromotion => flags.contains('p');

  bool get isCastle => flags.contains('k') || flags.contains('q');

  @override
  String toString() => uci;
}

class UciMove {
  const UciMove({required this.from, required this.to, this.promotion});

  final String from;
  final String to;
  final String? promotion;

  static UciMove parse(String value) {
    if (value.length != 4 && value.length != 5) {
      throw FormatException('Invalid UCI move', value);
    }

    return UciMove(
      from: value.substring(0, 2),
      to: value.substring(2, 4),
      promotion: value.length == 5 ? value.substring(4, 5) : null,
    );
  }
}
