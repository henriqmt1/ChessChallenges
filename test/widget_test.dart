import 'package:chess_chalenges/app/chess_chalenges_app.dart';
import 'package:chess_chalenges/app/campaign/domain/entities/campaign_level_node.dart';
import 'package:chess_chalenges/app/campaign/presentation/viewmodels/campaign_map_state.dart';
import 'package:chess_chalenges/app/campaign/presentation/viewmodels/campaign_map_view_model.dart';
import 'package:chess_chalenges/app/puzzles/domain/entities/puzzle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the branded animated splash during startup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: ChessChalengesApp(locale: Locale('pt', 'BR'))),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('animated-splash')), findsOneWidget);
    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
    expect(find.text('Preparando seus desafios...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('loads the home and opens the guided campaign map', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          campaignMapViewModelProvider.overrideWith(
            (ref) => _campaignStateFor(1),
          ),
        ],
        child: const ChessChalengesApp(
          locale: Locale('pt', 'BR'),
          startupMinimumDuration: Duration.zero,
        ),
      ),
    );

    for (var attempt = 0; attempt < 200; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Como quer jogar hoje?').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(find.text('Como quer jogar hoje?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mode-guided-lessons-card')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('mode-objectives-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('mode-vs-bot-card')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mode-local-players-card')),
      findsOneWidget,
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'Poppins');
    expect(find.byKey(const ValueKey('offensive-fire')), findsOneWidget);
    expect(find.byKey(const ValueKey('theme-mode-toggle')), findsOneWidget);
    expect(find.byKey(const ValueKey('faq-button')), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('faq-button')));
    await tester.pumpAndSettle();
    expect(find.text('Central de ajuda'), findsOneWidget);
    expect(find.byKey(const ValueKey('faq-item-free-pro')), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('app-edition-badge')));
    await tester.pumpAndSettle();
    expect(find.text('Chess Chalenges PRO'), findsOneWidget);
    expect(find.text('Sem anúncios entre as fases'), findsOneWidget);
    Navigator.of(tester.element(find.text('Chess Chalenges PRO'))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('mode-local-players-card')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-local-players-card')));
    await tester.pumpAndSettle();

    expect(find.text('2 Jogadores local'), findsOneWidget);
    expect(find.text('Vez: Brancas'), findsOneWidget);
    expect(find.byKey(const ValueKey('chess-square-e2')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('local-game-back-button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('mode-guided-lessons-card')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-guided-lessons-card')));
    await tester.pumpAndSettle();

    expect(find.text('Mundo 1'), findsOneWidget);
    expect(find.text('0/100 XP'), findsOneWidget);
    expect(find.byKey(const ValueKey('campaign-level-0')), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the selected world 3D emblem', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          campaignMapViewModelProvider.overrideWith(
            (ref) async => const CampaignMapState(
              nodes: [],
              worldIndex: 10,
              worldTheme: 'mastery',
              unlockedWorldCount: 10,
              completedCount: 0,
              currentLevelIndex: 90,
              offensiveCount: 0,
              isActivityCompletedToday: false,
            ),
          ),
        ],
        child: const ChessChalengesApp(
          locale: Locale('pt', 'BR'),
          startupMinimumDuration: Duration.zero,
        ),
      ),
    );

    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find
          .byKey(const ValueKey('mode-guided-lessons-card'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    await tester.tap(find.byKey(const ValueKey('mode-guided-lessons-card')));
    await tester.pumpAndSettle();

    expect(find.text('Mundo 10'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/chess/ui/world_10_king.png',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('lets users preview locked worlds and levels', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          campaignMapViewModelProvider.overrideWith((ref) {
            return _campaignStateFor(ref.watch(selectedWorldViewModelProvider));
          }),
        ],
        child: const ChessChalengesApp(
          locale: Locale('pt', 'BR'),
          startupMinimumDuration: Duration.zero,
        ),
      ),
    );

    for (var attempt = 0; attempt < 50; attempt++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find
          .byKey(const ValueKey('mode-guided-lessons-card'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    await tester.tap(find.byKey(const ValueKey('mode-guided-lessons-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('world-selector')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('world-selector')));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/chess/ui/world_2_queen.png',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('world-option-2')));
    await tester.pumpAndSettle();

    expect(find.text('Mundo 2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('campaign-level-10')));
    await tester.pumpAndSettle();

    expect(find.text('Fase 1 bloqueada'), findsOneWidget);
    expect(
      find.text('Complete as fases anteriores para liberar esta fase.'),
      findsOneWidget,
    );
    final lockedButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Fase bloqueada'),
    );
    expect(lockedButton.onPressed, isNull);
    expect(find.byType(SnackBar), findsNothing);

    Navigator.of(tester.element(find.text('Fase 1 bloqueada'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('campaign-back-button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('mode-guided-lessons-card')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('mode-guided-lessons-card')));
    await tester.pumpAndSettle();

    expect(find.text('Mundo 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('campaign-level-0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CampaignMapState _campaignStateFor(int world) {
  final startIndex = (world - 1) * 10;
  final nodes = List.generate(10, (localIndex) {
    final index = startIndex + localIndex;
    return CampaignLevelNode(
      index: index,
      status: world == 1 && localIndex == 0
          ? CampaignLevelNodeStatus.current
          : CampaignLevelNodeStatus.locked,
      type: CampaignLevelNodeType.normal,
      xOffset: 0,
      puzzle: Puzzle(
        id: 'test-$index',
        objective: 'Encontre a melhor jogada.',
        fen: '8/8/8/8/8/8/8/K6k w - - 0 1',
        sideToMove: 'white',
        orientation: 'white',
        moves: const ['a1a2'],
        playerMoveIndexes: const {0},
        theme: world == 1 ? 'fundamentals' : 'mateIn1',
        difficulty: 1,
        world: world,
        chapter: 1,
        level: localIndex + 1,
        hint: const PuzzleHint(text: 'Mova o rei.', from: 'a1', to: 'a2'),
      ),
    );
  });

  return CampaignMapState(
    nodes: nodes,
    worldIndex: world,
    worldTheme: world == 1 ? 'fundamentals' : 'mateIn1',
    unlockedWorldCount: 1,
    completedCount: 0,
    currentLevelIndex: 0,
    offensiveCount: 0,
    isActivityCompletedToday: false,
  );
}
