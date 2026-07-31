import 'package:flutter/material.dart';
import 'package:twistfive/features/game/domain/models/game_status.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    required this.status,
    this.onRestart,
    super.key,
  });

  final GameStatus status;
  final VoidCallback? onRestart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_titleFor(status)),
      content: Text(_messageFor(status)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (onRestart != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart?.call();
            },
            child: const Text('Restart'),
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
