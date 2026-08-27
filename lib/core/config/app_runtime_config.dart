import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppRuntimeConfig {
  const AppRuntimeConfig({
    this.currentBuild = 0,
    this.minimumSupportedBuild = 0,
    this.storeUrl = '',
    this.messagePt = '',
    this.messageEn = '',
    this.messageEs = '',
    this.adsEnabled = true,
    this.loadedFromFirebase = false,
  });

  final int currentBuild;
  final int minimumSupportedBuild;
  final String storeUrl;
  final String messagePt;
  final String messageEn;
  final String messageEs;
  final bool adsEnabled;
  final bool loadedFromFirebase;

  /// Sem uma URL válida da loja, a atualização nunca bloqueia o jogo. Isso
  /// evita travar todos os usuários por uma configuração incompleta.
  bool get requiresUpdate =>
      currentBuild > 0 &&
      minimumSupportedBuild > currentBuild &&
      Uri.tryParse(storeUrl)?.isAbsolute == true;

  String messageFor(String languageCode) {
    final message = switch (languageCode) {
      'en' => messageEn,
      'es' => messageEs,
      _ => messagePt,
    };
    return message.trim();
  }
}

final appRuntimeConfigProvider =
    NotifierProvider<AppRuntimeConfigController, AppRuntimeConfig>(
      AppRuntimeConfigController.new,
    );

class AppRuntimeConfigController extends Notifier<AppRuntimeConfig> {
  static const _fetchTimeout = Duration(seconds: 4);
  static const _forceUpdatePreview = bool.fromEnvironment(
    'FORCE_UPDATE_PREVIEW',
  );
  Future<void>? _initialization;

  @override
  AppRuntimeConfig build() => const AppRuntimeConfig();

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    if (_forceUpdatePreview) {
      state = AppRuntimeConfig(
        currentBuild: 1,
        minimumSupportedBuild: 999,
        storeUrl: _previewStoreUrl,
        messagePt: 'Atualize o app para continuar jogando sem problemas.',
        messageEn: 'Update the app to keep playing without issues.',
        messageEs: 'Actualiza la app para seguir jugando sin problemas.',
        adsEnabled: true,
      );
      return;
    }

    // Testes de widget e plataformas ainda não configuradas não possuem um
    // FirebaseApp. Nesses casos, os padrões locais continuam valendo.
    if (Firebase.apps.isEmpty) {
      return;
    }

    var currentBuild = 0;
    try {
      final packageInfo = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 2),
      );
      currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    } on Object {
      // Falha aberta: atualização remota nunca impede a inicialização local.
    }

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _fetchTimeout,
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults(_defaults);

    var loadedFromFirebase = false;
    try {
      loadedFromFirebase = await remoteConfig.fetchAndActivate().timeout(
        _fetchTimeout,
      );
    } on Object {
      // Valores cacheados ou padrões locais são usados quando estiver offline.
    }

    final platformSuffix = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => '',
    };
    final minimumBuild = platformSuffix.isEmpty
        ? 0
        : remoteConfig.getInt('minimum_${platformSuffix}_build');
    final storeUrl = platformSuffix.isEmpty
        ? ''
        : remoteConfig.getString('${platformSuffix}_store_url');

    state = AppRuntimeConfig(
      currentBuild: currentBuild,
      minimumSupportedBuild: minimumBuild,
      storeUrl: storeUrl,
      messagePt: remoteConfig.getString('force_update_message_pt'),
      messageEn: remoteConfig.getString('force_update_message_en'),
      messageEs: remoteConfig.getString('force_update_message_es'),
      adsEnabled: remoteConfig.getBool('ads_enabled'),
      loadedFromFirebase: loadedFromFirebase,
    );
  }

  static const Map<String, Object> _defaults = {
    'minimum_android_build': 1,
    'minimum_ios_build': 1,
    'android_store_url':
        'https://play.google.com/store/apps/details?id=com.henriquemarinhoteixeira.chesschalenges',
    // Preencher depois que o app ganhar um ID na App Store Connect.
    'ios_store_url': '',
    'force_update_message_pt':
        'Esta versão precisa ser atualizada para continuar funcionando corretamente.',
    'force_update_message_en':
        'This version must be updated to keep working correctly.',
    'force_update_message_es':
        'Esta versión debe actualizarse para seguir funcionando correctamente.',
    'ads_enabled': true,
  };

  static String get _previewStoreUrl {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        'https://play.google.com/store/apps/details?id=com.henriquemarinhoteixeira.chesschalenges',
      TargetPlatform.iOS => 'https://apps.apple.com/app/id0000000000',
      _ =>
        'https://play.google.com/store/apps/details?id=com.henriquemarinhoteixeira.chesschalenges',
    };
  }
}
