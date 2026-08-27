// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Chess Chalenges';

  @override
  String get darkModeTooltip => 'Ativar modo escuro';

  @override
  String get lightModeTooltip => 'Ativar modo claro';

  @override
  String get faqTooltip => 'Ajuda e perguntas frequentes';

  @override
  String get progressTooltip => 'Ver progresso e estatísticas';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Seu resumo no Chess Chalenges.';

  @override
  String get progressHeroTitle => 'Sua evolução';

  @override
  String get progressHeroSubtitle =>
      'Estatísticas salvas localmente e sincronizadas quando houver internet.';

  @override
  String get progressSynced => 'Sincronizado';

  @override
  String get progressLocalOnly => 'Salvo no aparelho';

  @override
  String get progressSyncSection => 'Sincronização';

  @override
  String get progressSyncGuestTitle => 'Proteja seu progresso';

  @override
  String get progressSyncGuestDescription =>
      'Entre com Google ou Apple para recuperar suas estatísticas e fases em outro aparelho.';

  @override
  String get progressSyncConnectedTitle => 'Progresso protegido';

  @override
  String progressSyncConnectedDescription(String account) {
    return 'Conectado como $account. Seus dados serão sincronizados quando houver internet.';
  }

  @override
  String get progressSyncConnectedFallback => 'sua conta';

  @override
  String get progressSyncGuestBadge => 'Visitante';

  @override
  String get progressSyncConnectedBadge => 'Conta conectada';

  @override
  String get progressSyncGoogleAction => 'Entrar com Google';

  @override
  String get progressSyncAppleAction => 'Entrar com Apple';

  @override
  String get progressSyncNowAction => 'Sincronizar agora';

  @override
  String get progressSyncErrorGeneric =>
      'Não foi possível sincronizar agora. Tente novamente em instantes.';

  @override
  String get progressSyncErrorFirebase =>
      'O Firebase ainda não está disponível neste ambiente.';

  @override
  String get progressSyncErrorGoogleConfig =>
      'Login Google ainda precisa ser configurado no Firebase deste app.';

  @override
  String get progressSyncErrorAppleConfig =>
      'Login Apple ainda precisa ser configurado para este app.';

  @override
  String get progressSyncErrorProviderDisabled =>
      'Esse método de login ainda não está ativado no Firebase.';

  @override
  String get progressSyncErrorAccountExists =>
      'Essa conta já existe. Entre com ela para puxar o progresso salvo.';

  @override
  String get progressSyncErrorNetwork =>
      'Confira sua internet e tente sincronizar novamente.';

  @override
  String get progressSyncCanceled => 'Login cancelado.';

  @override
  String get progressRoutineSection => 'Rotina';

  @override
  String get progressLearningSection => 'Aprendizado';

  @override
  String get progressGamesSection => 'Partidas';

  @override
  String get progressCurrentStreak => 'Ofensiva atual';

  @override
  String get progressBestStreak => 'Melhor ofensiva';

  @override
  String get progressActiveDays => 'Dias ativos';

  @override
  String get progressGuidedLessons => 'Lições concluídas';

  @override
  String get progressObjectiveStars => 'Estrelas em objetivos';

  @override
  String get progressObjectiveChallenges => 'Objetivos concluídos';

  @override
  String get progressTotalGames => 'Partidas jogadas';

  @override
  String get progressBotGames => 'Contra bot';

  @override
  String get progressBotWins => 'Vitórias vs bot';

  @override
  String get progressBotAdvancedWins => 'Vitórias avançado';

  @override
  String get progressLocalGames => '2 jogadores local';

  @override
  String get progressLocalWins => 'Vitórias locais';

  @override
  String progressBotSummary(int wins, int advancedWins) {
    return '$wins vitórias • $advancedWins no avançado';
  }

  @override
  String progressLocalSummary(int draws) {
    return 'No mesmo celular • $draws empates';
  }

  @override
  String get faqComingSoon => 'A central de ajuda será adicionada em breve.';

  @override
  String get faqPageTitle => 'Central de ajuda';

  @override
  String get faqHeroTitle => 'Como podemos ajudar?';

  @override
  String get faqPageSubtitle =>
      'Respostas rápidas sobre o jogo, a sua conta e compras.';

  @override
  String get faqGeneralSection => 'Jogo e versões';

  @override
  String get faqPurchasesSection => 'Compras e pagamentos';

  @override
  String get faqAccountSection => 'Conta, dispositivos e atualizações';

  @override
  String get faqFreeProQuestion => 'Qual é a diferença entre FREE e PRO?';

  @override
  String get faqFreeProAnswer =>
      'A versão FREE dá acesso a todos os mundos e fases seguindo a progressão normal, com anúncios em intervalos controlados. A versão PRO remove os anúncios permanentemente; não salta nem desbloqueia fases.';

  @override
  String get faqInternetQuestion => 'Preciso de internet para jogar?';

  @override
  String get faqInternetAnswer =>
      'As fases podem ser jogadas offline. A internet é necessária apenas para entrar na conta, sincronizar dados, comprar ou restaurar o PRO e carregar anúncios.';

  @override
  String get faqAdsQuestion => 'Quando aparecem os anúncios?';

  @override
  String get faqAdsAnswer =>
      'Os anúncios aparecem apenas na versão FREE e em pausas naturais entre algumas fases. Nunca interrompem uma jogada. Se um anúncio não carregar, o jogo continua normalmente.';

  @override
  String get faqLifetimeQuestion => 'A compra do PRO é mensal?';

  @override
  String get faqLifetimeAnswer =>
      'Não. O PRO é uma compra única e vitalícia, sem subscrição ou cobrança recorrente. O preço e a moeda são indicados pela Google Play ou App Store antes da confirmação.';

  @override
  String get faqRestoreQuestion => 'O que significa restaurar compra?';

  @override
  String get faqRestoreAnswer =>
      'Restaurar compra consulta a Google Play ou App Store para recuperar um PRO que já comprou. Isto não gera uma nova cobrança e não solicita reembolso.';

  @override
  String get faqRefundQuestion => 'Como funciona o reembolso?';

  @override
  String get faqRefundAnswer =>
      'Os pedidos de reembolso são solicitados e analisados pela Google Play ou App Store. Quando a loja aprova e devolve o valor segundo as suas regras, o acesso PRO relacionado com a compra pode ser removido.';

  @override
  String get faqAccountQuestion => 'Por que usar uma conta na aplicação?';

  @override
  String get faqAccountAnswer =>
      'A conta protege e sincroniza o seu acesso PRO entre dispositivos. O direito é associado ao identificador interno seguro da conta e não depende de o e-mail permanecer igual ou visível.';

  @override
  String get faqNewDeviceQuestion =>
      'Troquei de telemóvel ou reinstalei a aplicação. E agora?';

  @override
  String get faqNewDeviceAnswer =>
      'Entre com a mesma conta usada anteriormente. A aplicação sincronizará o acesso PRO; se necessário, use Restaurar compra com a mesma conta da loja que efetuou o pagamento.';

  @override
  String get faqCrossPlatformQuestion =>
      'O PRO funciona no Android e no iPhone?';

  @override
  String get faqCrossPlatformAnswer =>
      'Sim, quando a compra validada estiver associada à mesma conta da aplicação. Sem essa associação, cada loja restaura compras apenas dentro do seu próprio sistema.';

  @override
  String get faqUpdatesQuestion => 'A aplicação pode exigir uma atualização?';

  @override
  String get faqUpdatesAnswer =>
      'As atualizações normais ficam disponíveis na loja. Se uma versão for indispensável para segurança ou compatibilidade, a aplicação poderá pedir uma atualização obrigatória antes de continuar.';

  @override
  String get faqFooterMessage =>
      'As compras e os reembolsos são sempre processados pela loja oficial do seu dispositivo. A aplicação nunca solicita os seus dados bancários diretamente.';

  @override
  String get premiumSheetTitle => 'Chess Chalenges PRO';

  @override
  String get premiumActiveTitle => 'A sua versão PRO está ativa';

  @override
  String get premiumDescription => 'Uma compra única para jogar sem anúncios.';

  @override
  String get premiumAfterAdTitle => 'Cansou-se dos anúncios?';

  @override
  String get premiumAfterAdDescription =>
      'Passe para PRO uma vez e remova todos os anúncios entre fases para sempre.';

  @override
  String get premiumActiveDescription =>
      'Obrigado por apoiar o jogo. Não verá anúncios entre as fases.';

  @override
  String get premiumBenefitNoAds => 'Sem anúncios entre as fases';

  @override
  String get premiumBenefitLifetime => 'Acesso vitalício, sem subscrição';

  @override
  String get premiumBenefitSameProgress => 'Mantém todo o progresso atual';

  @override
  String get premiumPriceLoading => 'A consultar preço...';

  @override
  String premiumBuyAction(String price) {
    return 'Desbloquear PRO • $price';
  }

  @override
  String get premiumPendingAction => 'A aguardar a loja...';

  @override
  String get premiumRestoreAction => 'Restaurar compra';

  @override
  String get premiumStoreUnavailable =>
      'A loja não está disponível agora. Verifique a internet e tente novamente.';

  @override
  String get premiumProductUnavailable =>
      'A versão PRO ainda não foi configurada nesta loja.';

  @override
  String get premiumPurchaseFailed =>
      'Não foi possível concluir a compra. Tente novamente dentro de instantes.';

  @override
  String get privacyOptionsAction => 'Opções de privacidade dos anúncios';

  @override
  String get splashLoadingLabel => 'Preparando seus desafios...';

  @override
  String get splashLoadError => 'Não foi possível preparar o jogo.';

  @override
  String get splashRetryAction => 'Tentar novamente';

  @override
  String get forceUpdateTitle => 'Atualização necessária';

  @override
  String get forceUpdateDefaultMessage =>
      'Esta versão precisa ser atualizada para continuar funcionando corretamente.';

  @override
  String get forceUpdateAction => 'Atualizar agora';

  @override
  String get forceUpdateStoreError =>
      'Não foi possível abrir a loja. Tente novamente em instantes.';

  @override
  String get homeChooseModeTitle => 'Como quer jogar hoje?';

  @override
  String get homeChooseModeSubtitle =>
      'Escolha um modo para treinar, jogar ou preparar-se para os próximos desafios.';

  @override
  String get homePlayAction => 'Jogar';

  @override
  String get homeComingSoonAction => 'Em breve';

  @override
  String get homeGuidedLessonsTitle => 'Lições guiadas';

  @override
  String get homeGuidedLessonsDescription =>
      'Continue a campanha atual com fases explicadas, dicas e progressão por mundos.';

  @override
  String get homeObjectiveModeTitle => 'Desafios por objetivo';

  @override
  String get homeObjectiveModeDescription =>
      'Resolva situações livres, procure até 3 estrelas e vença com menos jogadas.';

  @override
  String get objectiveChallengesTitle => 'Desafios por objetivo';

  @override
  String get objectiveChallengesHeroTitle => 'Procure 3 estrelas';

  @override
  String get objectiveChallengesHeroSubtitle => 'com menos jogadas possíveis';

  @override
  String objectiveChallengesLevelCount(int count) {
    return '$count desafios';
  }

  @override
  String objectiveChallengesProgress(int earned, int total) {
    return '$earned/$total';
  }

  @override
  String get objectiveChallengesFutureLevelsNote =>
      'Novas fases serão liberadas no futuro.';

  @override
  String objectiveChallengeLevelSemantics(int level) {
    return 'Desafio $level';
  }

  @override
  String get homeVsBotModeTitle => 'Contra bot';

  @override
  String get homeVsBotModeDescription =>
      'Jogue partidas contra bot fácil, médio ou avançado quando quiser treinar livremente.';

  @override
  String get homeLocalPlayersModeTitle => '2 Jogadores local';

  @override
  String get homeLocalPlayersModeDescription =>
      'Use o telemóvel como tabuleiro para jogar com outra pessoa no mesmo aparelho.';

  @override
  String get localGameTitle => '2 Jogadores local';

  @override
  String get localGameSubtitle =>
      'Um tabuleiro partilhado para jogar no mesmo telemóvel.';

  @override
  String get localGameWhiteSide => 'Brancas';

  @override
  String get localGameBlackSide => 'Pretas';

  @override
  String localGameTurnTitle(String side) {
    return 'Vez: $side';
  }

  @override
  String get localGameCheckTitle => 'XEQUE!';

  @override
  String localGameCheckTurnDescription(String side) {
    return '$side precisam defender o rei.';
  }

  @override
  String get localGameCheckWarning => 'Xeque no rei. Encontre uma defesa.';

  @override
  String get localGameCheckmateTitle => 'Xeque-mate';

  @override
  String get localGameDrawTitle => 'Empate';

  @override
  String get localGameDrawDescription =>
      'Ninguém venceu esta partida. Reinicie para jogar outra.';

  @override
  String localGameWinnerLabel(String side) {
    return '$side venceram.';
  }

  @override
  String get localGameReadyMessage =>
      'Toque numa peça da vez, faça o lance e passe o telemóvel.';

  @override
  String localGameMovesCount(int count) {
    return 'Lances: $count';
  }

  @override
  String localGameActivityPending(int remaining) {
    return 'Faltam $remaining lances para a ofensiva';
  }

  @override
  String get localGameActivityDone => 'Ofensiva do dia garantida';

  @override
  String get localGameRestartButton => 'Reiniciar';

  @override
  String get localGameResetAction => 'Reiniciar partida';

  @override
  String get localGameFlipBoardAction => 'Virar tabuleiro';

  @override
  String get localGameResetDialogTitle => 'Reiniciar partida?';

  @override
  String get localGameResetDialogMessage =>
      'A partida atual será apagada e o tabuleiro volta para o início.';

  @override
  String get localGameResetCancelAction => 'Cancelar';

  @override
  String get localGameResetConfirmAction => 'Reiniciar';

  @override
  String get showLastMoveAction => 'Ver último lance';

  @override
  String get promotionChoiceTitle => 'Promover peão';

  @override
  String get promotionChoiceSubtitle =>
      'Escolha em que peça este peão vai transformar-se.';

  @override
  String get promotionQueen => 'Dama';

  @override
  String get promotionRook => 'Torre';

  @override
  String get promotionBishop => 'Bispo';

  @override
  String get promotionKnight => 'Cavalo';

  @override
  String get botGameTitle => 'Contra bot';

  @override
  String get botGameChooseDifficultyTitle => 'Escolha o nível do bot';

  @override
  String get botGameChooseDifficultySubtitle =>
      'Você joga de brancas. O bot responde de pretas conforme o nível escolhido.';

  @override
  String get botDifficultyBeginnerTitle => 'Iniciante';

  @override
  String get botDifficultyBeginnerDescription =>
      'Joga lances legais, mas ainda erra e deixa oportunidades abertas.';

  @override
  String get botDifficultyIntermediateTitle => 'Intermédio';

  @override
  String get botDifficultyIntermediateDescription =>
      'Procura capturas, xeques e evita peças penduradas.';

  @override
  String get botDifficultyAdvancedTitle => 'Avançado';

  @override
  String get botDifficultyAdvancedDescription =>
      'Calcula uma resposta à frente antes de escolher a jogada.';

  @override
  String get botGameStartAction => 'Começar';

  @override
  String get botGameYourTurnTitle => 'A sua vez';

  @override
  String get botGameThinkingTitle => 'Bot a pensar...';

  @override
  String get botGameThinkingDescription =>
      'Ele está a procurar uma resposta. Já já joga.';

  @override
  String get botGameReadyDescription =>
      'Você joga de brancas. Toque numa peça e faça o lance.';

  @override
  String get botGamePlayerInCheckDescription =>
      'O seu rei está em xeque. Defenda agora.';

  @override
  String get botGameBotInCheckDescription =>
      'Você colocou o bot em xeque. Ele precisa responder.';

  @override
  String get botGameYouWonTitle => 'Você venceu';

  @override
  String get botGameYouWonDescription => 'Xeque-mate no bot. Boa!';

  @override
  String get botGameBotWonTitle => 'Bot venceu';

  @override
  String get botGameBotWonDescription =>
      'O bot fechou o xeque-mate. Reinicie para tentar de novo.';

  @override
  String get botGameDrawTitle => 'Empate';

  @override
  String get botGameDrawDescription =>
      'A partida terminou sem vencedor. Reinicie para jogar outra.';

  @override
  String campaignLoadError(String error) {
    return 'Não foi possível carregar a campanha: $error';
  }

  @override
  String worldLabel(int world) {
    return 'Mundo $world';
  }

  @override
  String worldSummary(int levels, int xp) {
    return 'Mate e fundamentos • $levels fases • $xp XP';
  }

  @override
  String worldXp(int earned, int total) {
    return 'XP do mundo: $earned/$total';
  }

  @override
  String offensiveCount(int count) {
    return 'Ofensiva $count';
  }

  @override
  String get nextWorldUnlockedMessage =>
      'Mundo 2 liberado. Vamos conectar os puzzles dele em seguida.';

  @override
  String get completeWorldToUnlockMessage =>
      'Complete todas as fases deste mundo para liberar o próximo.';

  @override
  String get completeCurrentLevelToUnlockMessage =>
      'Complete a fase atual para desbloquear.';

  @override
  String levelLabel(int level) {
    return 'Fase $level';
  }

  @override
  String lockedLevelTitle(int level) {
    return 'Fase $level bloqueada';
  }

  @override
  String get lockedLevelAction => 'Fase bloqueada';

  @override
  String get completePreviousLevelsToUnlock =>
      'Complete as fases anteriores para liberar esta fase.';

  @override
  String get comingSoon => 'Em breve';

  @override
  String reviewLevelTitle(int level) {
    return 'Revisar fase $level';
  }

  @override
  String get reviewLevelAction => 'Revisar fase';

  @override
  String startWithXp(int xp) {
    return 'Começar +$xp XP';
  }

  @override
  String get xpAlreadyCollectedDescription =>
      'O XP dessa fase já foi coletado.';

  @override
  String get completeToAddXpDescription => 'Complete para somar XP ao mundo.';

  @override
  String worldTheme(int world, String theme) {
    return 'Mundo $world • $theme';
  }

  @override
  String levelProgress(int current, int total) {
    return 'Fase $current/$total';
  }

  @override
  String get xpCollected => 'XP coletado';

  @override
  String xpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String goToWorld(int world) {
    return 'Ir para o Mundo $world';
  }

  @override
  String get nextWorld => 'Próximo mundo';

  @override
  String get newChallengesUnlocked => 'Novo conjunto de desafios liberado.';

  @override
  String completeLevelsToUnlock(int completed, int total) {
    return 'Complete $completed/$total fases para liberar.';
  }

  @override
  String puzzlesLoadError(String error) {
    return 'Não foi possível carregar os puzzles: $error';
  }

  @override
  String get backTooltip => 'Voltar';

  @override
  String get hintTooltip => 'Dica';

  @override
  String get hintUsedTooltip => 'Dica já usada neste lance';

  @override
  String puzzleMeta(int world, int chapter, int level) {
    return 'Mundo $world • Capítulo $chapter • Fase $level';
  }

  @override
  String get wrongMoveTitle => 'Lance errado';

  @override
  String get moveNotPlayed => 'Esse lance não entrou no tabuleiro.';

  @override
  String get retryMove => 'Tentar lance de novo';

  @override
  String get restartLevel => 'Recomeçar fase';

  @override
  String get perfectTitle => 'Perfeito';

  @override
  String get reviewCompletedTitle => 'Revisão concluída';

  @override
  String levelCompletedWithXp(int level, int xp) {
    return 'Fase $level concluída. +$xp XP';
  }

  @override
  String levelReviewedXpCollected(int level) {
    return 'Fase $level revisada. XP já coletado.';
  }

  @override
  String get continueButton => 'Continuar';

  @override
  String get hintButton => 'Dica';

  @override
  String get solutionButton => 'Solução';

  @override
  String get mapButton => 'Mapa';

  @override
  String get restartButton => 'Reiniciar';

  @override
  String get resetButton => 'Resetar';

  @override
  String get puzzleMessageFindBestMove => 'Encontre a melhor jogada.';

  @override
  String get puzzleMessageHintMate001 =>
      'A dama precisa fechar a última casa do rei.';

  @override
  String get puzzleMessageHintSequence002 => 'Comece ocupando o centro.';

  @override
  String get puzzleMessageHintSequence003 =>
      'Desenvolva com ganho de tempo e pressione o centro.';

  @override
  String get puzzleMessageLookHighlightedPiece => 'Observe a peça destacada.';

  @override
  String puzzleMessageSolution(String solution) {
    return 'Solução: $solution';
  }

  @override
  String get puzzleMessageTryMoveAgain => 'Tente esse lance de novo.';

  @override
  String get puzzleMessageChooseRightSquare => 'Escolha a casa certa.';

  @override
  String get puzzleMessageTapPiece => 'Toque em uma peça para jogar.';

  @override
  String get puzzleMessageWrongMove =>
      'Lance errado. Escolha como quer continuar.';

  @override
  String get puzzleMessageInconsistent =>
      'Esse puzzle está inconsistente. Vamos corrigir a base.';

  @override
  String get puzzleMessageInvalidOpponentReply =>
      'Resposta automática inválida na base do puzzle.';

  @override
  String get puzzleMessageCompleted => 'Perfeito. Fase concluída.';

  @override
  String get puzzleMessageOpponentReplied => 'Boa. O adversário respondeu.';

  @override
  String get puzzleMessageContinueSequence => 'Boa. Continue a sequência.';

  @override
  String get themeMateIn1 => 'Mate em 1';

  @override
  String get themeDevelopment => 'Desenvolvimento';

  @override
  String get themeOpeningPattern => 'Padrão de abertura';

  @override
  String get themeFundamentals => 'Fundamentos';

  @override
  String get themeMaterial => 'Capturas e trocas';

  @override
  String get themeFork => 'Garfos';

  @override
  String get themePin => 'Cravadas';

  @override
  String get themeDiscoveredAttack => 'Ataques descobertos';

  @override
  String get themeDefense => 'Defesa e contra-ataque';

  @override
  String get themeEndgame => 'Finais essenciais';

  @override
  String get themeCombination => 'Combinações táticas';

  @override
  String get themeMastery => 'Mestre do tabuleiro';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyAdvanced => 'Avançado';

  @override
  String get themeComingSoon => 'Em breve';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Chess Chalenges';

  @override
  String get darkModeTooltip => 'Ativar modo escuro';

  @override
  String get lightModeTooltip => 'Ativar modo claro';

  @override
  String get faqTooltip => 'Ajuda e perguntas frequentes';

  @override
  String get progressTooltip => 'Ver progresso e estatísticas';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get progressSubtitle => 'Seu resumo no Chess Chalenges.';

  @override
  String get progressHeroTitle => 'Sua evolução';

  @override
  String get progressHeroSubtitle =>
      'Estatísticas salvas localmente e sincronizadas quando houver internet.';

  @override
  String get progressSynced => 'Sincronizado';

  @override
  String get progressLocalOnly => 'Salvo no aparelho';

  @override
  String get progressSyncSection => 'Sincronização';

  @override
  String get progressSyncGuestTitle => 'Proteja seu progresso';

  @override
  String get progressSyncGuestDescription =>
      'Entre com Google ou Apple para recuperar suas estatísticas e fases em outro aparelho.';

  @override
  String get progressSyncConnectedTitle => 'Progresso protegido';

  @override
  String progressSyncConnectedDescription(String account) {
    return 'Conectado como $account. Seus dados serão sincronizados quando houver internet.';
  }

  @override
  String get progressSyncConnectedFallback => 'sua conta';

  @override
  String get progressSyncGuestBadge => 'Visitante';

  @override
  String get progressSyncConnectedBadge => 'Conta conectada';

  @override
  String get progressSyncGoogleAction => 'Entrar com Google';

  @override
  String get progressSyncAppleAction => 'Entrar com Apple';

  @override
  String get progressSyncNowAction => 'Sincronizar agora';

  @override
  String get progressSyncErrorGeneric =>
      'Não foi possível sincronizar agora. Tente novamente em instantes.';

  @override
  String get progressSyncErrorFirebase =>
      'O Firebase ainda não está disponível neste ambiente.';

  @override
  String get progressSyncErrorGoogleConfig =>
      'Login Google ainda precisa ser configurado no Firebase deste app.';

  @override
  String get progressSyncErrorAppleConfig =>
      'Login Apple ainda precisa ser configurado para este app.';

  @override
  String get progressSyncErrorProviderDisabled =>
      'Esse método de login ainda não está ativado no Firebase.';

  @override
  String get progressSyncErrorAccountExists =>
      'Essa conta já existe. Entre com ela para puxar o progresso salvo.';

  @override
  String get progressSyncErrorNetwork =>
      'Confira sua internet e tente sincronizar novamente.';

  @override
  String get progressSyncCanceled => 'Login cancelado.';

  @override
  String get progressRoutineSection => 'Rotina';

  @override
  String get progressLearningSection => 'Aprendizado';

  @override
  String get progressGamesSection => 'Partidas';

  @override
  String get progressCurrentStreak => 'Ofensiva atual';

  @override
  String get progressBestStreak => 'Melhor ofensiva';

  @override
  String get progressActiveDays => 'Dias ativos';

  @override
  String get progressGuidedLessons => 'Lições concluídas';

  @override
  String get progressObjectiveStars => 'Estrelas em objetivos';

  @override
  String get progressObjectiveChallenges => 'Objetivos concluídos';

  @override
  String get progressTotalGames => 'Partidas jogadas';

  @override
  String get progressBotGames => 'Contra bot';

  @override
  String get progressBotWins => 'Vitórias vs bot';

  @override
  String get progressBotAdvancedWins => 'Vitórias avançado';

  @override
  String get progressLocalGames => '2 jogadores local';

  @override
  String get progressLocalWins => 'Vitórias locais';

  @override
  String progressBotSummary(int wins, int advancedWins) {
    return '$wins vitórias • $advancedWins no avançado';
  }

  @override
  String progressLocalSummary(int draws) {
    return 'No mesmo celular • $draws empates';
  }

  @override
  String get faqComingSoon => 'A central de ajuda será adicionada em breve.';

  @override
  String get faqPageTitle => 'Central de ajuda';

  @override
  String get faqHeroTitle => 'Como podemos ajudar?';

  @override
  String get faqPageSubtitle =>
      'Respostas rápidas sobre o jogo, sua conta e compras.';

  @override
  String get faqGeneralSection => 'Jogo e versões';

  @override
  String get faqPurchasesSection => 'Compras e pagamentos';

  @override
  String get faqAccountSection => 'Conta, aparelhos e atualizações';

  @override
  String get faqFreeProQuestion => 'Qual é a diferença entre FREE e PRO?';

  @override
  String get faqFreeProAnswer =>
      'A versão FREE dá acesso a todos os mundos e fases seguindo a progressão normal, com anúncios em intervalos controlados. A versão PRO remove os anúncios permanentemente; ela não pula nem desbloqueia fases.';

  @override
  String get faqInternetQuestion => 'Preciso de internet para jogar?';

  @override
  String get faqInternetAnswer =>
      'As fases podem ser jogadas offline. A internet é necessária apenas para entrar na conta, sincronizar dados, comprar ou restaurar o PRO e carregar anúncios.';

  @override
  String get faqAdsQuestion => 'Quando os anúncios aparecem?';

  @override
  String get faqAdsAnswer =>
      'Anúncios aparecem somente na versão FREE e em pausas naturais entre algumas fases. Eles nunca interrompem uma jogada. Se um anúncio não carregar, o jogo continua normalmente.';

  @override
  String get faqLifetimeQuestion => 'A compra do PRO é mensal?';

  @override
  String get faqLifetimeAnswer =>
      'Não. O PRO é uma compra única e vitalícia, sem assinatura ou cobrança recorrente. O preço e a moeda são informados pela Google Play ou App Store antes da confirmação.';

  @override
  String get faqRestoreQuestion => 'O que significa restaurar compra?';

  @override
  String get faqRestoreAnswer =>
      'Restaurar compra consulta a Google Play ou App Store para recuperar um PRO que você já comprou. Isso não gera uma nova cobrança e não solicita reembolso.';

  @override
  String get faqRefundQuestion => 'Como funciona o reembolso?';

  @override
  String get faqRefundAnswer =>
      'Pedidos de reembolso são solicitados e analisados pela Google Play ou App Store. Quando a loja aprova e devolve o valor conforme as regras dela, o acesso PRO relacionado à compra pode ser removido.';

  @override
  String get faqAccountQuestion => 'Por que usar uma conta no app?';

  @override
  String get faqAccountAnswer =>
      'A conta protege e sincroniza seu acesso PRO entre aparelhos. O direito é vinculado ao identificador interno seguro da sua conta, e não depende do seu e-mail permanecer igual ou visível.';

  @override
  String get faqNewDeviceQuestion =>
      'Troquei de celular ou reinstalei o app. E agora?';

  @override
  String get faqNewDeviceAnswer =>
      'Entre com a mesma conta usada anteriormente. O app sincronizará seu acesso PRO; se necessário, use Restaurar compra com a mesma conta da loja que fez o pagamento.';

  @override
  String get faqCrossPlatformQuestion =>
      'O PRO funciona no Android e no iPhone?';

  @override
  String get faqCrossPlatformAnswer =>
      'Sim, quando a compra validada estiver vinculada à mesma conta do app. Sem essa vinculação, cada loja restaura compras apenas dentro do próprio sistema.';

  @override
  String get faqUpdatesQuestion => 'O app pode exigir uma atualização?';

  @override
  String get faqUpdatesAnswer =>
      'Atualizações normais ficam disponíveis pela loja. Se uma versão for indispensável para segurança ou compatibilidade, o app poderá pedir uma atualização obrigatória antes de continuar.';

  @override
  String get faqFooterMessage =>
      'Compras e reembolsos sempre são processados pela loja oficial do seu aparelho. O app nunca solicita seus dados bancários diretamente.';

  @override
  String get premiumSheetTitle => 'Chess Chalenges PRO';

  @override
  String get premiumActiveTitle => 'Sua versão PRO está ativa';

  @override
  String get premiumDescription => 'Uma compra única para jogar sem anúncios.';

  @override
  String get premiumAfterAdTitle => 'Cansou dos anúncios?';

  @override
  String get premiumAfterAdDescription =>
      'Vire PRO uma vez e remova todos os anúncios entre fases para sempre.';

  @override
  String get premiumActiveDescription =>
      'Obrigado por apoiar o jogo. Você não verá anúncios entre as fases.';

  @override
  String get premiumBenefitNoAds => 'Sem anúncios entre as fases';

  @override
  String get premiumBenefitLifetime => 'Acesso vitalício, sem assinatura';

  @override
  String get premiumBenefitSameProgress => 'Mantém todo o seu progresso atual';

  @override
  String get premiumPriceLoading => 'Consultando preço...';

  @override
  String premiumBuyAction(String price) {
    return 'Liberar PRO • $price';
  }

  @override
  String get premiumPendingAction => 'Aguardando a loja...';

  @override
  String get premiumRestoreAction => 'Restaurar compra';

  @override
  String get premiumStoreUnavailable =>
      'A loja não está disponível agora. Confira a internet e tente novamente.';

  @override
  String get premiumProductUnavailable =>
      'A versão PRO ainda não foi configurada nesta loja.';

  @override
  String get premiumPurchaseFailed =>
      'Não foi possível concluir a compra. Tente novamente em instantes.';

  @override
  String get privacyOptionsAction => 'Opções de privacidade dos anúncios';

  @override
  String get splashLoadingLabel => 'Preparando seus desafios...';

  @override
  String get splashLoadError => 'Não foi possível preparar o jogo.';

  @override
  String get splashRetryAction => 'Tentar novamente';

  @override
  String get forceUpdateTitle => 'Atualização necessária';

  @override
  String get forceUpdateDefaultMessage =>
      'Esta versão precisa ser atualizada para continuar funcionando corretamente.';

  @override
  String get forceUpdateAction => 'Atualizar agora';

  @override
  String get forceUpdateStoreError =>
      'Não foi possível abrir a loja. Tente novamente em instantes.';

  @override
  String get homeChooseModeTitle => 'Como quer jogar hoje?';

  @override
  String get homeChooseModeSubtitle =>
      'Escolha um modo para treinar, jogar ou se preparar para os próximos desafios.';

  @override
  String get homePlayAction => 'Jogar';

  @override
  String get homeComingSoonAction => 'Em breve';

  @override
  String get homeGuidedLessonsTitle => 'Lições guiadas';

  @override
  String get homeGuidedLessonsDescription =>
      'Continue a campanha atual com fases explicadas, dicas e progressão por mundos.';

  @override
  String get homeObjectiveModeTitle => 'Desafios por objetivo';

  @override
  String get homeObjectiveModeDescription =>
      'Resolva situações livres, busque até 3 estrelas e vença com menos jogadas.';

  @override
  String get objectiveChallengesTitle => 'Desafios por objetivo';

  @override
  String get objectiveChallengesHeroTitle => 'Busque 3 estrelas';

  @override
  String get objectiveChallengesHeroSubtitle => 'com menos jogadas possíveis';

  @override
  String objectiveChallengesLevelCount(int count) {
    return '$count desafios';
  }

  @override
  String objectiveChallengesProgress(int earned, int total) {
    return '$earned/$total';
  }

  @override
  String get objectiveChallengesFutureLevelsNote =>
      'Novas fases serão liberadas no futuro.';

  @override
  String objectiveChallengeLevelSemantics(int level) {
    return 'Desafio $level';
  }

  @override
  String get homeVsBotModeTitle => 'Contra bot';

  @override
  String get homeVsBotModeDescription =>
      'Jogue partidas contra bot fácil, médio ou avançado quando quiser treinar livre.';

  @override
  String get homeLocalPlayersModeTitle => '2 Jogadores local';

  @override
  String get homeLocalPlayersModeDescription =>
      'Use o celular como tabuleiro para jogar com outra pessoa no mesmo aparelho.';

  @override
  String get localGameTitle => '2 Jogadores local';

  @override
  String get localGameSubtitle =>
      'Um tabuleiro compartilhado para jogar no mesmo celular.';

  @override
  String get localGameWhiteSide => 'Brancas';

  @override
  String get localGameBlackSide => 'Pretas';

  @override
  String localGameTurnTitle(String side) {
    return 'Vez: $side';
  }

  @override
  String get localGameCheckTitle => 'XEQUE!';

  @override
  String localGameCheckTurnDescription(String side) {
    return '$side precisam defender o rei.';
  }

  @override
  String get localGameCheckWarning => 'Xeque no rei. Encontre uma defesa.';

  @override
  String get localGameCheckmateTitle => 'Xeque-mate';

  @override
  String get localGameDrawTitle => 'Empate';

  @override
  String get localGameDrawDescription =>
      'Ninguém venceu esta partida. Reinicie para jogar outra.';

  @override
  String localGameWinnerLabel(String side) {
    return '$side venceram.';
  }

  @override
  String get localGameReadyMessage =>
      'Toque uma peça da vez, faça o lance e passe o celular.';

  @override
  String localGameMovesCount(int count) {
    return 'Lances: $count';
  }

  @override
  String localGameActivityPending(int remaining) {
    return 'Faltam $remaining lances pra ofensiva';
  }

  @override
  String get localGameActivityDone => 'Ofensiva do dia garantida';

  @override
  String get localGameRestartButton => 'Reiniciar';

  @override
  String get localGameResetAction => 'Reiniciar partida';

  @override
  String get localGameFlipBoardAction => 'Virar tabuleiro';

  @override
  String get localGameResetDialogTitle => 'Reiniciar partida?';

  @override
  String get localGameResetDialogMessage =>
      'A partida atual será apagada e o tabuleiro volta para o início.';

  @override
  String get localGameResetCancelAction => 'Cancelar';

  @override
  String get localGameResetConfirmAction => 'Reiniciar';

  @override
  String get showLastMoveAction => 'Ver último lance';

  @override
  String get promotionChoiceTitle => 'Promover peão';

  @override
  String get promotionChoiceSubtitle =>
      'Escolha qual peça esse peão vai virar.';

  @override
  String get promotionQueen => 'Dama';

  @override
  String get promotionRook => 'Torre';

  @override
  String get promotionBishop => 'Bispo';

  @override
  String get promotionKnight => 'Cavalo';

  @override
  String get botGameTitle => 'Contra bot';

  @override
  String get botGameChooseDifficultyTitle => 'Escolha o nível do bot';

  @override
  String get botGameChooseDifficultySubtitle =>
      'Você joga de brancas. O bot responde de pretas conforme o nível escolhido.';

  @override
  String get botDifficultyBeginnerTitle => 'Iniciante';

  @override
  String get botDifficultyBeginnerDescription =>
      'Joga lances legais, mas ainda erra e deixa chances abertas.';

  @override
  String get botDifficultyIntermediateTitle => 'Intermediário';

  @override
  String get botDifficultyIntermediateDescription =>
      'Procura capturas, xeques e evita peças penduradas.';

  @override
  String get botDifficultyAdvancedTitle => 'Avançado';

  @override
  String get botDifficultyAdvancedDescription =>
      'Calcula uma resposta à frente antes de escolher a jogada.';

  @override
  String get botGameStartAction => 'Começar';

  @override
  String get botGameYourTurnTitle => 'Sua vez';

  @override
  String get botGameThinkingTitle => 'Bot pensando...';

  @override
  String get botGameThinkingDescription =>
      'Ele está procurando uma resposta. Já já joga.';

  @override
  String get botGameReadyDescription =>
      'Você joga de brancas. Toque uma peça e faça seu lance.';

  @override
  String get botGamePlayerInCheckDescription =>
      'Seu rei está em xeque. Defenda agora.';

  @override
  String get botGameBotInCheckDescription =>
      'Você colocou o bot em xeque. Ele precisa responder.';

  @override
  String get botGameYouWonTitle => 'Você venceu';

  @override
  String get botGameYouWonDescription => 'Xeque-mate no bot. Boa!';

  @override
  String get botGameBotWonTitle => 'Bot venceu';

  @override
  String get botGameBotWonDescription =>
      'O bot fechou o xeque-mate. Reinicie para tentar de novo.';

  @override
  String get botGameDrawTitle => 'Empate';

  @override
  String get botGameDrawDescription =>
      'A partida terminou sem vencedor. Reinicie para jogar outra.';

  @override
  String campaignLoadError(String error) {
    return 'Não foi possível carregar a campanha: $error';
  }

  @override
  String worldLabel(int world) {
    return 'Mundo $world';
  }

  @override
  String worldSummary(int levels, int xp) {
    return 'Mate e fundamentos • $levels fases • $xp XP';
  }

  @override
  String worldXp(int earned, int total) {
    return 'XP do mundo: $earned/$total';
  }

  @override
  String offensiveCount(int count) {
    return 'Ofensiva $count';
  }

  @override
  String get nextWorldUnlockedMessage =>
      'Mundo 2 liberado. Vamos conectar os puzzles dele em seguida.';

  @override
  String get completeWorldToUnlockMessage =>
      'Complete todas as fases deste mundo para liberar o próximo.';

  @override
  String get completeCurrentLevelToUnlockMessage =>
      'Complete a fase atual para desbloquear.';

  @override
  String levelLabel(int level) {
    return 'Fase $level';
  }

  @override
  String lockedLevelTitle(int level) {
    return 'Fase $level bloqueada';
  }

  @override
  String get lockedLevelAction => 'Fase bloqueada';

  @override
  String get completePreviousLevelsToUnlock =>
      'Complete as fases anteriores para liberar esta fase.';

  @override
  String get comingSoon => 'Em breve';

  @override
  String reviewLevelTitle(int level) {
    return 'Revisar fase $level';
  }

  @override
  String get reviewLevelAction => 'Revisar fase';

  @override
  String startWithXp(int xp) {
    return 'Começar +$xp XP';
  }

  @override
  String get xpAlreadyCollectedDescription =>
      'O XP dessa fase já foi coletado.';

  @override
  String get completeToAddXpDescription => 'Complete para somar XP ao mundo.';

  @override
  String worldTheme(int world, String theme) {
    return 'Mundo $world • $theme';
  }

  @override
  String levelProgress(int current, int total) {
    return 'Fase $current/$total';
  }

  @override
  String get xpCollected => 'XP coletado';

  @override
  String xpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String goToWorld(int world) {
    return 'Ir para o Mundo $world';
  }

  @override
  String get nextWorld => 'Próximo mundo';

  @override
  String get newChallengesUnlocked => 'Novo conjunto de desafios liberado.';

  @override
  String completeLevelsToUnlock(int completed, int total) {
    return 'Complete $completed/$total fases para liberar.';
  }

  @override
  String puzzlesLoadError(String error) {
    return 'Não foi possível carregar os puzzles: $error';
  }

  @override
  String get backTooltip => 'Voltar';

  @override
  String get hintTooltip => 'Dica';

  @override
  String get hintUsedTooltip => 'Dica já usada neste lance';

  @override
  String puzzleMeta(int world, int chapter, int level) {
    return 'Mundo $world • Capítulo $chapter • Fase $level';
  }

  @override
  String get wrongMoveTitle => 'Lance errado';

  @override
  String get moveNotPlayed => 'Esse lance não entrou no tabuleiro.';

  @override
  String get retryMove => 'Tentar lance de novo';

  @override
  String get restartLevel => 'Recomeçar fase';

  @override
  String get perfectTitle => 'Perfeito';

  @override
  String get reviewCompletedTitle => 'Revisão concluída';

  @override
  String levelCompletedWithXp(int level, int xp) {
    return 'Fase $level concluída. +$xp XP';
  }

  @override
  String levelReviewedXpCollected(int level) {
    return 'Fase $level revisada. XP já coletado.';
  }

  @override
  String get continueButton => 'Continuar';

  @override
  String get hintButton => 'Dica';

  @override
  String get solutionButton => 'Solução';

  @override
  String get mapButton => 'Mapa';

  @override
  String get restartButton => 'Reiniciar';

  @override
  String get resetButton => 'Resetar';

  @override
  String get puzzleMessageFindBestMove => 'Encontre a melhor jogada.';

  @override
  String get puzzleMessageHintMate001 =>
      'A dama precisa fechar a última casa do rei.';

  @override
  String get puzzleMessageHintSequence002 => 'Comece ocupando o centro.';

  @override
  String get puzzleMessageHintSequence003 =>
      'Desenvolva com ganho de tempo e pressione o centro.';

  @override
  String get puzzleMessageLookHighlightedPiece => 'Observe a peça destacada.';

  @override
  String puzzleMessageSolution(String solution) {
    return 'Solução: $solution';
  }

  @override
  String get puzzleMessageTryMoveAgain => 'Tente esse lance de novo.';

  @override
  String get puzzleMessageChooseRightSquare => 'Escolha a casa certa.';

  @override
  String get puzzleMessageTapPiece => 'Toque em uma peça para jogar.';

  @override
  String get puzzleMessageWrongMove =>
      'Lance errado. Escolha como quer continuar.';

  @override
  String get puzzleMessageInconsistent =>
      'Esse puzzle está inconsistente. Vamos corrigir a base.';

  @override
  String get puzzleMessageInvalidOpponentReply =>
      'Resposta automática inválida na base do puzzle.';

  @override
  String get puzzleMessageCompleted => 'Perfeito. Fase concluída.';

  @override
  String get puzzleMessageOpponentReplied => 'Boa. O adversário respondeu.';

  @override
  String get puzzleMessageContinueSequence => 'Boa. Continue a sequência.';

  @override
  String get themeMateIn1 => 'Mate em 1';

  @override
  String get themeDevelopment => 'Desenvolvimento';

  @override
  String get themeOpeningPattern => 'Padrão de abertura';

  @override
  String get themeFundamentals => 'Fundamentos';

  @override
  String get themeMaterial => 'Capturas e trocas';

  @override
  String get themeFork => 'Garfos';

  @override
  String get themePin => 'Cravadas';

  @override
  String get themeDiscoveredAttack => 'Ataques descobertos';

  @override
  String get themeDefense => 'Defesa e contra-ataque';

  @override
  String get themeEndgame => 'Finais essenciais';

  @override
  String get themeCombination => 'Combinações táticas';

  @override
  String get themeMastery => 'Mestre do tabuleiro';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Médio';

  @override
  String get difficultyAdvanced => 'Avançado';

  @override
  String get themeComingSoon => 'Em breve';
}
