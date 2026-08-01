import 'package:flutter/material.dart';
import 'package:twistfive/app/theme/app_theme.dart';
import 'package:twistfive/features/game/presentation/screens/mode_selection_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Board preview
              SizedBox(
                width: 200,
                height: 200,
                child: _buildBoardPreview(),
              ),
              const SizedBox(height: 48),
              Text(
                'Five in a row.\nThen the board turns.',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Place a marble, twist a block.\nSimple to learn, hard to hold on to.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ModeSelectionScreen(),
                      ),
                    );
                  },
                  child: const Text('Play'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardPreview() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.boardWood,
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            padding: const EdgeInsets.all(6),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(9, (cellIndex) {
              final hasMarble = _previewMarbles[index]?.contains(cellIndex) ?? false;
              final isWhite = _previewWhite[index]?.contains(cellIndex) ?? false;
              return Container(
                decoration: BoxDecoration(
                  color: hasMarble
                      ? (isWhite ? AppTheme.cream : const Color(0xFF555555))
                      : const Color(0xFF2A2016),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // Pre-defined marble positions for the preview board
  static const _previewMarbles = <int, Set<int>>{
    0: {1, 3, 4},
    1: {2, 4},
    2: {0, 6},
    3: {4, 7},
  };

  static const _previewWhite = <int, Set<int>>{
    0: {3, 4},
    1: {4},
    2: {6},
    3: {4},
  };
}
