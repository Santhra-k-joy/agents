import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/domain/models/game_difficulty.dart';
import 'package:twistfive/features/game/presentation/screens/game_screen.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  GameDifficulty _selected = GameDifficulty.hard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Pick a level',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'The rules never change \u2014 only how well the computer plays.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ...GameDifficulty.values.map(
                (difficulty) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DifficultyCard(
                    difficulty: difficulty,
                    isSelected: _selected == difficulty,
                    onTap: () {
                      setState(() => _selected = difficulty);
                      Future<void>.delayed(
                        const Duration(milliseconds: 200),
                        () {
                          if (!mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                              builder: (_) => GameScreen(
                                isVsAi: true,
                                difficulty: difficulty,
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  final GameDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : const Color(0xFF444444),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.gold : AppTheme.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleFor(difficulty),
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildStrengthBars(difficulty),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthBars(GameDifficulty difficulty) {
    final filledBars = switch (difficulty) {
      GameDifficulty.easy => 1,
      GameDifficulty.medium => 2,
      GameDifficulty.hard => 3,
      GameDifficulty.extremeHard => 4,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isFilled = index < filledBars;
        return Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Container(
            width: 5,
            height: 12 + (index * 4).toDouble(),
            decoration: BoxDecoration(
              color: isFilled ? const Color(0xFF888888) : const Color(0xFF444444),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  String _subtitleFor(GameDifficulty difficulty) {
    return switch (difficulty) {
      GameDifficulty.easy => 'Learns the ropes with you',
      GameDifficulty.medium => 'Blocks the obvious lines',
      GameDifficulty.hard => 'Reads two moves ahead',
      GameDifficulty.extremeHard => 'Twists your lines apart',
    };
  }
}
