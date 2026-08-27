import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:chess_chalenges/shared/chess/chess_rules_service.dart';
import 'package:chess_chalenges/shared/chess/promotion_choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  test('detects promotion and applies the selected piece', () {
    final rules = ChessRulesService.fromFen('8/P7/8/8/8/8/8/4k2K w - - 0 1');

    expect(rules.isPromotionMove(from: 'a7', to: 'a8'), isTrue);

    final moved = rules.applyMove(
      from: 'a7',
      to: 'a8',
      promotion: promotionCodeFor(ChessPieceKind.knight),
    );

    expect(moved, isTrue);
    expect(rules.pieceAt('a8')?.kind, ChessPieceKind.knight);
    expect(rules.pieceAt('a8')?.color, ChessPieceColor.white);
  });

  testWidgets('promotion sheet lets the player choose a piece', (tester) async {
    ChessPieceKind? selected;

    await tester.pumpWidget(
      localizedTestApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    selected = await showPromotionChoiceSheet(
                      context,
                      color: ChessPieceColor.white,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Promover peão'), findsOneWidget);
    expect(find.text('Dama'), findsOneWidget);
    expect(find.text('Torre'), findsOneWidget);
    expect(find.text('Bispo'), findsOneWidget);
    expect(find.text('Cavalo'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('promotion-choice-knight')));
    await tester.pumpAndSettle();

    expect(selected, ChessPieceKind.knight);
  });
}
