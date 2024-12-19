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
          'Queens',
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
                    state: game.state,
                    board: game.board,
                    onTapCell: _onTapCell,
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

  void _onTapCell(int x, int y) {
    return switch (game.cellStateAt(x, y)) {
      CellState.empty => game.markCell(x, y),
      CellState.marked => game.addStar(x, y),
      CellState.star => game.removeStar(x, y),
    };
  }
}