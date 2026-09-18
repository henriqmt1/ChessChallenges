import 'package:chess_chalenges/app/local_game/presentation/pages/local_game_page.dart';
import 'package:chess_chalenges/app/local_game/presentation/viewmodels/local_game_view_model.dart';
import 'package:chess_chalenges/shared/monetization/ads_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/localized_test_app.dart';

void main() {
  testWidgets('makes check state prominent in the local game', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const LocalGamePage())),
    );

    expect(find.text('Vez: Brancas'), findsOneWidget);

    await _playMove(tester, from: 'f2', to: 'f3');
    await _playMove(tester, from: 'e7', to: 'e5');
    await _playMove(tester, from: 'a2', to: 'a3');
    await _playMove(tester, from: 'd8', to: 'h4');

    expect(find.text('XEQUE!'), findsOneWidget);
    expect(find.text('Brancas precisam defender o rei.'), findsOneWidget);
  });

  testWidgets('asks for confirmation before restarting the local game', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: localizedTestApp(home: const LocalGamePage())),
    );

    expect(find.text('2 Jogadores local'), findsOneWidget);
    expect(find.text('Virar tabuleiro'), findsOneWidget);
    expect(find.text('Reiniciar'), findsOneWidget);

    await _playMove(tester, from: 'f2', to: 'f3');
    expect(find.text('Vez: Pretas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('local-game-reset-button')));
    await tester.pumpAndSettle();

    expect(find.text('Reiniciar partida?'), findsOneWidget);
    expect(
      find.text(
        'A partida atual será apagada e o tabuleiro volta para o início.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Vez: Pretas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('local-game-reset-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reiniciar').last);
    await tester.pumpAndSettle();

    expect(find.text('Vez: Brancas'), findsOneWidget);
  });

  testWidgets('starts a fresh local game after leaving and opening again', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: localizedTestApp(
          home: const _LocalGameHost(keepStateAlive: true),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-local-game-button')));
    await tester.pumpAndSettle();

    await _playMove(tester, from: 'f2', to: 'f3');
    expect(find.text('Vez: Pretas'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('local-game-back-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-local-game-button')));
    await tester.pumpAndSettle();

    expect(find.text('Vez: Brancas'), findsOneWidget);
  });

  testWidgets('tries to show an ad after a local game finishes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ads = _FakeAdsViewModel();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adsViewModelProvider.overrideWith(() => ads)],
        child: localizedTestApp(home: const LocalGamePage()),
      ),
    );

    await _playMove(tester, from: 'f2', to: 'f3');
    await _playMove(tester, from: 'e7', to: 'e5');
    await _playMove(tester, from: 'g2', to: 'g4');
    await _playMove(tester, from: 'd8', to: 'h4');
    await tester.pump();

    expect(find.text('Xeque-mate'), findsOneWidget);
    expect(ads.localGameAdCalls, 1);
    expect(ads.lastPremiumValue, isFalse);
  });
}

class _FakeAdsViewModel extends AdsViewModel {
  int localGameAdCalls = 0;
  bool? lastPremiumValue;

  @override
  AdsState build() {
    return const AdsState(isInitialized: true, canRequestAds: true);
  }

  @override
  Future<bool> showAfterLocalGameIfEligible({required bool isPremium}) async {
    localGameAdCalls++;
    lastPremiumValue = isPremium;
    return false;
  }
}

class _LocalGameHost extends ConsumerWidget {
  const _LocalGameHost({this.keepStateAlive = false});

  final bool keepStateAlive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (keepStateAlive) {
      ref.watch(localGameViewModelProvider);
    }

    return Scaffold(
      body: Center(
        child: FilledButton(
          key: const ValueKey('open-local-game-button'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LocalGamePage()),
            );
          },
          child: const Text('Abrir local'),
        ),
      ),
    );
  }
}

Future<void> _playMove(
  WidgetTester tester, {
  required String from,
  required String to,
}) async {
  await tester.tap(find.byKey(ValueKey('chess-square-$from')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('chess-square-$to')));
  await tester.pump();
}
