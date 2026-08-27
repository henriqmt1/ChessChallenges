// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chess Chalenges';

  @override
  String get darkModeTooltip => 'Enable dark mode';

  @override
  String get lightModeTooltip => 'Enable light mode';

  @override
  String get faqTooltip => 'Help and frequently asked questions';

  @override
  String get progressTooltip => 'View progress and stats';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'Your Chess Chalenges summary.';

  @override
  String get progressHeroTitle => 'Your growth';

  @override
  String get progressHeroSubtitle =>
      'Stats are saved locally and synced when internet is available.';

  @override
  String get progressSynced => 'Synced';

  @override
  String get progressLocalOnly => 'Saved on device';

  @override
  String get progressSyncSection => 'Sync';

  @override
  String get progressSyncGuestTitle => 'Protect your progress';

  @override
  String get progressSyncGuestDescription =>
      'Sign in with Google or Apple to recover your stats and levels on another device.';

  @override
  String get progressSyncConnectedTitle => 'Progress protected';

  @override
  String progressSyncConnectedDescription(String account) {
    return 'Connected as $account. Your data will sync when internet is available.';
  }

  @override
  String get progressSyncConnectedFallback => 'your account';

  @override
  String get progressSyncGuestBadge => 'Guest';

  @override
  String get progressSyncConnectedBadge => 'Connected account';

  @override
  String get progressSyncGoogleAction => 'Sign in with Google';

  @override
  String get progressSyncAppleAction => 'Sign in with Apple';

  @override
  String get progressSyncNowAction => 'Sync now';

  @override
  String get progressSyncErrorGeneric =>
      'Could not sync right now. Try again in a moment.';

  @override
  String get progressSyncErrorFirebase =>
      'Firebase is not available in this environment yet.';

  @override
  String get progressSyncErrorGoogleConfig =>
      'Google sign-in still needs to be configured in Firebase for this app.';

  @override
  String get progressSyncErrorAppleConfig =>
      'Apple sign-in still needs to be configured for this app.';

  @override
  String get progressSyncErrorProviderDisabled =>
      'This sign-in method is not enabled in Firebase yet.';

  @override
  String get progressSyncErrorAccountExists =>
      'This account already exists. Sign in with it to load saved progress.';

  @override
  String get progressSyncErrorNetwork =>
      'Check your internet and try syncing again.';

  @override
  String get progressSyncCanceled => 'Sign-in canceled.';

  @override
  String get progressRoutineSection => 'Routine';

  @override
  String get progressLearningSection => 'Learning';

  @override
  String get progressGamesSection => 'Games';

  @override
  String get progressCurrentStreak => 'Current streak';

  @override
  String get progressBestStreak => 'Best streak';

  @override
  String get progressActiveDays => 'Active days';

  @override
  String get progressGuidedLessons => 'Lessons completed';

  @override
  String get progressObjectiveStars => 'Objective stars';

  @override
  String get progressObjectiveChallenges => 'Objectives completed';

  @override
  String get progressTotalGames => 'Games played';

  @override
  String get progressBotGames => 'Bot games';

  @override
  String get progressBotWins => 'Bot wins';

  @override
  String get progressBotAdvancedWins => 'Advanced wins';

  @override
  String get progressLocalGames => 'Local 2 players';

  @override
  String get progressLocalWins => 'Local wins';

  @override
  String progressBotSummary(int wins, int advancedWins) {
    return '$wins wins • $advancedWins advanced';
  }

  @override
  String progressLocalSummary(int draws) {
    return 'Same device • $draws draws';
  }

  @override
  String get faqComingSoon => 'The help center will be added soon.';

  @override
  String get faqPageTitle => 'Help center';

  @override
  String get faqHeroTitle => 'How can we help?';

  @override
  String get faqPageSubtitle =>
      'Quick answers about the game, your account, and purchases.';

  @override
  String get faqGeneralSection => 'Game and editions';

  @override
  String get faqPurchasesSection => 'Purchases and payments';

  @override
  String get faqAccountSection => 'Account, devices, and updates';

  @override
  String get faqFreeProQuestion =>
      'What is the difference between FREE and PRO?';

  @override
  String get faqFreeProAnswer =>
      'The FREE edition gives access to every world and level through normal progression, with ads at controlled intervals. PRO permanently removes ads; it does not skip or unlock levels.';

  @override
  String get faqInternetQuestion => 'Do I need internet to play?';

  @override
  String get faqInternetAnswer =>
      'Levels can be played offline. Internet is only required to sign in, sync data, purchase or restore PRO, and load ads.';

  @override
  String get faqAdsQuestion => 'When do ads appear?';

  @override
  String get faqAdsAnswer =>
      'Ads only appear in the FREE edition at natural pauses between some levels. They never interrupt a move. If an ad cannot load, the game continues normally.';

  @override
  String get faqLifetimeQuestion => 'Is PRO a monthly purchase?';

  @override
  String get faqLifetimeAnswer =>
      'No. PRO is a one-time lifetime purchase with no subscription or recurring charge. Google Play or the App Store displays the price and currency before confirmation.';

  @override
  String get faqRestoreQuestion => 'What does restore purchase mean?';

  @override
  String get faqRestoreAnswer =>
      'Restore purchase asks Google Play or the App Store to recover a PRO purchase you already made. It does not create a new charge or request a refund.';

  @override
  String get faqRefundQuestion => 'How do refunds work?';

  @override
  String get faqRefundAnswer =>
      'Refund requests are submitted to and reviewed by Google Play or the App Store. When the store approves and returns the payment under its rules, the related PRO access may be removed.';

  @override
  String get faqAccountQuestion => 'Why use an in-app account?';

  @override
  String get faqAccountAnswer =>
      'Your account protects and syncs PRO access across devices. The entitlement is linked to your secure internal account identifier and does not depend on your email remaining unchanged or visible.';

  @override
  String get faqNewDeviceQuestion =>
      'I changed phones or reinstalled the app. What now?';

  @override
  String get faqNewDeviceAnswer =>
      'Sign in with the same account you used before. The app will sync your PRO access; if needed, use Restore purchase with the same store account that made the payment.';

  @override
  String get faqCrossPlatformQuestion => 'Does PRO work on Android and iPhone?';

  @override
  String get faqCrossPlatformAnswer =>
      'Yes, when the verified purchase is linked to the same in-app account. Without that link, each store can only restore purchases within its own system.';

  @override
  String get faqUpdatesQuestion => 'Can the app require an update?';

  @override
  String get faqUpdatesAnswer =>
      'Regular updates are available through the store. If a version is essential for security or compatibility, the app may require an update before you can continue.';

  @override
  String get faqFooterMessage =>
      'Purchases and refunds are always processed by your device\'s official store. The app never asks for your banking details directly.';

  @override
  String get premiumSheetTitle => 'Chess Chalenges PRO';

  @override
  String get premiumActiveTitle => 'Your PRO version is active';

  @override
  String get premiumDescription => 'One purchase to play without ads.';

  @override
  String get premiumAfterAdTitle => 'Tired of ads?';

  @override
  String get premiumAfterAdDescription =>
      'Go PRO once and remove every ad between levels forever.';

  @override
  String get premiumActiveDescription =>
      'Thanks for supporting the game. You will not see ads between levels.';

  @override
  String get premiumBenefitNoAds => 'No ads between levels';

  @override
  String get premiumBenefitLifetime => 'Lifetime access, no subscription';

  @override
  String get premiumBenefitSameProgress => 'Keeps all your current progress';

  @override
  String get premiumPriceLoading => 'Checking price...';

  @override
  String premiumBuyAction(String price) {
    return 'Unlock PRO • $price';
  }

  @override
  String get premiumPendingAction => 'Waiting for the store...';

  @override
  String get premiumRestoreAction => 'Restore purchase';

  @override
  String get premiumStoreUnavailable =>
      'The store is unavailable right now. Check your connection and try again.';

  @override
  String get premiumProductUnavailable =>
      'The PRO version has not been configured in this store yet.';

  @override
  String get premiumPurchaseFailed =>
      'The purchase could not be completed. Please try again shortly.';

  @override
  String get privacyOptionsAction => 'Ad privacy options';

  @override
  String get splashLoadingLabel => 'Preparing your challenges...';

  @override
  String get splashLoadError => 'The game could not be prepared.';

  @override
  String get splashRetryAction => 'Try again';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateDefaultMessage =>
      'This version must be updated to keep working correctly.';

  @override
  String get forceUpdateAction => 'Update now';

  @override
  String get forceUpdateStoreError =>
      'The store could not be opened. Please try again shortly.';

  @override
  String get homeChooseModeTitle => 'How do you want to play today?';

  @override
  String get homeChooseModeSubtitle =>
      'Choose a mode to train, play, or get ready for the next challenges.';

  @override
  String get homePlayAction => 'Play';

  @override
  String get homeComingSoonAction => 'Coming soon';

  @override
  String get homeGuidedLessonsTitle => 'Guided lessons';

  @override
  String get homeGuidedLessonsDescription =>
      'Continue the current campaign with explained levels, hints, and world progression.';

  @override
  String get homeObjectiveModeTitle => 'Objective challenges';

  @override
  String get homeObjectiveModeDescription =>
      'Solve open situations, chase up to 3 stars, and win with fewer moves.';

  @override
  String get objectiveChallengesTitle => 'Objective challenges';

  @override
  String get objectiveChallengesHeroTitle => 'Chase 3 stars';

  @override
  String get objectiveChallengesHeroSubtitle => 'in as few moves as possible';

  @override
  String objectiveChallengesLevelCount(int count) {
    return '$count challenges';
  }

  @override
  String objectiveChallengesProgress(int earned, int total) {
    return '$earned/$total';
  }

  @override
  String get objectiveChallengesFutureLevelsNote =>
      'New stages will be released in the future.';

  @override
  String objectiveChallengeLevelSemantics(int level) {
    return 'Challenge $level';
  }

  @override
  String get homeVsBotModeTitle => 'Vs bot';

  @override
  String get homeVsBotModeDescription =>
      'Play matches against easy, medium, or advanced bots whenever you want free practice.';

  @override
  String get homeLocalPlayersModeTitle => '2 local players';

  @override
  String get homeLocalPlayersModeDescription =>
      'Use the phone as a board to play with another person on the same device.';

  @override
  String get localGameTitle => '2 local players';

  @override
  String get localGameSubtitle => 'A shared board to play on the same phone.';

  @override
  String get localGameWhiteSide => 'White';

  @override
  String get localGameBlackSide => 'Black';

  @override
  String localGameTurnTitle(String side) {
    return 'Turn: $side';
  }

  @override
  String get localGameCheckTitle => 'CHECK!';

  @override
  String localGameCheckTurnDescription(String side) {
    return '$side must defend the king.';
  }

  @override
  String get localGameCheckWarning => 'King in check. Find a defense.';

  @override
  String get localGameCheckmateTitle => 'Checkmate';

  @override
  String get localGameDrawTitle => 'Draw';

  @override
  String get localGameDrawDescription =>
      'Nobody won this game. Restart to play another one.';

  @override
  String localGameWinnerLabel(String side) {
    return '$side wins.';
  }

  @override
  String get localGameReadyMessage =>
      'Tap the side-to-move piece, play, and pass the phone.';

  @override
  String localGameMovesCount(int count) {
    return 'Moves: $count';
  }

  @override
  String localGameActivityPending(int remaining) {
    return '$remaining moves left for streak';
  }

  @override
  String get localGameActivityDone => 'Today’s streak is safe';

  @override
  String get localGameRestartButton => 'Restart';

  @override
  String get localGameResetAction => 'Restart game';

  @override
  String get localGameFlipBoardAction => 'Flip board';

  @override
  String get localGameResetDialogTitle => 'Restart game?';

  @override
  String get localGameResetDialogMessage =>
      'The current game will be cleared and the board will return to the starting position.';

  @override
  String get localGameResetCancelAction => 'Cancel';

  @override
  String get localGameResetConfirmAction => 'Restart';

  @override
  String get showLastMoveAction => 'Show last move';

  @override
  String get promotionChoiceTitle => 'Promote pawn';

  @override
  String get promotionChoiceSubtitle => 'Choose which piece this pawn becomes.';

  @override
  String get promotionQueen => 'Queen';

  @override
  String get promotionRook => 'Rook';

  @override
  String get promotionBishop => 'Bishop';

  @override
  String get promotionKnight => 'Knight';

  @override
  String get botGameTitle => 'Vs bot';

  @override
  String get botGameChooseDifficultyTitle => 'Choose the bot level';

  @override
  String get botGameChooseDifficultySubtitle =>
      'You play white. The bot answers as black based on the selected level.';

  @override
  String get botDifficultyBeginnerTitle => 'Beginner';

  @override
  String get botDifficultyBeginnerDescription =>
      'Plays legal moves, but still makes mistakes and leaves chances open.';

  @override
  String get botDifficultyIntermediateTitle => 'Intermediate';

  @override
  String get botDifficultyIntermediateDescription =>
      'Looks for captures, checks, and avoids hanging pieces.';

  @override
  String get botDifficultyAdvancedTitle => 'Advanced';

  @override
  String get botDifficultyAdvancedDescription =>
      'Calculates one reply ahead before choosing its move.';

  @override
  String get botGameStartAction => 'Start';

  @override
  String get botGameYourTurnTitle => 'Your turn';

  @override
  String get botGameThinkingTitle => 'Bot thinking...';

  @override
  String get botGameThinkingDescription =>
      'It is looking for a reply and will move soon.';

  @override
  String get botGameReadyDescription =>
      'You play white. Tap a piece and make your move.';

  @override
  String get botGamePlayerInCheckDescription =>
      'Your king is in check. Defend now.';

  @override
  String get botGameBotInCheckDescription =>
      'You put the bot in check. It has to respond.';

  @override
  String get botGameYouWonTitle => 'You won';

  @override
  String get botGameYouWonDescription => 'Checkmate against the bot. Nice!';

  @override
  String get botGameBotWonTitle => 'Bot won';

  @override
  String get botGameBotWonDescription =>
      'The bot delivered checkmate. Restart to try again.';

  @override
  String get botGameDrawTitle => 'Draw';

  @override
  String get botGameDrawDescription =>
      'The match ended without a winner. Restart to play another one.';

  @override
  String campaignLoadError(String error) {
    return 'The campaign could not be loaded: $error';
  }

  @override
  String worldLabel(int world) {
    return 'World $world';
  }

  @override
  String worldSummary(int levels, int xp) {
    return 'Checkmates and fundamentals • $levels levels • $xp XP';
  }

  @override
  String worldXp(int earned, int total) {
    return 'World XP: $earned/$total';
  }

  @override
  String offensiveCount(int count) {
    return 'Streak $count';
  }

  @override
  String get nextWorldUnlockedMessage =>
      'World 2 unlocked. Its puzzles will be connected next.';

  @override
  String get completeWorldToUnlockMessage =>
      'Complete every level in this world to unlock the next one.';

  @override
  String get completeCurrentLevelToUnlockMessage =>
      'Complete the current level to unlock this one.';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String lockedLevelTitle(int level) {
    return 'Level $level locked';
  }

  @override
  String get lockedLevelAction => 'Level locked';

  @override
  String get completePreviousLevelsToUnlock =>
      'Complete the previous levels to unlock this one.';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String reviewLevelTitle(int level) {
    return 'Review level $level';
  }

  @override
  String get reviewLevelAction => 'Review level';

  @override
  String startWithXp(int xp) {
    return 'Start +$xp XP';
  }

  @override
  String get xpAlreadyCollectedDescription =>
      'The XP for this level has already been collected.';

  @override
  String get completeToAddXpDescription =>
      'Complete it to add XP to the world.';

  @override
  String worldTheme(int world, String theme) {
    return 'World $world • $theme';
  }

  @override
  String levelProgress(int current, int total) {
    return 'Level $current/$total';
  }

  @override
  String get xpCollected => 'XP collected';

  @override
  String xpAmount(int xp) {
    return '+$xp XP';
  }

  @override
  String goToWorld(int world) {
    return 'Go to World $world';
  }

  @override
  String get nextWorld => 'Next world';

  @override
  String get newChallengesUnlocked => 'A new set of challenges is unlocked.';

  @override
  String completeLevelsToUnlock(int completed, int total) {
    return 'Complete $completed/$total levels to unlock.';
  }

  @override
  String puzzlesLoadError(String error) {
    return 'The puzzles could not be loaded: $error';
  }

  @override
  String get backTooltip => 'Back';

  @override
  String get hintTooltip => 'Hint';

  @override
  String get hintUsedTooltip => 'Hint already used for this move';

  @override
  String puzzleMeta(int world, int chapter, int level) {
    return 'World $world • Chapter $chapter • Level $level';
  }

  @override
  String get wrongMoveTitle => 'Wrong move';

  @override
  String get moveNotPlayed => 'That move was not played on the board.';

  @override
  String get retryMove => 'Try the move again';

  @override
  String get restartLevel => 'Restart level';

  @override
  String get perfectTitle => 'Perfect';

  @override
  String get reviewCompletedTitle => 'Review complete';

  @override
  String levelCompletedWithXp(int level, int xp) {
    return 'Level $level complete. +$xp XP';
  }

  @override
  String levelReviewedXpCollected(int level) {
    return 'Level $level reviewed. XP already collected.';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get hintButton => 'Hint';

  @override
  String get solutionButton => 'Solution';

  @override
  String get mapButton => 'Map';

  @override
  String get restartButton => 'Restart';

  @override
  String get resetButton => 'Reset';

  @override
  String get puzzleMessageFindBestMove => 'Find the best move.';

  @override
  String get puzzleMessageHintMate001 =>
      'The queen must cover the king\'s final escape square.';

  @override
  String get puzzleMessageHintSequence002 =>
      'Start by taking control of the center.';

  @override
  String get puzzleMessageHintSequence003 =>
      'Develop with tempo and put pressure on the center.';

  @override
  String get puzzleMessageLookHighlightedPiece =>
      'Look at the highlighted piece.';

  @override
  String puzzleMessageSolution(String solution) {
    return 'Solution: $solution';
  }

  @override
  String get puzzleMessageTryMoveAgain => 'Try that move again.';

  @override
  String get puzzleMessageChooseRightSquare => 'Choose the right square.';

  @override
  String get puzzleMessageTapPiece => 'Tap a piece to play.';

  @override
  String get puzzleMessageWrongMove =>
      'Wrong move. Choose how you want to continue.';

  @override
  String get puzzleMessageInconsistent =>
      'This puzzle is inconsistent. Its data needs to be fixed.';

  @override
  String get puzzleMessageInvalidOpponentReply =>
      'The automated reply is invalid in the puzzle data.';

  @override
  String get puzzleMessageCompleted => 'Perfect. Level complete.';

  @override
  String get puzzleMessageOpponentReplied => 'Nice. Your opponent replied.';

  @override
  String get puzzleMessageContinueSequence => 'Nice. Continue the sequence.';

  @override
  String get themeMateIn1 => 'Mate in 1';

  @override
  String get themeDevelopment => 'Development';

  @override
  String get themeOpeningPattern => 'Opening pattern';

  @override
  String get themeFundamentals => 'Fundamentals';

  @override
  String get themeMaterial => 'Captures and trades';

  @override
  String get themeFork => 'Forks';

  @override
  String get themePin => 'Pins';

  @override
  String get themeDiscoveredAttack => 'Discovered attacks';

  @override
  String get themeDefense => 'Defense and counterattack';

  @override
  String get themeEndgame => 'Essential endgames';

  @override
  String get themeCombination => 'Tactical combinations';

  @override
  String get themeMastery => 'Board mastery';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String get themeComingSoon => 'Coming soon';
}
