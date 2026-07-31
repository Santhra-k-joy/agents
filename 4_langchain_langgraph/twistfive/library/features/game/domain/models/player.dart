enum Player {
  black,
  white;

  Player get opponent {
    return switch (this) {
      Player.black => Player.white,
      Player.white => Player.black,
    };
  }

  String get displayName {
    return switch (this) {
      Player.black => 'Black',
      Player.white => 'White',
    };
  }
}
