import 'package:chess_chalenges/app/faq/presentation/pages/faq_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('shows and expands localized purchase questions', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(localizedTestApp(home: const FaqPage()));

    expect(find.text('Central de ajuda'), findsOneWidget);
    expect(find.text('Jogo e versões'), findsOneWidget);
    expect(find.text('Compras e pagamentos'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('faq-item-free-pro')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('A versão FREE dá acesso a todos os mundos'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
