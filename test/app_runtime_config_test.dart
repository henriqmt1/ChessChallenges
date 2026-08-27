import 'package:chess_chalenges/core/config/app_runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires an update only with a newer minimum build and valid URL', () {
    const required = AppRuntimeConfig(
      currentBuild: 10,
      minimumSupportedBuild: 11,
      storeUrl: 'https://example.com/store',
    );
    const current = AppRuntimeConfig(
      currentBuild: 11,
      minimumSupportedBuild: 11,
      storeUrl: 'https://example.com/store',
    );
    const incomplete = AppRuntimeConfig(
      currentBuild: 10,
      minimumSupportedBuild: 11,
    );

    expect(required.requiresUpdate, isTrue);
    expect(current.requiresUpdate, isFalse);
    expect(incomplete.requiresUpdate, isFalse);
  });

  test('selects the remote update message for the current language', () {
    const config = AppRuntimeConfig(
      messagePt: 'Português',
      messageEn: 'English',
      messageEs: 'Español',
    );

    expect(config.messageFor('pt'), 'Português');
    expect(config.messageFor('en'), 'English');
    expect(config.messageFor('es'), 'Español');
    expect(config.messageFor('fr'), 'Português');
  });
}
