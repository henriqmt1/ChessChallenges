import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Chess Chalenges'**
  String get appTitle;

  /// No description provided for @darkModeTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ativar modo escuro'**
  String get darkModeTooltip;

  /// No description provided for @lightModeTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ativar modo claro'**
  String get lightModeTooltip;

  /// No description provided for @faqTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ajuda e perguntas frequentes'**
  String get faqTooltip;

  /// No description provided for @progressTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ver progresso e estatísticas'**
  String get progressTooltip;

  /// No description provided for @progressTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Progresso'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seu resumo no Chess Chalenges.'**
  String get progressSubtitle;

  /// No description provided for @progressHeroTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sua evolução'**
  String get progressHeroTitle;

  /// No description provided for @progressHeroSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estatísticas salvas localmente e sincronizadas quando houver internet.'**
  String get progressHeroSubtitle;

  /// No description provided for @progressSynced.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sincronizado'**
  String get progressSynced;

  /// No description provided for @progressLocalOnly.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvo no aparelho'**
  String get progressLocalOnly;

  /// No description provided for @progressSyncSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sincronização'**
  String get progressSyncSection;

  /// No description provided for @progressSyncGuestTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Proteja seu progresso'**
  String get progressSyncGuestTitle;

  /// No description provided for @progressSyncGuestDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entre com Google ou Apple para recuperar suas estatísticas e fases em outro aparelho.'**
  String get progressSyncGuestDescription;

  /// No description provided for @progressSyncConnectedTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Progresso protegido'**
  String get progressSyncConnectedTitle;

  /// No description provided for @progressSyncConnectedDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conectado como {account}. Seus dados serão sincronizados quando houver internet.'**
  String progressSyncConnectedDescription(String account);

  /// No description provided for @progressSyncConnectedFallback.
  ///
  /// In pt_BR, this message translates to:
  /// **'sua conta'**
  String get progressSyncConnectedFallback;

  /// No description provided for @progressSyncGuestBadge.
  ///
  /// In pt_BR, this message translates to:
  /// **'Visitante'**
  String get progressSyncGuestBadge;

  /// No description provided for @progressSyncConnectedBadge.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conta conectada'**
  String get progressSyncConnectedBadge;

  /// No description provided for @progressSyncGoogleAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar com Google'**
  String get progressSyncGoogleAction;

  /// No description provided for @progressSyncAppleAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar com Apple'**
  String get progressSyncAppleAction;

  /// No description provided for @progressSyncNowAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sincronizar agora'**
  String get progressSyncNowAction;

  /// No description provided for @progressSyncErrorGeneric.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível sincronizar agora. Tente novamente em instantes.'**
  String get progressSyncErrorGeneric;

  /// No description provided for @progressSyncErrorFirebase.
  ///
  /// In pt_BR, this message translates to:
  /// **'O Firebase ainda não está disponível neste ambiente.'**
  String get progressSyncErrorFirebase;

  /// No description provided for @progressSyncErrorGoogleConfig.
  ///
  /// In pt_BR, this message translates to:
  /// **'Login Google ainda precisa ser configurado no Firebase deste app.'**
  String get progressSyncErrorGoogleConfig;

  /// No description provided for @progressSyncErrorAppleConfig.
  ///
  /// In pt_BR, this message translates to:
  /// **'Login Apple ainda precisa ser configurado para este app.'**
  String get progressSyncErrorAppleConfig;

  /// No description provided for @progressSyncErrorProviderDisabled.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esse método de login ainda não está ativado no Firebase.'**
  String get progressSyncErrorProviderDisabled;

  /// No description provided for @progressSyncErrorAccountExists.
  ///
  /// In pt_BR, this message translates to:
  /// **'Essa conta já existe. Entre com ela para puxar o progresso salvo.'**
  String get progressSyncErrorAccountExists;

  /// No description provided for @progressSyncErrorNetwork.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confira sua internet e tente sincronizar novamente.'**
  String get progressSyncErrorNetwork;

  /// No description provided for @progressSyncCanceled.
  ///
  /// In pt_BR, this message translates to:
  /// **'Login cancelado.'**
  String get progressSyncCanceled;

  /// No description provided for @progressRoutineSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Rotina'**
  String get progressRoutineSection;

  /// No description provided for @progressLearningSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Aprendizado'**
  String get progressLearningSection;

  /// No description provided for @progressGamesSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Partidas'**
  String get progressGamesSection;

  /// No description provided for @progressCurrentStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ofensiva atual'**
  String get progressCurrentStreak;

  /// No description provided for @progressBestStreak.
  ///
  /// In pt_BR, this message translates to:
  /// **'Melhor ofensiva'**
  String get progressBestStreak;

  /// No description provided for @progressActiveDays.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dias ativos'**
  String get progressActiveDays;

  /// No description provided for @progressGuidedLessons.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lições concluídas'**
  String get progressGuidedLessons;

  /// No description provided for @progressObjectiveStars.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estrelas em objetivos'**
  String get progressObjectiveStars;

  /// No description provided for @progressObjectiveChallenges.
  ///
  /// In pt_BR, this message translates to:
  /// **'Objetivos concluídos'**
  String get progressObjectiveChallenges;

  /// No description provided for @progressTotalGames.
  ///
  /// In pt_BR, this message translates to:
  /// **'Partidas jogadas'**
  String get progressTotalGames;

  /// No description provided for @progressBotGames.
  ///
  /// In pt_BR, this message translates to:
  /// **'Contra bot'**
  String get progressBotGames;

  /// No description provided for @progressBotWins.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vitórias vs bot'**
  String get progressBotWins;

  /// No description provided for @progressBotAdvancedWins.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vitórias avançado'**
  String get progressBotAdvancedWins;

  /// No description provided for @progressLocalGames.
  ///
  /// In pt_BR, this message translates to:
  /// **'2 jogadores local'**
  String get progressLocalGames;

  /// No description provided for @progressLocalWins.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vitórias locais'**
  String get progressLocalWins;

  /// No description provided for @progressBotSummary.
  ///
  /// In pt_BR, this message translates to:
  /// **'{wins} vitórias • {advancedWins} no avançado'**
  String progressBotSummary(int wins, int advancedWins);

  /// No description provided for @progressLocalSummary.
  ///
  /// In pt_BR, this message translates to:
  /// **'No mesmo celular • {draws} empates'**
  String progressLocalSummary(int draws);

  /// No description provided for @faqComingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'A central de ajuda será adicionada em breve.'**
  String get faqComingSoon;

  /// No description provided for @faqPageTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Central de ajuda'**
  String get faqPageTitle;

  /// No description provided for @faqHeroTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Como podemos ajudar?'**
  String get faqHeroTitle;

  /// No description provided for @faqPageSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Respostas rápidas sobre o jogo, sua conta e compras.'**
  String get faqPageSubtitle;

  /// No description provided for @faqGeneralSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Jogo e versões'**
  String get faqGeneralSection;

  /// No description provided for @faqPurchasesSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Compras e pagamentos'**
  String get faqPurchasesSection;

  /// No description provided for @faqAccountSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conta, aparelhos e atualizações'**
  String get faqAccountSection;

  /// No description provided for @faqFreeProQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Qual é a diferença entre FREE e PRO?'**
  String get faqFreeProQuestion;

  /// No description provided for @faqFreeProAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'A versão FREE dá acesso a todos os mundos e fases seguindo a progressão normal, com anúncios em intervalos controlados. A versão PRO remove os anúncios permanentemente; ela não pula nem desbloqueia fases.'**
  String get faqFreeProAnswer;

  /// No description provided for @faqInternetQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preciso de internet para jogar?'**
  String get faqInternetQuestion;

  /// No description provided for @faqInternetAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'As fases podem ser jogadas offline. A internet é necessária apenas para entrar na conta, sincronizar dados, comprar ou restaurar o PRO e carregar anúncios.'**
  String get faqInternetAnswer;

  /// No description provided for @faqAdsQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Quando os anúncios aparecem?'**
  String get faqAdsQuestion;

  /// No description provided for @faqAdsAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Anúncios aparecem somente na versão FREE e em pausas naturais entre algumas fases. Eles nunca interrompem uma jogada. Se um anúncio não carregar, o jogo continua normalmente.'**
  String get faqAdsAnswer;

  /// No description provided for @faqLifetimeQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'A compra do PRO é mensal?'**
  String get faqLifetimeQuestion;

  /// No description provided for @faqLifetimeAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não. O PRO é uma compra única e vitalícia, sem assinatura ou cobrança recorrente. O preço e a moeda são informados pela Google Play ou App Store antes da confirmação.'**
  String get faqLifetimeAnswer;

  /// No description provided for @faqRestoreQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'O que significa restaurar compra?'**
  String get faqRestoreQuestion;

  /// No description provided for @faqRestoreAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Restaurar compra consulta a Google Play ou App Store para recuperar um PRO que você já comprou. Isso não gera uma nova cobrança e não solicita reembolso.'**
  String get faqRestoreAnswer;

  /// No description provided for @faqRefundQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Como funciona o reembolso?'**
  String get faqRefundQuestion;

  /// No description provided for @faqRefundAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pedidos de reembolso são solicitados e analisados pela Google Play ou App Store. Quando a loja aprova e devolve o valor conforme as regras dela, o acesso PRO relacionado à compra pode ser removido.'**
  String get faqRefundAnswer;

  /// No description provided for @faqAccountQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por que usar uma conta no app?'**
  String get faqAccountQuestion;

  /// No description provided for @faqAccountAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'A conta protege e sincroniza seu acesso PRO entre aparelhos. O direito é vinculado ao identificador interno seguro da sua conta, e não depende do seu e-mail permanecer igual ou visível.'**
  String get faqAccountAnswer;

  /// No description provided for @faqNewDeviceQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'Troquei de celular ou reinstalei o app. E agora?'**
  String get faqNewDeviceQuestion;

  /// No description provided for @faqNewDeviceAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entre com a mesma conta usada anteriormente. O app sincronizará seu acesso PRO; se necessário, use Restaurar compra com a mesma conta da loja que fez o pagamento.'**
  String get faqNewDeviceAnswer;

  /// No description provided for @faqCrossPlatformQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'O PRO funciona no Android e no iPhone?'**
  String get faqCrossPlatformQuestion;

  /// No description provided for @faqCrossPlatformAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sim, quando a compra validada estiver vinculada à mesma conta do app. Sem essa vinculação, cada loja restaura compras apenas dentro do próprio sistema.'**
  String get faqCrossPlatformAnswer;

  /// No description provided for @faqUpdatesQuestion.
  ///
  /// In pt_BR, this message translates to:
  /// **'O app pode exigir uma atualização?'**
  String get faqUpdatesQuestion;

  /// No description provided for @faqUpdatesAnswer.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizações normais ficam disponíveis pela loja. Se uma versão for indispensável para segurança ou compatibilidade, o app poderá pedir uma atualização obrigatória antes de continuar.'**
  String get faqUpdatesAnswer;

  /// No description provided for @faqFooterMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Compras e reembolsos sempre são processados pela loja oficial do seu aparelho. O app nunca solicita seus dados bancários diretamente.'**
  String get faqFooterMessage;

  /// No description provided for @premiumSheetTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Chess Chalenges PRO'**
  String get premiumSheetTitle;

  /// No description provided for @premiumActiveTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sua versão PRO está ativa'**
  String get premiumActiveTitle;

  /// No description provided for @premiumDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Uma compra única para jogar sem anúncios.'**
  String get premiumDescription;

  /// No description provided for @premiumAfterAdTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cansou dos anúncios?'**
  String get premiumAfterAdTitle;

  /// No description provided for @premiumAfterAdDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vire PRO uma vez e remova todos os anúncios entre fases para sempre.'**
  String get premiumAfterAdDescription;

  /// No description provided for @premiumActiveDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Obrigado por apoiar o jogo. Você não verá anúncios entre as fases.'**
  String get premiumActiveDescription;

  /// No description provided for @premiumBenefitNoAds.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem anúncios entre as fases'**
  String get premiumBenefitNoAds;

  /// No description provided for @premiumBenefitLifetime.
  ///
  /// In pt_BR, this message translates to:
  /// **'Acesso vitalício, sem assinatura'**
  String get premiumBenefitLifetime;

  /// No description provided for @premiumBenefitSameProgress.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mantém todo o seu progresso atual'**
  String get premiumBenefitSameProgress;

  /// No description provided for @premiumPriceLoading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Consultando preço...'**
  String get premiumPriceLoading;

  /// No description provided for @premiumBuyAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Liberar PRO • {price}'**
  String premiumBuyAction(String price);

  /// No description provided for @premiumPendingAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Aguardando a loja...'**
  String get premiumPendingAction;

  /// No description provided for @premiumRestoreAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Restaurar compra'**
  String get premiumRestoreAction;

  /// No description provided for @premiumStoreUnavailable.
  ///
  /// In pt_BR, this message translates to:
  /// **'A loja não está disponível agora. Confira a internet e tente novamente.'**
  String get premiumStoreUnavailable;

  /// No description provided for @premiumProductUnavailable.
  ///
  /// In pt_BR, this message translates to:
  /// **'A versão PRO ainda não foi configurada nesta loja.'**
  String get premiumProductUnavailable;

  /// No description provided for @premiumPurchaseFailed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível concluir a compra. Tente novamente em instantes.'**
  String get premiumPurchaseFailed;

  /// No description provided for @privacyOptionsAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Opções de privacidade dos anúncios'**
  String get privacyOptionsAction;

  /// No description provided for @splashLoadingLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preparando seus desafios...'**
  String get splashLoadingLabel;

  /// No description provided for @splashLoadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível preparar o jogo.'**
  String get splashLoadError;

  /// No description provided for @splashRetryAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar novamente'**
  String get splashRetryAction;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualização necessária'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateDefaultMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esta versão precisa ser atualizada para continuar funcionando corretamente.'**
  String get forceUpdateDefaultMessage;

  /// No description provided for @forceUpdateAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar agora'**
  String get forceUpdateAction;

  /// No description provided for @forceUpdateStoreError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível abrir a loja. Tente novamente em instantes.'**
  String get forceUpdateStoreError;

  /// No description provided for @homeChooseModeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Como quer jogar hoje?'**
  String get homeChooseModeTitle;

  /// No description provided for @homeChooseModeSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolha um modo para treinar, jogar ou se preparar para os próximos desafios.'**
  String get homeChooseModeSubtitle;

  /// No description provided for @homePlayAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Jogar'**
  String get homePlayAction;

  /// No description provided for @homeComingSoonAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em breve'**
  String get homeComingSoonAction;

  /// No description provided for @homeGuidedLessonsTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lições guiadas'**
  String get homeGuidedLessonsTitle;

  /// No description provided for @homeGuidedLessonsDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Continue a campanha atual com fases explicadas, dicas e progressão por mundos.'**
  String get homeGuidedLessonsDescription;

  /// No description provided for @homeObjectiveModeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desafios por objetivo'**
  String get homeObjectiveModeTitle;

  /// No description provided for @homeObjectiveModeDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Resolva situações livres, busque até 3 estrelas e vença com menos jogadas.'**
  String get homeObjectiveModeDescription;

  /// No description provided for @objectiveChallengesTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desafios por objetivo'**
  String get objectiveChallengesTitle;

  /// No description provided for @objectiveChallengesHeroTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Busque 3 estrelas'**
  String get objectiveChallengesHeroTitle;

  /// No description provided for @objectiveChallengesHeroSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'com menos jogadas possíveis'**
  String get objectiveChallengesHeroSubtitle;

  /// No description provided for @objectiveChallengesLevelCount.
  ///
  /// In pt_BR, this message translates to:
  /// **'{count} desafios'**
  String objectiveChallengesLevelCount(int count);

  /// No description provided for @objectiveChallengesProgress.
  ///
  /// In pt_BR, this message translates to:
  /// **'{earned}/{total}'**
  String objectiveChallengesProgress(int earned, int total);

  /// No description provided for @objectiveChallengesFutureLevelsNote.
  ///
  /// In pt_BR, this message translates to:
  /// **'Novas fases serão liberadas no futuro.'**
  String get objectiveChallengesFutureLevelsNote;

  /// No description provided for @objectiveChallengeLevelSemantics.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desafio {level}'**
  String objectiveChallengeLevelSemantics(int level);

  /// No description provided for @homeVsBotModeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Contra bot'**
  String get homeVsBotModeTitle;

  /// No description provided for @homeVsBotModeDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Jogue partidas contra bot fácil, médio ou avançado quando quiser treinar livre.'**
  String get homeVsBotModeDescription;

  /// No description provided for @homeLocalPlayersModeTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'2 Jogadores local'**
  String get homeLocalPlayersModeTitle;

  /// No description provided for @homeLocalPlayersModeDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Use o celular como tabuleiro para jogar com outra pessoa no mesmo aparelho.'**
  String get homeLocalPlayersModeDescription;

  /// No description provided for @localGameTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'2 Jogadores local'**
  String get localGameTitle;

  /// No description provided for @localGameSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Um tabuleiro compartilhado para jogar no mesmo celular.'**
  String get localGameSubtitle;

  /// No description provided for @localGameWhiteSide.
  ///
  /// In pt_BR, this message translates to:
  /// **'Brancas'**
  String get localGameWhiteSide;

  /// No description provided for @localGameBlackSide.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pretas'**
  String get localGameBlackSide;

  /// No description provided for @localGameTurnTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vez: {side}'**
  String localGameTurnTitle(String side);

  /// No description provided for @localGameCheckTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'XEQUE!'**
  String get localGameCheckTitle;

  /// No description provided for @localGameCheckTurnDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'{side} precisam defender o rei.'**
  String localGameCheckTurnDescription(String side);

  /// No description provided for @localGameCheckWarning.
  ///
  /// In pt_BR, this message translates to:
  /// **'Xeque no rei. Encontre uma defesa.'**
  String get localGameCheckWarning;

  /// No description provided for @localGameCheckmateTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Xeque-mate'**
  String get localGameCheckmateTitle;

  /// No description provided for @localGameDrawTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Empate'**
  String get localGameDrawTitle;

  /// No description provided for @localGameDrawDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ninguém venceu esta partida. Reinicie para jogar outra.'**
  String get localGameDrawDescription;

  /// No description provided for @localGameWinnerLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'{side} venceram.'**
  String localGameWinnerLabel(String side);

  /// No description provided for @localGameReadyMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Toque uma peça da vez, faça o lance e passe o celular.'**
  String get localGameReadyMessage;

  /// No description provided for @localGameMovesCount.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lances: {count}'**
  String localGameMovesCount(int count);

  /// No description provided for @localGameActivityPending.
  ///
  /// In pt_BR, this message translates to:
  /// **'Faltam {remaining} lances pra ofensiva'**
  String localGameActivityPending(int remaining);

  /// No description provided for @localGameActivityDone.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ofensiva do dia garantida'**
  String get localGameActivityDone;

  /// No description provided for @localGameRestartButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Reiniciar'**
  String get localGameRestartButton;

  /// No description provided for @localGameResetAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Reiniciar partida'**
  String get localGameResetAction;

  /// No description provided for @localGameFlipBoardAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Virar tabuleiro'**
  String get localGameFlipBoardAction;

  /// No description provided for @localGameResetDialogTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Reiniciar partida?'**
  String get localGameResetDialogTitle;

  /// No description provided for @localGameResetDialogMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'A partida atual será apagada e o tabuleiro volta para o início.'**
  String get localGameResetDialogMessage;

  /// No description provided for @localGameResetCancelAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get localGameResetCancelAction;

  /// No description provided for @localGameResetConfirmAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Reiniciar'**
  String get localGameResetConfirmAction;

  /// No description provided for @showLastMoveAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ver último lance'**
  String get showLastMoveAction;

  /// No description provided for @promotionChoiceTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Promover peão'**
  String get promotionChoiceTitle;

  /// No description provided for @promotionChoiceSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolha qual peça esse peão vai virar.'**
  String get promotionChoiceSubtitle;

  /// No description provided for @promotionQueen.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dama'**
  String get promotionQueen;

  /// No description provided for @promotionRook.
  ///
  /// In pt_BR, this message translates to:
  /// **'Torre'**
  String get promotionRook;

  /// No description provided for @promotionBishop.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bispo'**
  String get promotionBishop;

  /// No description provided for @promotionKnight.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cavalo'**
  String get promotionKnight;

  /// No description provided for @botGameTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Contra bot'**
  String get botGameTitle;

  /// No description provided for @botGameChooseDifficultyTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolha o nível do bot'**
  String get botGameChooseDifficultyTitle;

  /// No description provided for @botGameChooseDifficultySubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você joga de brancas. O bot responde de pretas conforme o nível escolhido.'**
  String get botGameChooseDifficultySubtitle;

  /// No description provided for @botDifficultyBeginnerTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Iniciante'**
  String get botDifficultyBeginnerTitle;

  /// No description provided for @botDifficultyBeginnerDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Joga lances legais, mas ainda erra e deixa chances abertas.'**
  String get botDifficultyBeginnerDescription;

  /// No description provided for @botDifficultyIntermediateTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Intermediário'**
  String get botDifficultyIntermediateTitle;

  /// No description provided for @botDifficultyIntermediateDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Procura capturas, xeques e evita peças penduradas.'**
  String get botDifficultyIntermediateDescription;

  /// No description provided for @botDifficultyAdvancedTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Avançado'**
  String get botDifficultyAdvancedTitle;

  /// No description provided for @botDifficultyAdvancedDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Calcula uma resposta à frente antes de escolher a jogada.'**
  String get botDifficultyAdvancedDescription;

  /// No description provided for @botGameStartAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Começar'**
  String get botGameStartAction;

  /// No description provided for @botGameYourTurnTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sua vez'**
  String get botGameYourTurnTitle;

  /// No description provided for @botGameThinkingTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bot pensando...'**
  String get botGameThinkingTitle;

  /// No description provided for @botGameThinkingDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ele está procurando uma resposta. Já já joga.'**
  String get botGameThinkingDescription;

  /// No description provided for @botGameReadyDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você joga de brancas. Toque uma peça e faça seu lance.'**
  String get botGameReadyDescription;

  /// No description provided for @botGamePlayerInCheckDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Seu rei está em xeque. Defenda agora.'**
  String get botGamePlayerInCheckDescription;

  /// No description provided for @botGameBotInCheckDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você colocou o bot em xeque. Ele precisa responder.'**
  String get botGameBotInCheckDescription;

  /// No description provided for @botGameYouWonTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você venceu'**
  String get botGameYouWonTitle;

  /// No description provided for @botGameYouWonDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Xeque-mate no bot. Boa!'**
  String get botGameYouWonDescription;

  /// No description provided for @botGameBotWonTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bot venceu'**
  String get botGameBotWonTitle;

  /// No description provided for @botGameBotWonDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'O bot fechou o xeque-mate. Reinicie para tentar de novo.'**
  String get botGameBotWonDescription;

  /// No description provided for @botGameDrawTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Empate'**
  String get botGameDrawTitle;

  /// No description provided for @botGameDrawDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'A partida terminou sem vencedor. Reinicie para jogar outra.'**
  String get botGameDrawDescription;

  /// No description provided for @campaignLoadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível carregar a campanha: {error}'**
  String campaignLoadError(String error);

  /// No description provided for @worldLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mundo {world}'**
  String worldLabel(int world);

  /// No description provided for @worldSummary.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mate e fundamentos • {levels} fases • {xp} XP'**
  String worldSummary(int levels, int xp);

  /// No description provided for @worldXp.
  ///
  /// In pt_BR, this message translates to:
  /// **'XP do mundo: {earned}/{total}'**
  String worldXp(int earned, int total);

  /// No description provided for @offensiveCount.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ofensiva {count}'**
  String offensiveCount(int count);

  /// No description provided for @nextWorldUnlockedMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mundo 2 liberado. Vamos conectar os puzzles dele em seguida.'**
  String get nextWorldUnlockedMessage;

  /// No description provided for @completeWorldToUnlockMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Complete todas as fases deste mundo para liberar o próximo.'**
  String get completeWorldToUnlockMessage;

  /// No description provided for @completeCurrentLevelToUnlockMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Complete a fase atual para desbloquear.'**
  String get completeCurrentLevelToUnlockMessage;

  /// No description provided for @levelLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase {level}'**
  String levelLabel(int level);

  /// No description provided for @lockedLevelTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase {level} bloqueada'**
  String lockedLevelTitle(int level);

  /// No description provided for @lockedLevelAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase bloqueada'**
  String get lockedLevelAction;

  /// No description provided for @completePreviousLevelsToUnlock.
  ///
  /// In pt_BR, this message translates to:
  /// **'Complete as fases anteriores para liberar esta fase.'**
  String get completePreviousLevelsToUnlock;

  /// No description provided for @comingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em breve'**
  String get comingSoon;

  /// No description provided for @reviewLevelTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Revisar fase {level}'**
  String reviewLevelTitle(int level);

  /// No description provided for @reviewLevelAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Revisar fase'**
  String get reviewLevelAction;

  /// No description provided for @startWithXp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Começar +{xp} XP'**
  String startWithXp(int xp);

  /// No description provided for @xpAlreadyCollectedDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'O XP dessa fase já foi coletado.'**
  String get xpAlreadyCollectedDescription;

  /// No description provided for @completeToAddXpDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Complete para somar XP ao mundo.'**
  String get completeToAddXpDescription;

  /// No description provided for @worldTheme.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mundo {world} • {theme}'**
  String worldTheme(int world, String theme);

  /// No description provided for @levelProgress.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase {current}/{total}'**
  String levelProgress(int current, int total);

  /// No description provided for @xpCollected.
  ///
  /// In pt_BR, this message translates to:
  /// **'XP coletado'**
  String get xpCollected;

  /// No description provided for @xpAmount.
  ///
  /// In pt_BR, this message translates to:
  /// **'+{xp} XP'**
  String xpAmount(int xp);

  /// No description provided for @goToWorld.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ir para o Mundo {world}'**
  String goToWorld(int world);

  /// No description provided for @nextWorld.
  ///
  /// In pt_BR, this message translates to:
  /// **'Próximo mundo'**
  String get nextWorld;

  /// No description provided for @newChallengesUnlocked.
  ///
  /// In pt_BR, this message translates to:
  /// **'Novo conjunto de desafios liberado.'**
  String get newChallengesUnlocked;

  /// No description provided for @completeLevelsToUnlock.
  ///
  /// In pt_BR, this message translates to:
  /// **'Complete {completed}/{total} fases para liberar.'**
  String completeLevelsToUnlock(int completed, int total);

  /// No description provided for @puzzlesLoadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Não foi possível carregar os puzzles: {error}'**
  String puzzlesLoadError(String error);

  /// No description provided for @backTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar'**
  String get backTooltip;

  /// No description provided for @hintTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dica'**
  String get hintTooltip;

  /// No description provided for @hintUsedTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dica já usada neste lance'**
  String get hintUsedTooltip;

  /// No description provided for @puzzleMeta.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mundo {world} • Capítulo {chapter} • Fase {level}'**
  String puzzleMeta(int world, int chapter, int level);

  /// No description provided for @wrongMoveTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lance errado'**
  String get wrongMoveTitle;

  /// No description provided for @moveNotPlayed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esse lance não entrou no tabuleiro.'**
  String get moveNotPlayed;

  /// No description provided for @retryMove.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar lance de novo'**
  String get retryMove;

  /// No description provided for @restartLevel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Recomeçar fase'**
  String get restartLevel;

  /// No description provided for @perfectTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfeito'**
  String get perfectTitle;

  /// No description provided for @reviewCompletedTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Revisão concluída'**
  String get reviewCompletedTitle;

  /// No description provided for @levelCompletedWithXp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase {level} concluída. +{xp} XP'**
  String levelCompletedWithXp(int level, int xp);

  /// No description provided for @levelReviewedXpCollected.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fase {level} revisada. XP já coletado.'**
  String levelReviewedXpCollected(int level);

  /// No description provided for @continueButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @hintButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dica'**
  String get hintButton;

  /// No description provided for @solutionButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Solução'**
  String get solutionButton;

  /// No description provided for @mapButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mapa'**
  String get mapButton;

  /// No description provided for @restartButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Reiniciar'**
  String get restartButton;

  /// No description provided for @resetButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Resetar'**
  String get resetButton;

  /// No description provided for @puzzleMessageFindBestMove.
  ///
  /// In pt_BR, this message translates to:
  /// **'Encontre a melhor jogada.'**
  String get puzzleMessageFindBestMove;

  /// No description provided for @puzzleMessageHintMate001.
  ///
  /// In pt_BR, this message translates to:
  /// **'A dama precisa fechar a última casa do rei.'**
  String get puzzleMessageHintMate001;

  /// No description provided for @puzzleMessageHintSequence002.
  ///
  /// In pt_BR, this message translates to:
  /// **'Comece ocupando o centro.'**
  String get puzzleMessageHintSequence002;

  /// No description provided for @puzzleMessageHintSequence003.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desenvolva com ganho de tempo e pressione o centro.'**
  String get puzzleMessageHintSequence003;

  /// No description provided for @puzzleMessageLookHighlightedPiece.
  ///
  /// In pt_BR, this message translates to:
  /// **'Observe a peça destacada.'**
  String get puzzleMessageLookHighlightedPiece;

  /// No description provided for @puzzleMessageSolution.
  ///
  /// In pt_BR, this message translates to:
  /// **'Solução: {solution}'**
  String puzzleMessageSolution(String solution);

  /// No description provided for @puzzleMessageTryMoveAgain.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tente esse lance de novo.'**
  String get puzzleMessageTryMoveAgain;

  /// No description provided for @puzzleMessageChooseRightSquare.
  ///
  /// In pt_BR, this message translates to:
  /// **'Escolha a casa certa.'**
  String get puzzleMessageChooseRightSquare;

  /// No description provided for @puzzleMessageTapPiece.
  ///
  /// In pt_BR, this message translates to:
  /// **'Toque em uma peça para jogar.'**
  String get puzzleMessageTapPiece;

  /// No description provided for @puzzleMessageWrongMove.
  ///
  /// In pt_BR, this message translates to:
  /// **'Lance errado. Escolha como quer continuar.'**
  String get puzzleMessageWrongMove;

  /// No description provided for @puzzleMessageInconsistent.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esse puzzle está inconsistente. Vamos corrigir a base.'**
  String get puzzleMessageInconsistent;

  /// No description provided for @puzzleMessageInvalidOpponentReply.
  ///
  /// In pt_BR, this message translates to:
  /// **'Resposta automática inválida na base do puzzle.'**
  String get puzzleMessageInvalidOpponentReply;

  /// No description provided for @puzzleMessageCompleted.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfeito. Fase concluída.'**
  String get puzzleMessageCompleted;

  /// No description provided for @puzzleMessageOpponentReplied.
  ///
  /// In pt_BR, this message translates to:
  /// **'Boa. O adversário respondeu.'**
  String get puzzleMessageOpponentReplied;

  /// No description provided for @puzzleMessageContinueSequence.
  ///
  /// In pt_BR, this message translates to:
  /// **'Boa. Continue a sequência.'**
  String get puzzleMessageContinueSequence;

  /// No description provided for @themeMateIn1.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mate em 1'**
  String get themeMateIn1;

  /// No description provided for @themeDevelopment.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desenvolvimento'**
  String get themeDevelopment;

  /// No description provided for @themeOpeningPattern.
  ///
  /// In pt_BR, this message translates to:
  /// **'Padrão de abertura'**
  String get themeOpeningPattern;

  /// No description provided for @themeFundamentals.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fundamentos'**
  String get themeFundamentals;

  /// No description provided for @themeMaterial.
  ///
  /// In pt_BR, this message translates to:
  /// **'Capturas e trocas'**
  String get themeMaterial;

  /// No description provided for @themeFork.
  ///
  /// In pt_BR, this message translates to:
  /// **'Garfos'**
  String get themeFork;

  /// No description provided for @themePin.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cravadas'**
  String get themePin;

  /// No description provided for @themeDiscoveredAttack.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ataques descobertos'**
  String get themeDiscoveredAttack;

  /// No description provided for @themeDefense.
  ///
  /// In pt_BR, this message translates to:
  /// **'Defesa e contra-ataque'**
  String get themeDefense;

  /// No description provided for @themeEndgame.
  ///
  /// In pt_BR, this message translates to:
  /// **'Finais essenciais'**
  String get themeEndgame;

  /// No description provided for @themeCombination.
  ///
  /// In pt_BR, this message translates to:
  /// **'Combinações táticas'**
  String get themeCombination;

  /// No description provided for @themeMastery.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mestre do tabuleiro'**
  String get themeMastery;

  /// No description provided for @difficultyEasy.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fácil'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In pt_BR, this message translates to:
  /// **'Médio'**
  String get difficultyMedium;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In pt_BR, this message translates to:
  /// **'Avançado'**
  String get difficultyAdvanced;

  /// No description provided for @themeComingSoon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em breve'**
  String get themeComingSoon;

  /// No description provided for @leaveGameTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair da partida?'**
  String get leaveGameTitle;

  /// No description provided for @leaveGameMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'A partida atual será perdida. Deseja sair?'**
  String get leaveGameMessage;

  /// No description provided for @keepPlayingAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Continuar jogando'**
  String get keepPlayingAction;

  /// No description provided for @leaveGameAction.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair da partida'**
  String get leaveGameAction;

  /// No description provided for @boardEmptySquare.
  ///
  /// In pt_BR, this message translates to:
  /// **'Casa vazia'**
  String get boardEmptySquare;

  /// No description provided for @boardWhitePieces.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peças brancas'**
  String get boardWhitePieces;

  /// No description provided for @boardBlackPieces.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peças pretas'**
  String get boardBlackPieces;

  /// No description provided for @boardPawn.
  ///
  /// In pt_BR, this message translates to:
  /// **'Peão'**
  String get boardPawn;

  /// No description provided for @boardKing.
  ///
  /// In pt_BR, this message translates to:
  /// **'Rei'**
  String get boardKing;

  /// No description provided for @boardLegalTarget.
  ///
  /// In pt_BR, this message translates to:
  /// **'Destino disponível'**
  String get boardLegalTarget;

  /// No description provided for @homeContinueLevel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Continuar: fase {level}'**
  String homeContinueLevel(int level);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
