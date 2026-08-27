import 'package:chess_chalenges/core/config/app_edition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports overriding the app to the free edition', () {
    final container = ProviderContainer(
      overrides: [appEditionProvider.overrideWithValue(AppEdition.free)],
    );
    addTearDown(container.dispose);

    expect(container.read(appEditionProvider), AppEdition.free);
  });
}
