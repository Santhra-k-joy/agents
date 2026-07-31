import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';
import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/rules/game_result_resolver.dart';

enum TurnPhase { placeMarble, rotateQuadrant }

class GameState {
  const GameState._({
    required this.board,
    required this.currentPlayer,
    required this.turnPhase,
    required this.status,
    this.winningLine,
  });

  factory GameState.initial() {
    return GameState._(
      board: GameBoardState.empty(),
      currentPlayer: Player.black,
      turnPhase: TurnPhase.placeMarble,
      status: GameStatus.inProgress,
    );
  }

  final GameBoardState board;
  final Player currentPlayer;
  final TurnPhase turnPhase;
  final GameStatus status;
  final WinningLine? winningLine;

  bool get isPlacementPhase => turnPhase == TurnPhase.placeMarble;

  bool get isRotationPhase => turnPhase == TurnPhase.rotateQuadrant;

  bool get isGameOver => status.isFinished;

  GameState placeMarble(int row, int column) {
    if (isGameOver || !isPlacementPhase || !board.canPlaceMarble(row, column)) {
      return this;
    }

    final updatedBoard = board.placeMarble(
      row: row,
      column: column,
      player: currentPlayer,
    );
    final status = GameResultResolver.afterPlacement(updatedBoard);

    return GameState._(
      board: updatedBoard,
      currentPlayer: currentPlayer,
      turnPhase: status.isFinished
          ? TurnPhase.placeMarble
          : TurnPhase.rotateQuadrant,
      status: status,
      winningLine: GameResultResolver.winningLineFor(updatedBoard),
    );
  }

  GameState rotateQuadrant({
    required Quadrant quadrant,
    required RotationDirection direction,
  }) {
    if (isGameOver || !isRotationPhase) {
      return this;
    }

    final updatedBoard = board.rotateQuadrant(
      quadrant: quadrant,
      direction: direction,
    );
    final status = GameResultResolver.afterRotation(updatedBoard);

    return GameState._(
      board: updatedBoard,
      currentPlayer: currentPlayer.opponent,
      turnPhase: TurnPhase.placeMarble,
      status: status,
      winningLine: GameResultResolver.winningLineFor(updatedBoard),
    );
  }
}
