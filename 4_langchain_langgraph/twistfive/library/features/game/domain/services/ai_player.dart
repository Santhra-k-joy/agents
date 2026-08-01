import 'dart:math';

import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/game_difficulty.dart';
import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/services/board_evaluator.dart';

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

class _FullMove {
  const _FullMove({required this.placement, required this.rotation});

  final AiMove placement;
  final AiRotationDecision rotation;
}

class AiPlayer {
  static final _random = Random();

  // Cache the rotation decision computed during choosePlacement for Hard/Extreme
  static AiRotationDecision? _cachedRotation;

  static AiMove choosePlacement({
    required GameBoardState board,
    required Player player,
    required GameDifficulty difficulty,
  }) {
    _cachedRotation = null;

    switch (difficulty) {
      case GameDifficulty.easy:
        return _easyPlacement(board);
      case GameDifficulty.medium:
        return _mediumPlacement(board, player);
      case GameDifficulty.hard:
        final move = _minimaxFullMove(board, player, maxDepth: 3, timeBudgetMs: 500);
        _cachedRotation = move.rotation;
        return move.placement;
      case GameDifficulty.extremeHard:
        final emptyCells = _countEmpty(board);
        final depth = emptyCells < 15 ? 5 : 4;
        final move = _minimaxFullMove(board, player, maxDepth: depth, timeBudgetMs: 1500);
        _cachedRotation = move.rotation;
        return move.placement;
    }
  }

  static AiRotationDecision chooseRotation({
    required GameBoardState board,
    required Player player,
    required GameDifficulty difficulty,
  }) {
    // Return cached result from minimax if available
    if (_cachedRotation != null) {
      final cached = _cachedRotation!;
      _cachedRotation = null;
      return cached;
    }

    switch (difficulty) {
      case GameDifficulty.easy:
        return _easyRotation();
      case GameDifficulty.medium:
        return _mediumRotation(board, player);
      case GameDifficulty.hard:
      case GameDifficulty.extremeHard:
        return _mediumRotation(board, player);
    }
  }

  // --- Easy: Random ---

