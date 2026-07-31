import 'package:twistfive/features/game/domain/models/player.dart';

enum GameStatus {
  inProgress,
  blackWins,
  whiteWins,
  draw;

  bool get isFinished => this != GameStatus.inProgress;

  Player? get winner {
    return switch (this) {
      GameStatus.blackWins => Player.black,
      GameStatus.whiteWins => Player.white,
      GameStatus.inProgress || GameStatus.draw => null,
    };
  }
}
