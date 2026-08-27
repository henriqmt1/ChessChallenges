import 'package:chess_chalenges/app/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('shows play on guided lessons before the first level is done', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const HomePage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jogar'), findsWidgets);
    expect(find.text('Continuar'), findsNothing);
  });

  testWidgets(
    'shows continue on guided lessons after the first level is done',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'campaign.completedLevels': <String>['0'],
      });

      await tester.pumpWidget(
        ProviderScope(child: localizedTestApp(home: const HomePage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Continuar'), findsOneWidget);
    },
  );

  testWidgets('keeps local players mode discoverable on the first screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const HomePage())),
    );
    await tester.pumpAndSettle();

    final localCardTop = tester
        .getTopLeft(find.byKey(const ValueKey('mode-local-players-card')))
        .dy;

    expect(localCardTop, lessThan(900));
  });

  testWidgets('opens objective challenges from the home card', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const HomePage())),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('mode-objectives-card')),
    );
    await tester.tap(find.byKey(const ValueKey('mode-objectives-card')));
    await tester.pumpAndSettle();
    await _scrollUntilFound(
      tester,
      find.byKey(const ValueKey('objective-level-1')),
    );

    expect(
      find.byKey(const ValueKey('objective-challenges-page')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('objective-level-1')), findsOneWidget);
  });

  testWidgets('opens progress from the offensive badge', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const HomePage())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('offensive-badge')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('progress-page')), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
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
