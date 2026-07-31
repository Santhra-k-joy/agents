import 'package:flutter/material.dart';
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
    final borderRadius = BorderRadius.circular(10);
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
        child: Material(
          color: isWinningCell
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canTap ? () => onTap!(row, column) : null,
            child: Center(
              child: isEmpty
                  ? null
                  : _buildMarble(context, player!, isWinningCell),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarble(
    BuildContext context,
    Player marbleOwner,
    bool isWinningCell,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final marbleColor = marbleOwner == Player.black
        ? colorScheme.onSurface
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: size * 0.7,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: marbleColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isWinningCell ? colorScheme.primary : colorScheme.outline,
          width: isWinningCell ? 3 : 1.5,
        ),
        boxShadow: isWinningCell
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: const SizedBox.shrink(),
    );
  }
}
