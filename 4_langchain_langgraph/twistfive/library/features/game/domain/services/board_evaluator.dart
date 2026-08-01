import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/player.dart';

class BoardEvaluator {
  static const int winScore = 100000;
  static const int _fourWeight = 1000;
  static const int _threeWeight = 100;
  static const int _twoWeight = 10;
  static const int _centerQuadrantBonus = 5;
  static const int _boardCenterBonus = 3;

  static const _boardSize = GameBoardState.boardSize;

  // Quadrant center cells
  static const _quadrantCenters = [(1, 1), (1, 4), (4, 1), (4, 4)];

  // Board center cells
  static const _boardCenterCells = [(2, 2), (2, 3), (3, 2), (3, 3)];

  /// Returns a score from [player]'s perspective. Positive = good for player.
  static int evaluate(GameBoardState board, Player player) {
    final opponent = player.opponent;
    var score = 0;

    // Evaluate all possible 5-cell lines
    score += _evaluateLines(board, player, opponent);

    // Positional bonuses
    for (final (row, col) in _quadrantCenters) {
      final marble = board.marbleAt(row, col);
      if (marble == player) {
        score += _centerQuadrantBonus;
      } else if (marble == opponent) {
        score -= _centerQuadrantBonus;
      }
    }

    for (final (row, col) in _boardCenterCells) {
      final marble = board.marbleAt(row, col);
      if (marble == player) {
        score += _boardCenterBonus;
      } else if (marble == opponent) {
        score -= _boardCenterBonus;
      }
    }

    return score;
  }

  static int _evaluateLines(
    GameBoardState board,
    Player player,
    Player opponent,
  ) {
    var score = 0;

    // Check all possible 5-in-a-row lines in 4 directions
    for (var row = 0; row < _boardSize; row++) {
      for (var col = 0; col < _boardSize; col++) {
        // Horizontal
        if (col + 4 < _boardSize) {
          score += _scoreLine(board, player, opponent, row, col, 0, 1);
        }
        // Vertical
        if (row + 4 < _boardSize) {
          score += _scoreLine(board, player, opponent, row, col, 1, 0);
        }
        // Diagonal down-right
        if (row + 4 < _boardSize && col + 4 < _boardSize) {
          score += _scoreLine(board, player, opponent, row, col, 1, 1);
        }
        // Diagonal down-left
        if (row + 4 < _boardSize && col - 4 >= 0) {
          score += _scoreLine(board, player, opponent, row, col, 1, -1);
        }
      }
    }

    return score;
  }

  static int _scoreLine(
    GameBoardState board,
    Player player,
    Player opponent,
    int startRow,
    int startCol,
    int dRow,
    int dCol,
  ) {
    var playerCount = 0;
    var opponentCount = 0;

    for (var i = 0; i < 5; i++) {
      final marble = board.marbleAt(startRow + i * dRow, startCol + i * dCol);
      if (marble == player) {
        playerCount++;
      } else if (marble == opponent) {
        opponentCount++;
      }
    }

    // Mixed line — no value for either side
    if (playerCount > 0 && opponentCount > 0) {
      return 0;
    }

    if (playerCount == 5) return winScore;
    if (opponentCount == 5) return -winScore;

    if (playerCount == 4) return _fourWeight;
    if (opponentCount == 4) return -_fourWeight;

    if (playerCount == 3) return _threeWeight;
    if (opponentCount == 3) return -_threeWeight;

    if (playerCount == 2) return _twoWeight;
    if (opponentCount == 2) return -_twoWeight;

    return 0;
  }

  /// Quick check if [player] has won.
  static bool hasWon(GameBoardState board, Player player) {
    for (var row = 0; row < _boardSize; row++) {
      for (var col = 0; col < _boardSize; col++) {
        if (board.marbleAt(row, col) != player) continue;
        if (_checkLine(board, player, row, col, 0, 1) ||
            _checkLine(board, player, row, col, 1, 0) ||
            _checkLine(board, player, row, col, 1, 1) ||
            _checkLine(board, player, row, col, 1, -1)) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _checkLine(
    GameBoardState board,
    Player player,
    int row,
    int col,
    int dRow,
    int dCol,
  ) {
    final endRow = row + 4 * dRow;
    final endCol = col + 4 * dCol;
    if (endRow < 0 || endRow >= _boardSize || endCol < 0 || endCol >= _boardSize) {
      return false;
    }
    for (var i = 1; i < 5; i++) {
      if (board.marbleAt(row + i * dRow, col + i * dCol) != player) {
        return false;
      }
    }
    return true;
  }
}
