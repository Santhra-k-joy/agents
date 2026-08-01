import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    required this.status,
    this.onRestart,
    this.onHome,
    super.key,
  });

  final GameStatus status;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBg,
      title: Text(
        _titleFor(status),
        style: const TextStyle(color: AppTheme.cream),
      ),
      content: Text(
        _messageFor(status),
        style: const TextStyle(color: Color(0xFF999999)),
      ),
      actions: [
        if (onHome != null)
          TextButton(
            onPressed: onHome,
            child: const Text('Home', style: TextStyle(color: Color(0xFF888888))),
          ),
        if (onRestart != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart?.call();
            },
            child: const Text('Play again'),
          ),
      ],
    );
  }

  String _titleFor(GameStatus gameStatus) {
    return switch (gameStatus) {
      GameStatus.blackWins => 'Black wins!',
      GameStatus.whiteWins => 'White wins!',
      GameStatus.draw => 'Draw',
      GameStatus.inProgress => 'Game in progress',
    };
  }

  String _messageFor(GameStatus gameStatus) {
    return switch (gameStatus) {
      GameStatus.blackWins || GameStatus.whiteWins =>
        'Five marbles are connected in a row.',
      GameStatus.draw =>
        'Both players formed five in a row, or the board is full.',
      GameStatus.inProgress => 'The game is still in progress.',
    };
  }
}
