import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twistfive/features/game/domain/models/game_difficulty.dart';
import 'package:twistfive/features/game/domain/models/game_state.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';
import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/services/ai_player.dart';
import 'package:twistfive/features/game/presentation/widgets/game_board.dart';
import 'package:twistfive/features/game/presentation/widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = GameState.initial();
  bool _isVsAi = false;
  GameDifficulty _difficulty = GameDifficulty.medium;

  void _handleCellTap(int row, int column) {
    _updateGameState(_gameState.placeMarble(row, column));
  }

  void _completeRotation(Quadrant quadrant, RotationDirection direction) {
    _updateGameState(
      _gameState.rotateQuadrant(quadrant: quadrant, direction: direction),
    );
  }

  void _updateGameState(GameState updatedGameState) {
    if (identical(updatedGameState, _gameState)) {
      return;
    }

    setState(() {
      _gameState = updatedGameState;
    });

    if (updatedGameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverDialog(updatedGameState.status);
        }
      });
      return;
    }

    if (_isVsAi && updatedGameState.currentPlayer == Player.white) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _gameState.isGameOver || !_isVsAi) {
          return;
        }

        Future<void>.delayed(const Duration(milliseconds: 700), () {
          if (!mounted || _gameState.isGameOver || !_isVsAi) {
            return;
          }

          if (_gameState.isPlacementPhase) {
            final move = AiPlayer.choosePlacement(
              board: _gameState.board,
              player: Player.white,
              difficulty: _difficulty,
            );

            _handleCellTap(move.row, move.column);
            return;
          }

          final rotation = AiPlayer.chooseRotation(
            board: _gameState.board,
            player: Player.white,
            difficulty: _difficulty,
          );

          _completeRotation(rotation.quadrant, rotation.direction);
        });
      });
    }
  }

  void _restartGame() {
    setState(() {
      _gameState = GameState.initial();
    });
  }

  void _toggleAi() {
    setState(() {
      _isVsAi = !_isVsAi;
      _gameState = GameState.initial();
    });
  }

  void _selectDifficulty(GameDifficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
    });
  }

  void _showGameOverDialog(GameStatus status) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          GameOverDialog(status: status, onRestart: _restartGame),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _gameState.currentPlayer;
    final isPlacementPhase = _gameState.isPlacementPhase;

    return Scaffold(
      appBar: AppBar(title: const Text('TwistFive')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _gameState.isGameOver
                          ? 'Game over'
                          : isPlacementPhase
                          ? '${currentPlayer.displayName}: place a marble'
                          : '${currentPlayer.displayName}: rotate a quadrant',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SegmentedButton<GameDifficulty>(
                    segments: const [
                      ButtonSegment(
                        value: GameDifficulty.easy,
                        label: Text('Easy'),
                      ),
                      ButtonSegment(
                        value: GameDifficulty.medium,
                        label: Text('Med'),
                      ),
                      ButtonSegment(
                        value: GameDifficulty.hard,
                        label: Text('Hard'),
                      ),
                      ButtonSegment(
                        value: GameDifficulty.extremeHard,
                        label: Text('Extreme'),
                      ),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (selection) {
                      _selectDifficulty(selection.first);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_isVsAi ? 'AI opponent: on' : 'AI opponent: off'),
                  FilledButton.tonal(
                    onPressed: _toggleAi,
                    child: Text(_isVsAi ? 'Disable AI' : 'Play vs AI'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GameBoard(
                  board: _gameState.board,
                  onCellTapped: isPlacementPhase && !_gameState.isGameOver
                      ? _handleCellTap
                      : null,
                  onRotationCompleted:
                      _gameState.isRotationPhase && !_gameState.isGameOver
                      ? _completeRotation
                      : null,
                  winningLine: _gameState.winningLine,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
