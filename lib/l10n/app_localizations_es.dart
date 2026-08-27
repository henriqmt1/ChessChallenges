// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Chess Chalenges';

  @override
  String get darkModeTooltip => 'Activar modo oscuro';

  @override
  String get lightModeTooltip => 'Activar modo claro';

  @override
  String get faqTooltip => 'Ayuda y preguntas frecuentes';

  @override
  String get progressTooltip => 'Ver progreso y estadísticas';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get progressSubtitle => 'Tu resumen en Chess Chalenges.';

  @override
  String get progressHeroTitle => 'Tu evolución';

  @override
  String get progressHeroSubtitle =>
      'Las estadísticas se guardan localmente y se sincronizan cuando hay internet.';

  @override
  String get progressSynced => 'Sincronizado';

  @override
  String get progressLocalOnly => 'Guardado en el dispositivo';

  @override
  String get progressSyncSection => 'Sincronización';

  @override
  String get progressSyncGuestTitle => 'Protege tu progreso';

  @override
  String get progressSyncGuestDescription =>
      'Inicia sesión con Google o Apple para recuperar tus estadísticas y niveles en otro dispositivo.';

  @override
  String get progressSyncConnectedTitle => 'Progreso protegido';

  @override
  String progressSyncConnectedDescription(String account) {
    return 'Conectado como $account. Tus datos se sincronizarán cuando haya internet.';
  }

  @override
  String get progressSyncConnectedFallback => 'tu cuenta';

  @override
  String get progressSyncGuestBadge => 'Visitante';

  @override
  String get progressSyncConnectedBadge => 'Cuenta conectada';

  @override
  String get progressSyncGoogleAction => 'Entrar con Google';

  @override
  String get progressSyncAppleAction => 'Entrar con Apple';

  @override
  String get progressSyncNowAction => 'Sincronizar ahora';

  @override
  String get progressSyncErrorGeneric =>
      'No se pudo sincronizar ahora. Inténtalo de nuevo en unos instantes.';

  @override
  String get progressSyncErrorFirebase =>
      'Firebase aún no está disponible en este entorno.';

  @override
  String get progressSyncErrorGoogleConfig =>
      'El login con Google aún debe configurarse en Firebase para esta app.';

  @override
  String get progressSyncErrorAppleConfig =>
      'El login con Apple aún debe configurarse para esta app.';

  @override
  String get progressSyncErrorProviderDisabled =>
      'Este método de login aún no está activado en Firebase.';

  @override
  String get progressSyncErrorAccountExists =>
      'Esta cuenta ya existe. Entra con ella para cargar el progreso guardado.';

  @override
  String get progressSyncErrorNetwork =>
      'Revisa tu internet e intenta sincronizar nuevamente.';

  @override
  String get progressSyncCanceled => 'Login cancelado.';

  @override
  String get progressRoutineSection => 'Rutina';

  @override
  String get progressLearningSection => 'Aprendizaje';

  @override
  String get progressGamesSection => 'Partidas';

  @override
  String get progressCurrentStreak => 'Racha actual';

  @override
  String get progressBestStreak => 'Mejor racha';

  @override
  String get progressActiveDays => 'Días activos';

  @override
  String get progressGuidedLessons => 'Lecciones completadas';

  @override
  String get progressObjectiveStars => 'Estrellas de objetivos';

  @override
  String get progressObjectiveChallenges => 'Objetivos completados';

  @override
  String get progressTotalGames => 'Partidas jugadas';

  @override
  String get progressBotGames => 'Contra bot';

  @override
  String get progressBotWins => 'Victorias vs bot';

  @override
  String get progressBotAdvancedWins => 'Victorias avanzado';

  @override
  String get progressLocalGames => '2 jugadores local';

  @override
  String get progressLocalWins => 'Victorias locales';

  @override
  String progressBotSummary(int wins, int advancedWins) {
    return '$wins victorias • $advancedWins en avanzado';
  }

  @override
  String progressLocalSummary(int draws) {
    return 'En el mismo celular • $draws empates';
  }

  @override
  String get faqComingSoon => 'El centro de ayuda se agregará pronto.';

  @override
  String get faqPageTitle => 'Centro de ayuda';

  @override
  String get faqHeroTitle => '¿Cómo podemos ayudarte?';

  @override
  String get faqPageSubtitle =>
      'Respuestas rápidas sobre el juego, tu cuenta y las compras.';

  @override
  String get faqGeneralSection => 'Juego y versiones';

  @override
  String get faqPurchasesSection => 'Compras y pagos';

  @override
  String get faqAccountSection => 'Cuenta, dispositivos y actualizaciones';

  @override
  String get faqFreeProQuestion => '¿Cuál es la diferencia entre FREE y PRO?';

  @override
  String get faqFreeProAnswer =>
      'La versión FREE da acceso a todos los mundos y niveles mediante la progresión normal, con anuncios en intervalos controlados. PRO elimina los anuncios permanentemente; no salta ni desbloquea niveles.';

  @override
  String get faqInternetQuestion => '¿Necesito internet para jugar?';

  @override
  String get faqInternetAnswer =>
      'Los niveles se pueden jugar sin conexión. Internet solo es necesario para iniciar sesión, sincronizar datos, comprar o restaurar PRO y cargar anuncios.';

  @override
  String get faqAdsQuestion => '¿Cuándo aparecen los anuncios?';

  @override
  String get faqAdsAnswer =>
      'Los anuncios solo aparecen en la versión FREE durante pausas naturales entre algunos niveles. Nunca interrumpen una jugada. Si un anuncio no carga, el juego continúa normalmente.';

  @override
  String get faqLifetimeQuestion => '¿La compra de PRO es mensual?';

  @override
  String get faqLifetimeAnswer =>
      'No. PRO es una compra única y vitalicia, sin suscripción ni cobros recurrentes. Google Play o App Store muestra el precio y la moneda antes de confirmar.';

  @override
  String get faqRestoreQuestion => '¿Qué significa restaurar compra?';

  @override
  String get faqRestoreAnswer =>
      'Restaurar compra consulta a Google Play o App Store para recuperar una compra PRO que ya realizaste. No genera un nuevo cobro ni solicita un reembolso.';

  @override
  String get faqRefundQuestion => '¿Cómo funcionan los reembolsos?';

  @override
  String get faqRefundAnswer =>
      'Las solicitudes de reembolso se envían y son revisadas por Google Play o App Store. Cuando la tienda las aprueba y devuelve el pago según sus reglas, el acceso PRO relacionado puede ser retirado.';

  @override
  String get faqAccountQuestion => '¿Por qué usar una cuenta en la aplicación?';

  @override
  String get faqAccountAnswer =>
      'Tu cuenta protege y sincroniza el acceso PRO entre dispositivos. El derecho se vincula al identificador interno seguro de tu cuenta y no depende de que tu correo permanezca igual o visible.';

  @override
  String get faqNewDeviceQuestion =>
      'Cambié de teléfono o reinstalé la aplicación. ¿Qué hago?';

  @override
  String get faqNewDeviceAnswer =>
      'Inicia sesión con la misma cuenta que usaste antes. La aplicación sincronizará tu acceso PRO; si es necesario, usa Restaurar compra con la misma cuenta de la tienda que realizó el pago.';

  @override
  String get faqCrossPlatformQuestion => '¿PRO funciona en Android y iPhone?';

  @override
  String get faqCrossPlatformAnswer =>
      'Sí, cuando la compra verificada está vinculada a la misma cuenta de la aplicación. Sin ese vínculo, cada tienda solo puede restaurar compras dentro de su propio sistema.';

  @override
  String get faqUpdatesQuestion =>
      '¿La aplicación puede exigir una actualización?';

  @override
  String get faqUpdatesAnswer =>
      'Las actualizaciones normales están disponibles en la tienda. Si una versión es indispensable por seguridad o compatibilidad, la aplicación puede exigir una actualización antes de continuar.';

  @override
  String get faqFooterMessage =>
      'Las compras y los reembolsos siempre son procesados por la tienda oficial de tu dispositivo. La aplicación nunca solicita directamente tus datos bancarios.';

  @override
  String get premiumSheetTitle => 'Chess Chalenges PRO';

  @override
  String get premiumActiveTitle => 'Tu versión PRO está activa';

  @override
  String get premiumDescription => 'Una compra única para jugar sin anuncios.';

  @override
  String get premiumAfterAdTitle => '¿Te cansaste de los anuncios?';

  @override
  String get premiumAfterAdDescription =>
      'Pásate a PRO una vez y elimina todos los anuncios entre niveles para siempre.';

  @override
  String get premiumActiveDescription =>
      'Gracias por apoyar el juego. No verás anuncios entre los niveles.';

  @override
  String get premiumBenefitNoAds => 'Sin anuncios entre niveles';

  @override
  String get premiumBenefitLifetime => 'Acceso de por vida, sin suscripción';

  @override
  String get premiumBenefitSameProgress => 'Conserva todo tu progreso actual';

  @override
  String get premiumPriceLoading => 'Consultando precio...';

  @override
  String premiumBuyAction(String price) {
    return 'Desbloquear PRO • $price';
  }

  @override
  String get premiumPendingAction => 'Esperando a la tienda...';

  @override
  String get premiumRestoreAction => 'Restaurar compra';

  @override
  String get premiumStoreUnavailable =>
      'La tienda no está disponible ahora. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get premiumProductUnavailable =>
      'La versión PRO aún no está configurada en esta tienda.';

  @override
  String get premiumPurchaseFailed =>
      'No se pudo completar la compra. Inténtalo de nuevo en unos instantes.';

  @override
  String get privacyOptionsAction => 'Opciones de privacidad de anuncios';

  @override
  String get splashLoadingLabel => 'Preparando tus desafíos...';

  @override
  String get splashLoadError => 'No se pudo preparar el juego.';

  @override
  String get splashRetryAction => 'Intentar de nuevo';

  @override
  String get forceUpdateTitle => 'Actualización necesaria';

  @override
  String get forceUpdateDefaultMessage =>
      'Esta versión debe actualizarse para seguir funcionando correctamente.';

  @override
  String get forceUpdateAction => 'Actualizar ahora';

  @override
  String get forceUpdateStoreError =>
      'No se pudo abrir la tienda. Inténtalo de nuevo en unos instantes.';

  @override
  String get homeChooseModeTitle => '¿Cómo quieres jugar hoy?';

  @override
  String get homeChooseModeSubtitle =>
      'Elige un modo para entrenar, jugar o prepararte para los próximos desafíos.';

  @override
  String get homePlayAction => 'Jugar';

  @override
  String get homeComingSoonAction => 'Próximamente';

  @override
  String get homeGuidedLessonsTitle => 'Lecciones guiadas';

  @override
  String get homeGuidedLessonsDescription =>
      'Continúa la campaña actual con niveles explicados, pistas y progresión por mundos.';

  @override
  String get homeObjectiveModeTitle => 'Desafíos por objetivo';

  @override
  String get homeObjectiveModeDescription =>
      'Resuelve situaciones libres, consigue hasta 3 estrellas y gana con menos jugadas.';

  @override
  String get objectiveChallengesTitle => 'Desafíos por objetivo';

  @override
  String get objectiveChallengesHeroTitle => 'Consigue 3 estrellas';

  @override
  String get objectiveChallengesHeroSubtitle =>
      'con la menor cantidad de jugadas';

  @override
  String objectiveChallengesLevelCount(int count) {
    return '$count desafíos';
  }

  @override
  String objectiveChallengesProgress(int earned, int total) {
    return '$earned/$total';
  }

  @override
  String get objectiveChallengesFutureLevelsNote =>
      'Nuevas fases se liberarán en el futuro.';

  @override
  String objectiveChallengeLevelSemantics(int level) {
    return 'Desafío $level';
  }

  @override
  String get homeVsBotModeTitle => 'Contra bot';

  @override
  String get homeVsBotModeDescription =>
      'Juega partidas contra bots fácil, medio o avanzado cuando quieras practicar libremente.';

  @override
  String get homeLocalPlayersModeTitle => '2 jugadores local';

  @override
  String get homeLocalPlayersModeDescription =>
      'Usa el móvil como tablero para jugar con otra persona en el mismo dispositivo.';

  @override
  String get localGameTitle => '2 jugadores local';

  @override
  String get localGameSubtitle =>
      'Un tablero compartido para jugar en el mismo móvil.';

  @override
  String get localGameWhiteSide => 'Blancas';

  @override
  String get localGameBlackSide => 'Negras';

  @override
  String localGameTurnTitle(String side) {
    return 'Turno: $side';
  }

  @override
  String get localGameCheckTitle => '¡JAQUE!';

  @override
  String localGameCheckTurnDescription(String side) {
    return '$side deben defender al rey.';
  }

  @override
  String get localGameCheckWarning => 'Rey en jaque. Encuentra una defensa.';

  @override
  String get localGameCheckmateTitle => 'Jaque mate';

  @override
  String get localGameDrawTitle => 'Empate';

  @override
  String get localGameDrawDescription =>
      'Nadie ganó esta partida. Reinicia para jugar otra.';

  @override
  String localGameWinnerLabel(String side) {
    return '$side ganan.';
  }

  @override
  String get localGameReadyMessage =>
      'Toca una pieza del turno, juega y pasa el móvil.';

  @override
  String localGameMovesCount(int count) {
    return 'Jugadas: $count';
  }

  @override
  String localGameActivityPending(int remaining) {
    return 'Faltan $remaining jugadas para la racha';
  }

  @override
  String get localGameActivityDone => 'Racha de hoy asegurada';

  @override
  String get localGameRestartButton => 'Reiniciar';

  @override
  String get localGameResetAction => 'Reiniciar partida';

  @override
  String get localGameFlipBoardAction => 'Girar tablero';

  @override
  String get localGameResetDialogTitle => '¿Reiniciar partida?';

  @override
  String get localGameResetDialogMessage =>
      'La partida actual se borrará y el tablero volverá al inicio.';

  @override
  String get localGameResetCancelAction => 'Cancelar';

  @override
  String get localGameResetConfirmAction => 'Reiniciar';

  @override
  String get showLastMoveAction => 'Ver última jugada';

  @override
  String get promotionChoiceTitle => 'Promover peón';

  @override
  String get promotionChoiceSubtitle =>
      'Elige en qué pieza se convertirá este peón.';

  @override
  String get promotionQueen => 'Dama';

  @override
  String get promotionRook => 'Torre';

  @override
  String get promotionBishop => 'Alfil';

  @override
  String get promotionKnight => 'Caballo';

  @override
  String get botGameTitle => 'Contra bot';

  @override
  String get botGameChooseDifficultyTitle => 'Elige el nivel del bot';

  @override
  String get botGameChooseDifficultySubtitle =>
      'Juegas con blancas. El bot responde con negras según el nivel elegido.';

  @override
  String get botDifficultyBeginnerTitle => 'Principiante';

  @override
  String get botDifficultyBeginnerDescription =>
      'Hace jugadas legales, pero todavía se equivoca y deja oportunidades abiertas.';

  @override
  String get botDifficultyIntermediateTitle => 'Intermedio';

  @override
  String get botDifficultyIntermediateDescription =>
      'Busca capturas, jaques y evita piezas colgadas.';

  @override
  String get botDifficultyAdvancedTitle => 'Avanzado';

  @override
  String get botDifficultyAdvancedDescription =>
      'Calcula una respuesta por delante antes de elegir la jugada.';

  @override
  String get botGameStartAction => 'Empezar';

  @override
  String get botGameYourTurnTitle => 'Tu turno';

  @override
  String get botGameThinkingTitle => 'Bot pensando...';

  @override
  String get botGameThinkingDescription =>
      'Está buscando una respuesta. Jugará enseguida.';

  @override
  String get botGameReadyDescription =>
      'Juegas con blancas. Toca una pieza y haz tu jugada.';

  @override
  String get botGamePlayerInCheckDescription =>
      'Tu rey está en jaque. Defiende ahora.';

  @override
  String get botGameBotInCheckDescription =>
      'Pusiste al bot en jaque. Tiene que responder.';

  @override
  String get botGameYouWonTitle => 'Ganaste';

  @override
  String get botGameYouWonDescription => 'Jaque mate al bot. ¡Bien!';

  @override
  String get botGameBotWonTitle => 'Ganó el bot';

  @override
  String get botGameBotWonDescription =>
      'El bot cerró el jaque mate. Reinicia para intentarlo de nuevo.';

  @override
  String get botGameDrawTitle => 'Tablas';

  @override
  String get botGameDrawDescription =>
      'La partida terminó sin ganador. Reinicia para jugar otra.';

  @override
  String campaignLoadError(String error) {
    return 'No fue posible cargar la campaña: $error';
  }

  @override
  String worldLabel(int world) {
    return 'Mundo $world';
  }

  @override
  String worldSummary(int levels, int xp) {
    return 'Mates y fundamentos • $levels niveles • $xp XP';
  }

  @override
  String worldXp(int earned, int total) {
    return 'XP del mundo: $earned/$total';
  }

  @override
  String offensiveCount(int count) {
    return 'Racha $count';
  }

  @override
  String get nextWorldUnlockedMessage =>
      'Mundo 2 desbloqueado. Sus puzzles se conectarán a continuación.';

  @override
  String get completeWorldToUnlockMessage =>
      'Completa todos los niveles de este mundo para desbloquear el siguiente.';

  @override
  String get completeCurrentLevelToUnlockMessage =>
      'Completa el nivel actual para desbloquear este.';

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String lockedLevelTitle(int level) {
    return 'Nivel $level bloqueado';
  }

  @override
  String get lockedLevelAction => 'Nivel bloqueado';

  @override
  String get completePreviousLevelsToUnlock =>
      'Completa los niveles anteriores para desbloquear este.';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String reviewLevelTitle(int level) {
    return 'Repasar nivel $level';
  }

  @override
  String get reviewLevelAction => 'Repasar nivel';

  @override
  String startWithXp(int xp) {
    return 'Empezar +$xp XP';
  }

  @override
  String get xpAlreadyCollectedDescription =>
      'El XP de este nivel ya fue obtenido.';

  @override
  String get completeToAddXpDescription => 'Complétalo para sumar XP al mundo.';

  @override
  String worldTheme(int world, String theme) {
    return 'Mundo $world • $theme';
  }

  @override
  String levelProgress(int current, int total) {
    return 'Nivel $current/$total';
  }

  @override
  String get xpCollected => 'XP obtenido';

  @override
  String xpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String goToWorld(int world) {
    return 'Ir al Mundo $world';
  }

  @override
  String get nextWorld => 'Siguiente mundo';

  @override
  String get newChallengesUnlocked =>
      'Se desbloqueó un nuevo conjunto de desafíos.';

  @override
  String completeLevelsToUnlock(int completed, int total) {
    return 'Completa $completed/$total niveles para desbloquear.';
  }

  @override
  String puzzlesLoadError(String error) {
    return 'No fue posible cargar los puzzles: $error';
  }

  @override
  String get backTooltip => 'Volver';

  @override
  String get hintTooltip => 'Pista';

  @override
  String get hintUsedTooltip => 'Pista ya utilizada en esta jugada';

  @override
  String puzzleMeta(int world, int chapter, int level) {
    return 'Mundo $world • Capítulo $chapter • Nivel $level';
  }

  @override
  String get wrongMoveTitle => 'Jugada incorrecta';

  @override
  String get moveNotPlayed => 'Esa jugada no se realizó en el tablero.';

  @override
  String get retryMove => 'Intentar la jugada de nuevo';

  @override
  String get restartLevel => 'Reiniciar nivel';

  @override
  String get perfectTitle => 'Perfecto';

  @override
  String get reviewCompletedTitle => 'Repaso completado';

  @override
  String levelCompletedWithXp(int level, int xp) {
    return 'Nivel $level completado. +$xp XP';
  }

  @override
  String levelReviewedXpCollected(int level) {
    return 'Nivel $level repasado. XP ya obtenido.';
  }

  @override
  String get continueButton => 'Continuar';

  @override
  String get hintButton => 'Pista';

  @override
  String get solutionButton => 'Solución';

  @override
  String get mapButton => 'Mapa';

  @override
  String get restartButton => 'Reiniciar';

  @override
  String get resetButton => 'Restablecer';

  @override
  String get puzzleMessageFindBestMove => 'Encuentra la mejor jugada.';

  @override
  String get puzzleMessageHintMate001 =>
      'La dama debe cubrir la última casilla de escape del rey.';

  @override
  String get puzzleMessageHintSequence002 => 'Empieza controlando el centro.';

  @override
  String get puzzleMessageHintSequence003 =>
      'Desarrolla con ganancia de tiempo y presiona el centro.';

  @override
  String get puzzleMessageLookHighlightedPiece => 'Observa la pieza resaltada.';

  @override
  String puzzleMessageSolution(String solution) {
    return 'Solución: $solution';
  }

  @override
  String get puzzleMessageTryMoveAgain => 'Intenta esa jugada de nuevo.';

  @override
  String get puzzleMessageChooseRightSquare => 'Elige la casilla correcta.';

  @override
  String get puzzleMessageTapPiece => 'Toca una pieza para jugar.';

  @override
  String get puzzleMessageWrongMove =>
      'Jugada incorrecta. Elige cómo quieres continuar.';

  @override
  String get puzzleMessageInconsistent =>
      'Este puzzle es inconsistente. Hay que corregir sus datos.';

  @override
  String get puzzleMessageInvalidOpponentReply =>
      'La respuesta automática no es válida en los datos del puzzle.';

  @override
  String get puzzleMessageCompleted => 'Perfecto. Nivel completado.';

  @override
  String get puzzleMessageOpponentReplied => 'Bien. Tu oponente respondió.';

  @override
  String get puzzleMessageContinueSequence => 'Bien. Continúa la secuencia.';

  @override
  String get themeMateIn1 => 'Mate en 1';

  @override
  String get themeDevelopment => 'Desarrollo';

  @override
  String get themeOpeningPattern => 'Patrón de apertura';

  @override
  String get themeFundamentals => 'Fundamentos';

  @override
  String get themeMaterial => 'Capturas e intercambios';

  @override
  String get themeFork => 'Tenedores';

  @override
  String get themePin => 'Clavadas';

  @override
  String get themeDiscoveredAttack => 'Ataques descubiertos';

  @override
  String get themeDefense => 'Defensa y contraataque';

  @override
  String get themeEndgame => 'Finales esenciales';

  @override
  String get themeCombination => 'Combinaciones tácticas';

  @override
  String get themeMastery => 'Maestría del tablero';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyAdvanced => 'Avanzado';

  @override
  String get themeComingSoon => 'Próximamente';
}
