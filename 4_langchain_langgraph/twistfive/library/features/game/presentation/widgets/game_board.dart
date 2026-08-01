import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/game_board_state.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';
import 'package:twistfive/features/game/domain/rules/game_result_resolver.dart';
import 'package:twistfive/features/game/presentation/widgets/board_quadrant.dart';
import 'package:twistfive/features/game/presentation/widgets/quadrant_rotation_buttons.dart';

typedef CellTapCallback = void Function(int row, int column);
typedef RotationCompletedCallback =
    void Function(Quadrant quadrant, RotationDirection direction);

class GameBoard extends StatefulWidget {
  const GameBoard({
    required this.board,
    required this.onCellTapped,
    this.onRotationCompleted,
    this.winningLine,
    super.key,
  });

  final GameBoardState board;
  final CellTapCallback? onCellTapped;
  final RotationCompletedCallback? onRotationCompleted;
  final WinningLine? winningLine;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  static const double _boardPadding = 8;
  static const double _cellGap = 4;
  static const double _quadrantGap = 12;
  static const double _controlWidth = 40;
  static const double _controlGap = 4;
  static const Duration _rotationDuration = Duration(milliseconds: 300);

  late final AnimationController _rotationController;
  late final Animation<double> _rotationProgress;
  _RotationRequest? _activeRotation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: _rotationDuration,
    )..addStatusListener(_handleAnimationStatus);
    _rotationProgress = CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _startRotation(Quadrant quadrant, RotationDirection direction) {
    if (widget.onRotationCompleted == null || _activeRotation != null) {
      return;
    }

    setState(() {
      _activeRotation = _RotationRequest(
        quadrant: quadrant,
        direction: direction,
      );
    });
    _rotationController.forward(from: 0);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _activeRotation == null) {
      return;
    }

    final completedRotation = _activeRotation!;
    setState(() {
      _activeRotation = null;
    });
    widget.onRotationCompleted?.call(
      completedRotation.quadrant,
      completedRotation.direction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - (_boardPadding * 2);
        final availableHeight = constraints.maxHeight - (_boardPadding * 2);
        final maxQuadrantWidth =
            (availableWidth -
                (_controlWidth * 2) -
                (_controlGap * 2) -
                _quadrantGap) /
            2;
        final maxQuadrantHeight = (availableHeight - _quadrantGap) / 2;
        final quadrantSize = math.min(maxQuadrantWidth, maxQuadrantHeight);
        final cellSize =
            (quadrantSize - (_cellGap * 2)) / GameBoardState.quadrantSize;
        final layoutWidth =
            (quadrantSize * 2) +
            _quadrantGap +
            (_controlWidth * 2) +
            (_controlGap * 2);
        final layoutHeight = (quadrantSize * 2) + _quadrantGap;

        return Center(
          child: SizedBox(
            width: layoutWidth + (_boardPadding * 2),
            height: layoutHeight + (_boardPadding * 2),
            child: Padding(
              padding: const EdgeInsets.all(_boardPadding),
              child: Column(
                children: [
                  _buildQuadrantRow(
                    leftQuadrant: Quadrant.topLeft,
                    rightQuadrant: Quadrant.topRight,
                    cellSize: cellSize,
                  ),
                  const SizedBox(height: _quadrantGap),
                  _buildQuadrantRow(
                    leftQuadrant: Quadrant.bottomLeft,
                    rightQuadrant: Quadrant.bottomRight,
                    cellSize: cellSize,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuadrantRow({
    required Quadrant leftQuadrant,
    required Quadrant rightQuadrant,
    required double cellSize,
  }) {
    final quadrantSize =
        (cellSize * GameBoardState.quadrantSize) + (_cellGap * 2);
    final controlsEnabled =
        widget.onRotationCompleted != null && _activeRotation == null;

    return SizedBox(
      height: quadrantSize,
      child: Row(
        children: [
          SizedBox(
            width: _controlWidth,
            child: QuadrantRotationButtons(
              quadrant: leftQuadrant,
              isEnabled: controlsEnabled,
              onRotationSelected: (direction) {
                _startRotation(leftQuadrant, direction);
              },
            ),
          ),
          const SizedBox(width: _controlGap),
          _buildAnimatedQuadrant(leftQuadrant, cellSize),
          const SizedBox(width: _quadrantGap),
          _buildAnimatedQuadrant(rightQuadrant, cellSize),
          const SizedBox(width: _controlGap),
          SizedBox(
            width: _controlWidth,
            child: QuadrantRotationButtons(
              quadrant: rightQuadrant,
              isEnabled: controlsEnabled,
              onRotationSelected: (direction) {
                _startRotation(rightQuadrant, direction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedQuadrant(Quadrant quadrant, double cellSize) {
    final boardQuadrant = BoardQuadrant(
      quadrant: quadrant,
      board: widget.board,
      cellSize: cellSize,
      cellGap: _cellGap,
      onCellTapped: widget.onCellTapped,
      winningLine: widget.winningLine,
    );
    final activeRotation = _activeRotation;

    if (activeRotation?.quadrant != quadrant) {
      return boardQuadrant;
    }

    final endTurns = activeRotation!.direction == RotationDirection.clockwise
        ? 0.25
        : -0.25;

    return RotationTransition(
      turns: Tween<double>(begin: 0, end: endTurns).animate(_rotationProgress),
      child: boardQuadrant,
    );
  }
}

class _RotationRequest {
  const _RotationRequest({required this.quadrant, required this.direction});

  final Quadrant quadrant;
  final RotationDirection direction;
}
