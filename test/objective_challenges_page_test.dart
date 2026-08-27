import 'package:chess_chalenges/app/objective_challenges/presentation/pages/objective_challenges_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('shows the 30-level objective challenge map', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(home: const ObjectiveChallengesPage()),
      ),
    );
    await tester.pumpAndSettle();
    await _scrollUntilFound(
      tester,
      find.byKey(const ValueKey('objective-level-1')),
    );

    expect(
      find.byKey(const ValueKey('objective-challenges-page')),
      findsOneWidget,
    );
    expect(find.text('Desafios por objetivo'), findsOneWidget);
    expect(find.text('30 desafios'), findsOneWidget);
    expect(find.text('0/90'), findsOneWidget);
    expect(find.text('90 estrelas'), findsNothing);
    expect(find.text('Mapa'), findsNothing);
    expect(find.byKey(const ValueKey('objective-level-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('objective-level-1-lock')), findsNothing);
    expect(
      find.byKey(const ValueKey('objective-level-2-lock')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('objective-level-30')),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.byKey(const ValueKey('objective-level-30')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('objective-level-30-lock')),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('objective-future-levels-note')),
      500,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Novas fases serão liberadas no futuro.'), findsOneWidget);
  });
}

Future<void> _scrollUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 12; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 120));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -260));
  }
}
