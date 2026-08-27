import 'package:chess_chalenges/app/puzzles/presentation/pages/puzzle_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('opens the requested initial puzzle', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _LocalizedPuzzlePage()));

    await _pumpUntilText(tester, 'Fase 3');

    expect(find.text('Fase 3'), findsOneWidget);
  });
}

class _LocalizedPuzzlePage extends StatelessWidget {
  const _LocalizedPuzzlePage();

  @override
  Widget build(BuildContext context) {
    return localizedTestApp(
      home: PuzzlePage(initialPuzzleIndex: 2, showSelector: false),
    );
  }
}

Future<void> _pumpUntilText(WidgetTester tester, String text) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(text).evaluate().isNotEmpty) {
      break;
    }
  }
}
