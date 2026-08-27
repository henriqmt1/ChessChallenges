import 'package:chess_chalenges/shared/feedback/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('error toast does not stack repeated messages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => AppToast.showError(context, 'Algo deu errado'),
                child: const Text('Mostrar erro'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mostrar erro'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Mostrar erro'));
    await tester.pump();

    expect(find.byKey(const ValueKey('app-error-toast')), findsOneWidget);
    expect(find.text('Algo deu errado'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const ValueKey('app-error-toast')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
