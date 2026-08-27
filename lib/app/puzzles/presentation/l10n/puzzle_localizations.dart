import '../../../../l10n/app_localizations.dart';
import '../viewmodels/puzzle_state.dart';

extension PuzzleStateLocalizations on PuzzleState {
  String localizedMessage(AppLocalizations l10n) {
    return switch (message) {
      PuzzleMessage.findBestMove => puzzle.objective,
      PuzzleMessage.puzzleHint => puzzle.hint.text,
      PuzzleMessage.lookHighlightedPiece =>
        l10n.puzzleMessageLookHighlightedPiece,
      PuzzleMessage.solution => l10n.puzzleMessageSolution(solutionText),
      PuzzleMessage.tryMoveAgain => l10n.puzzleMessageTryMoveAgain,
      PuzzleMessage.chooseRightSquare => l10n.puzzleMessageChooseRightSquare,
      PuzzleMessage.tapPiece => l10n.puzzleMessageTapPiece,
      PuzzleMessage.wrongMove => l10n.puzzleMessageWrongMove,
      PuzzleMessage.inconsistentPuzzle => l10n.puzzleMessageInconsistent,
      PuzzleMessage.invalidOpponentReply =>
        l10n.puzzleMessageInvalidOpponentReply,
      PuzzleMessage.completed => l10n.puzzleMessageCompleted,
      PuzzleMessage.opponentReplied => l10n.puzzleMessageOpponentReplied,
      PuzzleMessage.continueSequence => l10n.puzzleMessageContinueSequence,
    };
  }
}

String localizedPuzzleTheme(AppLocalizations l10n, String theme) {
  return switch (theme) {
    'mateIn1' => l10n.themeMateIn1,
    'development' => l10n.themeDevelopment,
    'openingPattern' => l10n.themeOpeningPattern,
    'fundamentals' => l10n.themeFundamentals,
    'material' => l10n.themeMaterial,
    'fork' => l10n.themeFork,
    'pin' => l10n.themePin,
    'discoveredAttack' => l10n.themeDiscoveredAttack,
    'defense' => l10n.themeDefense,
    'endgame' => l10n.themeEndgame,
    'combination' => l10n.themeCombination,
    'mastery' => l10n.themeMastery,
    _ => l10n.themeComingSoon,
  };
}

String localizedDifficulty(AppLocalizations l10n, String difficultyBand) {
  return switch (difficultyBand) {
    'easy' => l10n.difficultyEasy,
    'medium' => l10n.difficultyMedium,
    'advanced' => l10n.difficultyAdvanced,
    _ => l10n.difficultyMedium,
  };
}
