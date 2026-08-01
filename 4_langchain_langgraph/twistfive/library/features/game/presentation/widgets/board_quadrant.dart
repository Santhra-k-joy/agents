import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/rules/game_result_resolver.dart';
import 'package:twistfive/features/game/presentation/widgets/board_cell.dart';

class BoardQuadrant extends StatelessWidget {
  const BoardQuadrant({
    required this.quadrant,
    required this.board,
    required this.cellSize,
    required this.cellGap,
    required this.onCellTapped,
    this.winningLine,
    super.key,
  });

  final Quadrant quadrant;
  final GameBoardState board;
  final double cellSize;
  final double cellGap;
  final void Function(int row, int column)? onCellTapped;
  final WinningLine? winningLine;

  @override
  Widget build(BuildContext context) {
    final quadrantSize =
        (cellSize * GameBoardState.quadrantSize) + (cellGap * 2);

    return Container(
      width: quadrantSize,
      height: quadrantSize,
      decoration: BoxDecoration(
        color: AppTheme.boardWood,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (
            var rowOffset = 0;
            rowOffset < GameBoardState.quadrantSize;
            rowOffset++
          ) ...[
            SizedBox(
              height: cellSize,
              child: Row(children: _buildRow(rowOffset)),
            ),
            if (rowOffset < GameBoardState.quadrantSize - 1)
              SizedBox(height: cellGap),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRow(int rowOffset) {
    return [
      for (
        var columnOffset = 0;
        columnOffset < GameBoardState.quadrantSize;
        columnOffset++
      ) ...[
        if (columnOffset > 0) SizedBox(width: cellGap),
        BoardCell(
          key: ValueKey(
            'board-cell-${quadrant.startRow + rowOffset}-'
            '${quadrant.startColumn + columnOffset}',
          ),
          row: quadrant.startRow + rowOffset,
          column: quadrant.startColumn + columnOffset,
          size: cellSize,
          player: board.marbleAt(
            quadrant.startRow + rowOffset,
            quadrant.startColumn + columnOffset,
          ),
          onTap: onCellTapped,
          isWinningCell:
              winningLine?.cells.contains((
                quadrant.startRow + rowOffset,
                quadrant.startColumn + columnOffset,
              )) ??
              false,
        ),
      ],
    ];
  }
}
