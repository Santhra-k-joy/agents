import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/game_difficulty.dart';
import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';

class AiMove {
  const AiMove({required this.row, required this.column});

  final int row;
  final int column;
}

class AiRotationDecision {
  const AiRotationDecision({required this.quadrant, required this.direction});

  final Quadrant quadrant;
  final RotationDirection direction;
}

class AiPlayer {
  static AiMove choosePlacement({
    required GameBoardState board,
    required Player player,
    required GameDifficulty difficulty,
  }) {
    final center = const AiMove(row: 2, column: 2);

    if (difficulty == GameDifficulty.easy) {
      if (board.canPlaceMarble(center.row, center.column)) {
        return center;
      }
      return _firstAvailableMove(board, fallback: center);
    }

    final winningMove = _findWinningMove(board, player);
    if (winningMove != null) {
      return winningMove;
    }

    final blockingMove = _findBlockingMove(board, player);
    if (blockingMove != null && difficulty == GameDifficulty.hard) {
      return blockingMove;
    }

    if (difficulty == GameDifficulty.medium ||
        difficulty == GameDifficulty.hard) {
      final tacticalMove = _findCenterOrCornerMove(board);
      if (tacticalMove != null) {
        return tacticalMove;
      }
    }

    return _firstAvailableMove(board, fallback: center);
  }

  static AiRotationDecision chooseRotation({
    required GameBoardState board,
    required Player player,
    required GameDifficulty difficulty,
  }) {
    final fallback = const AiRotationDecision(
      quadrant: Quadrant.topLeft,
      direction: RotationDirection.clockwise,
    );

    if (difficulty == GameDifficulty.easy) {
      return fallback;
    }

    return fallback;
  }

  static AiMove? _findWinningMove(GameBoardState board, Player player) {
    return _findMoveFor(board, player);
  }

  static AiMove? _findBlockingMove(GameBoardState board, Player player) {
    final opponent = player.opponent;
    return _findMoveFor(board, opponent);
  }

  static AiMove? _findMoveFor(GameBoardState board, Player player) {
    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var column = 0; column < GameBoardState.boardSize; column++) {
        if (!board.canPlaceMarble(row, column)) {
          continue;
        }

        final candidateBoard = board.placeMarble(
          row: row,
          column: column,
          player: player,
        );

        final winningPlayers = _winningPlayers(candidateBoard);
        if (winningPlayers.contains(player)) {
          return AiMove(row: row, column: column);
        }
      }
    }

    return null;
  }

  static Set<Player> _winningPlayers(GameBoardState board) {
    final winningPlayers = <Player>{};

    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var column = 0; column < GameBoardState.boardSize; column++) {
        final player = board.marbleAt(row, column);
        if (player == null) {
          continue;
        }

        if (_hasFiveInLine(board, player, row, column, 0, 1) ||
            _hasFiveInLine(board, player, row, column, 1, 0) ||
            _hasFiveInLine(board, player, row, column, 1, 1) ||
            _hasFiveInLine(board, player, row, column, 1, -1)) {
          winningPlayers.add(player);
        }
      }
    }

    return winningPlayers;
  }

  static bool _hasFiveInLine(
    GameBoardState board,
    Player player,
    int row,
    int column,
    int rowStep,
    int columnStep,
  ) {
    const winningLineLength = 5;
    final endRow = row + ((winningLineLength - 1) * rowStep);
    final endColumn = column + ((winningLineLength - 1) * columnStep);

    if (endRow < 0 ||
        endRow >= GameBoardState.boardSize ||
        endColumn < 0 ||
        endColumn >= GameBoardState.boardSize) {
      return false;
    }

    for (var offset = 1; offset < winningLineLength; offset++) {
      if (board.marbleAt(
            row + (offset * rowStep),
            column + (offset * columnStep),
          ) !=
          player) {
        return false;
      }
    }

    return true;
  }

  static AiMove? _findCenterOrCornerMove(GameBoardState board) {
    const centerMoves = <AiMove>[
      AiMove(row: 2, column: 2),
      AiMove(row: 0, column: 0),
      AiMove(row: 0, column: 5),
      AiMove(row: 5, column: 0),
      AiMove(row: 5, column: 5),
    ];

    for (final move in centerMoves) {
      if (board.canPlaceMarble(move.row, move.column)) {
        return move;
      }
    }

    return null;
  }

  static AiMove _firstAvailableMove(
    GameBoardState board, {
    required AiMove fallback,
  }) {
    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var column = 0; column < GameBoardState.boardSize; column++) {
        if (board.canPlaceMarble(row, column)) {
          return AiMove(row: row, column: column);
        }
      }
    }

    return fallback;
  }
}
