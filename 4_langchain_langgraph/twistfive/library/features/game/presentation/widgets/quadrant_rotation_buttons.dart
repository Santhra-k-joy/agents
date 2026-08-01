import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
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
        _buildButton(
          key: ValueKey('rotate-${quadrant.name}-counterclockwise'),
          tooltip: 'Rotate ${_displayNameFor(quadrant)} counter-clockwise',
          icon: Icons.rotate_left,
          onPressed: isEnabled
              ? () => onRotationSelected(RotationDirection.counterclockwise)
              : null,
        ),
        const SizedBox(height: 4),
        _buildButton(
          key: ValueKey('rotate-${quadrant.name}-clockwise'),
          tooltip: 'Rotate ${_displayNameFor(quadrant)} clockwise',
          icon: Icons.rotate_right,
          onPressed: isEnabled
              ? () => onRotationSelected(RotationDirection.clockwise)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton({
    required Key key,
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        key: key,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: AppTheme.gold,
        disabledColor: const Color(0xFF555555),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
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
