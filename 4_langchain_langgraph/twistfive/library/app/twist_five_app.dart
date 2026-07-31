import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/presentation/screens/game_screen.dart';

class TwistFiveApp extends StatelessWidget {
  const TwistFiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwistFive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const GameScreen(),
    );
  }
}
