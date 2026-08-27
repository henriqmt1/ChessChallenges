import 'package:chess_chalenges/shared/monetization/premium_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('shows a focused PRO offer after an ad', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showPremiumSheet(
                      context,
                      variant: PremiumSheetVariant.afterAd,
                    );
                  },
                  child: const Text('open premium'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open premium'));
    await tester.pumpAndSettle();

    expect(find.text('Cansou dos anúncios?'), findsOneWidget);
    expect(
      find.text(
        'Vire PRO uma vez e remova todos os anúncios entre fases para sempre.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('buy-premium-button')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('premium-sheet-close-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('premium-sheet-close-button')));
    await tester.pumpAndSettle();

    expect(find.text('Cansou dos anúncios?'), findsNothing);
  });
}
