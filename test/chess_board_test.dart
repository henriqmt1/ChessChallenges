import 'package:chess_chalenges/shared/chess/chess_board.dart';
import 'package:chess_chalenges/shared/chess/board_move.dart';
import 'package:chess_chalenges/shared/chess/board_piece.dart';
import 'package:chess_chalenges/shared/chess/chess_asset_paths.dart';
import 'package:flutter/material.dart';
import 'dart:ui' show SemanticsAction, Tristate;
import 'support/localized_test_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('announces piece, square, selection and legal destination', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    String? tapped;
    await tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: SizedBox.square(
            dimension: 320,
            child: ChessBoard(
              pieces: const {
                'e4': BoardPiece(
                  color: ChessPieceColor.white,
                  kind: ChessPieceKind.pawn,
                ),
              },
              selectedSquare: 'e4',
              legalTargets: const {'e5'},
              onSquareTap: (square) => tapped = square,
            ),
          ),
        ),
      ),
    );
    final selected = tester.getSemantics(
      find.bySemanticsLabel('E4, Peças brancas, Peão'),
    );
    expect(
      selected.getSemanticsData().flagsCollection.isSelected,
      Tristate.isTrue,
    );
    final destination = tester.getSemantics(
      find.bySemanticsLabel('E5, Casa vazia'),
    );
    expect(destination.hint, 'Destino disponível');
    destination.owner!.performAction(destination.id, SemanticsAction.tap);
    expect(tapped, 'e5');
    semantics.dispose();
  });

  testWidgets('shows a visible capture hint over occupied legal targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 320,
              child: ChessBoard(
                pieces: const {
                  'e8': BoardPiece(
                    color: ChessPieceColor.black,
                    kind: ChessPieceKind.king,
                  ),
                  'd7': BoardPiece(
                    color: ChessPieceColor.white,
                    kind: ChessPieceKind.queen,
                  ),
                },
                selectedSquare: 'e8',
                legalTargets: const {'d7'},
                onSquareTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('chess-square-d7')), findsOneWidget);
    expect(find.byKey(const ValueKey('chess-capture-hint')), findsOneWidget);
  });

  testWidgets('shows last move highlights over origin and target squares', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 320,
              child: ChessBoard(
                pieces: const {
                  'e4': BoardPiece(
                    color: ChessPieceColor.white,
                    kind: ChessPieceKind.pawn,
                  ),
                },
                selectedSquare: null,
                legalTargets: const {},
                highlightedMove: const BoardMove(from: 'e2', to: 'e4'),
                onSquareTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('chess-last-move-highlight')),
      findsNWidgets(2),
    );
  });

  testWidgets('black orientation places black home side at the bottom', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 320,
              child: ChessBoard(
                orientation: ChessBoardOrientation.black,
                pieces: const {
                  'c7': BoardPiece(
                    color: ChessPieceColor.black,
                    kind: ChessPieceKind.pawn,
                  ),
                },
                selectedSquare: null,
                legalTargets: const {},
                onSquareTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final boardFinder = find.byType(ChessBoard);
    final boardTop = tester.getTopLeft(boardFinder);
    final boardBottom = tester.getBottomLeft(boardFinder);
    final c7Center = tester.getCenter(
      find.byKey(const ValueKey('chess-square-c7')),
    );

    expect(
      c7Center.dy,
      greaterThan(boardTop.dy + (boardBottom.dy - boardTop.dy) * 0.70),
    );
  });
}
