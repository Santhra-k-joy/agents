import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';

class GameBoardState {
  GameBoardState._(List<List<Player?>> cells)
      : _cells = List<List<Player?>>.unmodifiable(
          cells.map((row) => List<Player?>.unmodifiable(row)),
        );

  static const int boardSize = 6;
  static const int quadrantSize = 3;

  factory GameBoardState.empty() {
    return GameBoardState._(
      List.generate(
        boardSize,
        (_) => List<Player?>.filled(boardSize, null),
      ),
    );
  }

  final List<List<Player?>> _cells;

  bool get isFull {
    return _cells.every(
      (row) => row.every((cell) => cell != null),
    );
  }

  Player? marbleAt(int row, int column) {
    if (!_isWithinBounds(row, column)) {
      return null;
    }

    return _cells[row][column];
  }

  bool canPlaceMarble(int row, int column) {
    return _isWithinBounds(row, column) && marbleAt(row, column) == null;
  }

  GameBoardState placeMarble({
    required int row,
    required int column,
    required Player player,
  }) {
    if (!canPlaceMarble(row, column)) {
      return this;
    }

    final updatedCells = _copyCells();
    updatedCells[row][column] = player;

    return GameBoardState._(updatedCells);
  }

  GameBoardState rotateQuadrant({
    required Quadrant quadrant,
    required RotationDirection direction,
  }) {
    final updatedCells = _copyCells();

    for (var rowOffset = 0; rowOffset < quadrantSize; rowOffset++) {
      for (var columnOffset = 0;
          columnOffset < quadrantSize;
          columnOffset++) {
        final sourceRow = quadrant.startRow + rowOffset;
        final sourceColumn = quadrant.startColumn + columnOffset;
        final marble = _cells[sourceRow][sourceColumn];

        final targetRowOffset = direction == RotationDirection.clockwise
            ? columnOffset
            : quadrantSize - 1 - columnOffset;
        final targetColumnOffset = direction == RotationDirection.clockwise
            ? quadrantSize - 1 - rowOffset
            : rowOffset;

        updatedCells[quadrant.startRow + targetRowOffset]
            [quadrant.startColumn + targetColumnOffset] = marble;
      }
    }

    return GameBoardState._(updatedCells);
  }

  List<List<Player?>> _copyCells() {
    return _cells
        .map((existingRow) => List<Player?>.of(existingRow))
        .toList();
  }

  bool _isWithinBounds(int row, int column) {
    return row >= 0 &&
        row < boardSize &&
        column >= 0 &&
        column < boardSize;
  }
}
