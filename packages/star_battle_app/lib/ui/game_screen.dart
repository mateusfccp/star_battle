import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:star_battle/star_battle.dart' hide Board;

import 'board.dart';

final _controlKey = Platform.isMacOS //
    ? LogicalKeyboardKey.meta
    : LogicalKeyboardKey.control;

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(_controlKey, LogicalKeyboardKey.keyZ): _undo,
        LogicalKeySet(_controlKey, LogicalKeyboardKey.keyY): _redo,
      },
      child: Focus(
        autofocus: true,
        child: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16.0),
                StreamBuilder(
                  stream: game.onStateChanged,
                  builder: (context, snapshot) {
                    return IconButton.filled(
                      tooltip: 'Undo',
                      icon: const Icon(Icons.undo),
                      onPressed: game.canUndo ? _undo : null,
                    );
                  },
                ),
                const SizedBox(width: 16.0),
                StreamBuilder(
                  stream: game.onStateChanged,
                  builder: (context, snapshot) {
                    return IconButton.filled(
                      tooltip: 'Redo',
                      icon: const Icon(Icons.redo),
                      onPressed: game.canRedo ? _redo : null,
                    );
                  },
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: game.reset,
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  void _redo() {
    if (game.canRedo) {
      game.redo();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _undo() {
    if (game.canUndo) {
      game.undo();
    } else {
      HapticFeedback.mediumImpact();
    }
  }
}
