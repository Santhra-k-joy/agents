enum GameDifficulty {
  easy,
  medium,
  hard,
  extremeHard;

  String get label {
    return switch (this) {
      GameDifficulty.easy => 'Easy',
      GameDifficulty.medium => 'Medium',
      GameDifficulty.hard => 'Hard',
      GameDifficulty.extremeHard => 'Extreme',
    };
  }
}
