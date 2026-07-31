enum GameDifficulty {
  easy,
  medium,
  hard;

  String get label {
    return switch (this) {
      GameDifficulty.easy => 'Easy',
      GameDifficulty.medium => 'Medium',
      GameDifficulty.hard => 'Hard',
    };
  }
}
