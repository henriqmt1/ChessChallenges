import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pawn cannot move diagonally into an empty square', () {
    final rules = ChessRulesService.standard();

    expect(rules.legalTargetsFrom('e2'), containsAll(['e3', 'e4']));
    expect(rules.legalTargetsFrom('e2'), isNot(contains('d3')));
    expect(rules.legalTargetsFrom('e2'), isNot(contains('f3')));

    expect(rules.applyMove(from: 'e2', to: 'd3'), isFalse);
    expect(rules.pieceAt('e2')?.kind, ChessPieceKind.pawn);
    expect(rules.pieceAt('d3'), isNull);
  });

  test(
    'pawn can move diagonally into an empty square only with en passant',
    () {
      final rules = ChessRulesService.standard();

      expect(rules.applyMove(from: 'e2', to: 'e4'), isTrue);
      expect(rules.applyMove(from: 'a7', to: 'a6'), isTrue);
      expect(rules.applyMove(from: 'e4', to: 'e5'), isTrue);
      expect(rules.applyMove(from: 'd7', to: 'd5'), isTrue);

      expect(rules.pieceAt('d6'), isNull);
      expect(rules.legalTargetsFrom('e5'), contains('d6'));

      expect(rules.applyMove(from: 'e5', to: 'd6'), isTrue);
      expect(rules.pieceAt('d6')?.color, ChessPieceColor.white);
      expect(rules.pieceAt('d6')?.kind, ChessPieceKind.pawn);
      expect(rules.pieceAt('d5'), isNull);
    },
  );
}
