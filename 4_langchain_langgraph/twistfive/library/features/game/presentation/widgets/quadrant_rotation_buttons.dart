import 'package:flutter/material.dart';
import 'package:twistfive/features/game/domain/models/rotation.dart';

class QuadrantRotationButtons extends StatelessWidget {
  const QuadrantRotationButtons({
    required this.quadrant,
    required this.isEnabled,
    required this.onRotationSelected,
    super.key,
  });

  final Quadrant quadrant;
  final bool isEnabled;
  final ValueChanged<RotationDirection> onRotationSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          key: ValueKey('rotate-${quadrant.name}-counterclockwise'),
          tooltip: 'Rotate ${_displayNameFor(quadrant)} counter-clockwise',
          onPressed: isEnabled
              ? () => onRotationSelected(RotationDirection.counterclockwise)
              : null,
          icon: const Icon(Icons.rotate_left),
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        ),
        const SizedBox(height: 4),
        IconButton.filledTonal(
          key: ValueKey('rotate-${quadrant.name}-clockwise'),
          tooltip: 'Rotate ${_displayNameFor(quadrant)} clockwise',
          onPressed: isEnabled
              ? () => onRotationSelected(RotationDirection.clockwise)
              : null,
          icon: const Icon(Icons.rotate_right),
          iconSize: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        ),
      ],
    );
  }

  String _displayNameFor(Quadrant quadrant) {
    return switch (quadrant) {
      Quadrant.topLeft => 'top left quadrant',
      Quadrant.topRight => 'top right quadrant',
      Quadrant.bottomLeft => 'bottom left quadrant',
      Quadrant.bottomRight => 'bottom right quadrant',
    };
  }
}
