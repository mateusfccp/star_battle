import 'package:flutter/material.dart';
import 'package:star_battle/star_battle.dart' hide Board;

import 'board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16.0),
        Text(
          'Star Battle',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder(
                stream: game.onStateChanged,
                builder: (context, snapshot) {
                  return Board(
                    game: game,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: game.reset,
          child: const Text('Reset'),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
