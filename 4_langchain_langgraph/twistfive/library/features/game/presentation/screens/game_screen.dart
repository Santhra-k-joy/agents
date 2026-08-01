import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/game_difficulty.dart';
import 'package:twistfive/features/game/domain/models/game_state.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';
import 'package:twistfive/features/game/domain/models/player.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/services/ai_player.dart';
import 'package:twistfive/features/game/presentation/screens/landing_screen.dart';
import 'package:twistfive/features/game/presentation/widgets/game_board.dart';
import 'package:twistfive/features/game/presentation/widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.isVsAi,
    this.difficulty = GameDifficulty.medium,
    super.key,
  });

  final bool isVsAi;
  final GameDifficulty difficulty;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = GameState.initial();

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

    if (widget.isVsAi && updatedGameState.currentPlayer == Player.white) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _gameState.isGameOver || !widget.isVsAi) {
          return;
        }

        Future<void>.delayed(const Duration(milliseconds: 700), () {
          if (!mounted || _gameState.isGameOver || !widget.isVsAi) {
            return;
          }

          if (_gameState.isPlacementPhase) {
            final move = AiPlayer.choosePlacement(
              board: _gameState.board,
              player: Player.white,
              difficulty: widget.difficulty,
            );

            _handleCellTap(move.row, move.column);
            return;
          }

          final rotation = AiPlayer.chooseRotation(
            board: _gameState.board,
            player: Player.white,
            difficulty: widget.difficulty,
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

  void _showGameOverDialog(GameStatus status) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        status: status,
        onRestart: _restartGame,
        onHome: () {
          Navigator.of(context).pop();
          Navigator.of(this.context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = _gameState.currentPlayer;
    final isPlacementPhase = _gameState.isPlacementPhase;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TwistFive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusBar(context, currentPlayer, isPlacementPhase),
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

  Widget _buildStatusBar(
    BuildContext context,
    Player currentPlayer,
    bool isPlacementPhase,
  ) {
    final statusText = _gameState.isGameOver
        ? 'Game over'
        : isPlacementPhase
            ? '${currentPlayer.displayName}: place a marble'
            : '${currentPlayer.displayName}: rotate a quadrant';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: currentPlayer == Player.black
                  ? const Color(0xFF555555)
                  : AppTheme.cream,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.gold, width: 1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(color: AppTheme.cream, fontSize: 15),
            ),
          ),
          if (widget.isVsAi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF444444)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.difficulty.label,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
