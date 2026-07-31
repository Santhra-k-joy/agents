enum Quadrant {
  topLeft(startRow: 0, startColumn: 0),
  topRight(startRow: 0, startColumn: 3),
  bottomLeft(startRow: 3, startColumn: 0),
  bottomRight(startRow: 3, startColumn: 3);

  const Quadrant({required this.startRow, required this.startColumn});

  final int startRow;
  final int startColumn;
}

enum RotationDirection { clockwise, counterclockwise }
