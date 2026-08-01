import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/player.dart';

class BoardCell extends StatelessWidget {
  const BoardCell({
    required this.row,
    required this.column,
    required this.size,
    required this.player,
    required this.onTap,
    this.isWinningCell = false,
    super.key,
  });

  final int row;
  final int column;
  final double size;
  final Player? player;
  final void Function(int row, int column)? onTap;
  final bool isWinningCell;

  @override
  Widget build(BuildContext context) {
    final isEmpty = player == null;
    final canTap = isEmpty && onTap != null;

    return SizedBox.square(
      dimension: size,
      child: Semantics(
        button: canTap,
        enabled: canTap,
        label: isEmpty
            ? 'Empty cell, row ${row + 1}, column ${column + 1}'
            : '${player!.displayName} marble, row ${row + 1}, '
                  'column ${column + 1}',
        child: GestureDetector(
          onTap: canTap ? () => onTap!(row, column) : null,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A1F14),
              shape: BoxShape.circle,
              border: isWinningCell
                  ? Border.all(color: AppTheme.gold, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isEmpty ? null : _buildMarble(player!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarble(Player marbleOwner) {
    final isWhite = marbleOwner == Player.white;
    final baseColor = isWhite ? AppTheme.cream : const Color(0xFF555555);

    return Container(
      width: size * 0.72,
      height: size * 0.72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            isWhite ? Colors.white : const Color(0xFF888888),
            baseColor,
            isWhite ? const Color(0xFFCCC0A8) : const Color(0xFF333333),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
          if (isWinningCell)
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
    );
  }
}