  static AiMove _easyPlacement(GameBoardState board) {
    final emptyCells = <AiMove>[];
    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var col = 0; col < GameBoardState.boardSize; col++) {
        if (board.canPlaceMarble(row, col)) {
          emptyCells.add(AiMove(row: row, column: col));
        }
      }
    }
    if (emptyCells.isEmpty) return const AiMove(row: 0, column: 0);
    return emptyCells[_random.nextInt(emptyCells.length)];
  }

  static AiRotationDecision _easyRotation() {
    final quadrant = Quadrant.values[_random.nextInt(Quadrant.values.length)];
    final direction = RotationDirection.values[_random.nextInt(RotationDirection.values.length)];
    return AiRotationDecision(quadrant: quadrant, direction: direction);
  }

  // --- Medium: Greedy 1-ply heuristic ---

  static AiMove _mediumPlacement(GameBoardState board, Player player) {
    AiMove? bestMove;
    var bestScore = -BoardEvaluator.winScore * 2;

    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var col = 0; col < GameBoardState.boardSize; col++) {
        if (!board.canPlaceMarble(row, col)) continue;
        final newBoard = board.placeMarble(row: row, column: col, player: player);
        final score = BoardEvaluator.evaluate(newBoard, player);
        if (score > bestScore) {
          bestScore = score;
          bestMove = AiMove(row: row, column: col);
        }
      }
    }

    return bestMove ?? const AiMove(row: 2, column: 2);
  }

  static AiRotationDecision _mediumRotation(GameBoardState board, Player player) {
    AiRotationDecision? bestRotation;
    var bestScore = -BoardEvaluator.winScore * 2;

    for (final quadrant in Quadrant.values) {
      for (final direction in RotationDirection.values) {
        final rotated = board.rotateQuadrant(quadrant: quadrant, direction: direction);
        // Avoid rotations that give the opponent a win
        if (BoardEvaluator.hasWon(rotated, player.opponent)) continue;
        final score = BoardEvaluator.evaluate(rotated, player);
        if (score > bestScore) {
          bestScore = score;
          bestRotation = AiRotationDecision(quadrant: quadrant, direction: direction);
        }
      }
    }

    return bestRotation ??
        const AiRotationDecision(
          quadrant: Quadrant.topLeft,
          direction: RotationDirection.clockwise,
        );
  }

  // --- Hard / Extreme: Minimax with alpha-beta pruning ---

  static _FullMove _minimaxFullMove(
    GameBoardState board,
    Player player, {
    required int maxDepth,
    required int timeBudgetMs,
  }) {
    final stopwatch = Stopwatch()..start();
    final emptyCells = _countEmpty(board);
    // Reduce depth for large branching factor
    final effectiveDepth = emptyCells > 20 ? min(maxDepth, 2) : maxDepth;

    _FullMove? bestFullMove;
    var bestScore = -BoardEvaluator.winScore * 2;

    // Generate and score candidate placements for move ordering
    final candidates = <(AiMove, int)>[];
    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var col = 0; col < GameBoardState.boardSize; col++) {
        if (!board.canPlaceMarble(row, col)) continue;
        final placed = board.placeMarble(row: row, column: col, player: player);
        candidates.add((AiMove(row: row, column: col), BoardEvaluator.evaluate(placed, player)));
      }
    }
    // Sort by heuristic score descending for better pruning
    candidates.sort((a, b) => b.$2.compareTo(a.$2));

    for (final (move, _) in candidates) {
      if (stopwatch.elapsedMilliseconds > timeBudgetMs) break;

      final placed = board.placeMarble(row: move.row, column: move.column, player: player);

      // Check immediate win from placement
      if (BoardEvaluator.hasWon(placed, player)) {
        // Pick rotation that doesn't undo the win
        final rotation = _bestRotationAfterPlacement(placed, player);
        return _FullMove(placement: move, rotation: rotation);
      }

      // Try each rotation after this placement
      for (final quadrant in Quadrant.values) {
        for (final direction in RotationDirection.values) {
          if (stopwatch.elapsedMilliseconds > timeBudgetMs) break;

          final rotated = placed.rotateQuadrant(quadrant: quadrant, direction: direction);

          // If rotation gives opponent a win, skip (unless we already won)
          if (BoardEvaluator.hasWon(rotated, player.opponent) &&
              !BoardEvaluator.hasWon(rotated, player)) {
            continue;
          }

          // Opponent's turn — minimize
          final score = _minimax(
            rotated,
            player,
            effectiveDepth - 1,
            -BoardEvaluator.winScore * 2,
            BoardEvaluator.winScore * 2,
            false,
            stopwatch,
            timeBudgetMs,
          );

          if (score > bestScore) {
            bestScore = score;
            bestFullMove = _FullMove(
              placement: move,
              rotation: AiRotationDecision(quadrant: quadrant, direction: direction),
            );
          }
        }
      }
    }

    if (bestFullMove != null) return bestFullMove;

    // Fallback
    final fallbackPlacement = candidates.isNotEmpty
        ? candidates.first.$1
        : const AiMove(row: 2, column: 2);
    return _FullMove(
      placement: fallbackPlacement,
      rotation: const AiRotationDecision(
        quadrant: Quadrant.topLeft,
        direction: RotationDirection.clockwise,
      ),
    );
  }

  static int _minimax(
    GameBoardState board,
    Player aiPlayer,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    Stopwatch stopwatch,
    int timeBudgetMs,
  ) {
    // Terminal checks
    if (BoardEvaluator.hasWon(board, aiPlayer)) return BoardEvaluator.winScore;
    if (BoardEvaluator.hasWon(board, aiPlayer.opponent)) return -BoardEvaluator.winScore;
    if (depth <= 0 || stopwatch.elapsedMilliseconds > timeBudgetMs) {
      return BoardEvaluator.evaluate(board, aiPlayer);
    }

    final currentPlayer = isMaximizing ? aiPlayer : aiPlayer.opponent;
    var localAlpha = alpha;
    var localBeta = beta;

    if (isMaximizing) {
      var maxEval = -BoardEvaluator.winScore * 2;

      for (var row = 0; row < GameBoardState.boardSize; row++) {
        for (var col = 0; col < GameBoardState.boardSize; col++) {
          if (!board.canPlaceMarble(row, col)) continue;
          if (stopwatch.elapsedMilliseconds > timeBudgetMs) return maxEval;

          final placed = board.placeMarble(row: row, column: col, player: currentPlayer);

          // Try rotations
          for (final quadrant in Quadrant.values) {
            for (final direction in RotationDirection.values) {
              final rotated = placed.rotateQuadrant(quadrant: quadrant, direction: direction);
              final eval = _minimax(
                rotated, aiPlayer, depth - 1, localAlpha, localBeta, false, stopwatch, timeBudgetMs,
              );
              maxEval = max(maxEval, eval);
              localAlpha = max(localAlpha, eval);
              if (localBeta <= localAlpha) return maxEval;
            }
          }
        }
      }

      return maxEval;
    } else {
      var minEval = BoardEvaluator.winScore * 2;

      for (var row = 0; row < GameBoardState.boardSize; row++) {
        for (var col = 0; col < GameBoardState.boardSize; col++) {
          if (!board.canPlaceMarble(row, col)) continue;
          if (stopwatch.elapsedMilliseconds > timeBudgetMs) return minEval;

          final placed = board.placeMarble(row: row, column: col, player: currentPlayer);

          for (final quadrant in Quadrant.values) {
            for (final direction in RotationDirection.values) {
              final rotated = placed.rotateQuadrant(quadrant: quadrant, direction: direction);
              final eval = _minimax(
                rotated, aiPlayer, depth - 1, localAlpha, localBeta, true, stopwatch, timeBudgetMs,
              );
              minEval = min(minEval, eval);
              localBeta = min(localBeta, eval);
              if (localBeta <= localAlpha) return minEval;
            }
          }
        }
      }

      return minEval;
    }
  }

  static AiRotationDecision _bestRotationAfterPlacement(GameBoardState board, Player player) {
    // After an immediate win from placement, pick a rotation that preserves it
    for (final quadrant in Quadrant.values) {
      for (final direction in RotationDirection.values) {
        final rotated = board.rotateQuadrant(quadrant: quadrant, direction: direction);
        if (BoardEvaluator.hasWon(rotated, player)) {
          return AiRotationDecision(quadrant: quadrant, direction: direction);
        }
      }
    }
    // If no rotation preserves the win, just pick highest-scoring one
    return _mediumRotation(board, player);
  }

  static int _countEmpty(GameBoardState board) {
    var count = 0;
    for (var row = 0; row < GameBoardState.boardSize; row++) {
      for (var col = 0; col < GameBoardState.boardSize; col++) {
        if (board.canPlaceMarble(row, col)) count++;
      }
    }
    return count;
  }
}
