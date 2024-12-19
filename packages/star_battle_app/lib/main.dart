import 'package:flutter/material.dart';
import 'package:star_battle/star_battle.dart';

import 'ui/game_screen.dart';

const _board = '''
0 0 1 1 2
0 1 1 2 2
0 1 1 2 2
3 3 4 4 4
3 3 3 4 4
''';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Game game;
  
  @override
  void initState() {
    super.initState();
    final board = StringBoardLoader().loadBoard(_board);
    game = Game(board: board);
  }
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: GameScreen(game: game),
        ),
      ),
    );
  }
}
