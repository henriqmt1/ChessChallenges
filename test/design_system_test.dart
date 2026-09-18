import 'package:chess_chalenges/core/theme/app_theme.dart';
import 'package:chess_chalenges/shared/widgets/app_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared layout and surface components render together', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppPageFrame(
            slivers: [
              SliverToBoxAdapter(
                child: AppSurface(
                  padding: const EdgeInsets.all(16),
                  child: AppPill(child: const Text('Design system')),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Design system'), findsOneWidget);
  });

  testWidgets('toolbar button exposes its tooltip and callback', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppToolbarIconButton(
            tooltip: 'Voltar',
            icon: Icons.arrow_back,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.byTooltip('Voltar'), findsOneWidget);
  });
}
