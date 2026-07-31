import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';
import 'package:twistfive/features/game/domain/models/player.dart';

class WinningLine {
  const WinningLine({required this.cells});

  final List<(int row, int column)> cells;
}

class GameResultResolver {
  static const int _winningLineLength = 5;

  static GameStatus afterPlacement(GameBoardState board) {
    return _statusForWinningPlayers(_findWinningPlayers(board));
  }

  static GameStatus afterRotation(GameBoardState board) {
    final winningStatus = _statusForWinningPlayers(_findWinningPlayers(board));

    if (winningStatus.isFinished) {
      return winningStatus;
    }

    return board.isFull ? GameStatus.draw : GameStatus.inProgress;
  }

  static WinningLine? winningLineFor(GameBoardState board) {
    return _findWinningLine(board);
  }

  static GameStatus _statusForWinningPlayers(Set<Player> winningPlayers) {
    if (winningPlayers.length > 1) {
      return GameStatus.draw;
    }

    if (winningPlayers.contains(Player.black)) {
      return GameStatus.blackWins;
    }

    if (winningPlayers.contains(Player.white)) {
      return GameStatus.whiteWins;
    }

    return GameStatus.inProgress;
  }

  static WinningLine? _findWinningLine(GameBoardState board) {
    final winningPlayers = _findWinningPlayers(board);
    if (winningPlayers.isEmpty) {
      return null;
    }

    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var column = 0; column < GameBoardState.boardSize; column++) {
        final player = board.marbleAt(row, column);

        if (player == null || !winningPlayers.contains(player)) {
          continue;
        }

        final line = _winningLineFor(board, player, row, column, 0, 1);
        if (line != null) {
          return line;
        }

        final lineVertical = _winningLineFor(board, player, row, column, 1, 0);
        if (lineVertical != null) {
          return lineVertical;
        }

        final lineDiagonal = _winningLineFor(board, player, row, column, 1, 1);
        if (lineDiagonal != null) {
          return lineDiagonal;
        }

        final lineAntiDiagonal = _winningLineFor(
          board,
          player,
          row,
          column,
          1,
          -1,
        );
        if (lineAntiDiagonal != null) {
          return lineAntiDiagonal;
        }
      }
    }

    return null;
  }

  static Set<Player> _findWinningPlayers(GameBoardState board) {
    final winningPlayers = <Player>{};

    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var column = 0; column < GameBoardState.boardSize; column++) {
        final player = board.marbleAt(row, column);

        if (player == null) {
          continue;
        }

        if (_hasWinningLine(board, player, row, column, 0, 1) ||
            _hasWinningLine(board, player, row, column, 1, 0) ||
            _hasWinningLine(board, player, row, column, 1, 1) ||
            _hasWinningLine(board, player, row, column, 1, -1)) {
          winningPlayers.add(player);
        }
      }
    }

    return winningPlayers;
  }

  static bool _hasWinningLine(
    GameBoardState board,
    Player player,
    int row,
    int column,
    int rowStep,
    int columnStep,
  ) {
    final endRow = row + ((_winningLineLength - 1) * rowStep);
    final endColumn = column + ((_winningLineLength - 1) * columnStep);

    if (endRow < 0 ||
        endRow >= GameBoardState.boardSize ||
        endColumn < 0 ||
        endColumn >= GameBoardState.boardSize) {
      return false;
    }

    for (var offset = 0; offset < _winningLineLength; offset++) {
      final candidateRow = row + (offset * rowStep);
      final candidateColumn = column + (offset * columnStep);
      if (board.marbleAt(candidateRow, candidateColumn) != player) {
        return false;
      }
    }

    return true;
  }

  static WinningLine? _winningLineFor(
    GameBoardState board,
    Player player,
    int row,
    int column,
    int rowStep,
    int columnStep,
  ) {
    final endRow = row + ((_winningLineLength - 1) * rowStep);
    final endColumn = column + ((_winningLineLength - 1) * columnStep);

    if (endRow < 0 ||
        endRow >= GameBoardState.boardSize ||
        endColumn < 0 ||
        endColumn >= GameBoardState.boardSize) {
      return null;
    }

    final cells = <(int row, int column)>[];
    for (var offset = 0; offset < _winningLineLength; offset++) {
      final candidateRow = row + (offset * rowStep);
      final candidateColumn = column + (offset * columnStep);
      if (board.marbleAt(candidateRow, candidateColumn) != player) {
        return null;
      }
      cells.add((candidateRow, candidateColumn));
    }

    return WinningLine(cells: cells);
  }
}
