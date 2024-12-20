import 'package:flutter/material.dart';
import 'package:star_battle/star_battle.dart';

import 'ui/game_screen.dart';

const _board = '''
0 1 1 1 1
0 2 2 2 1
0 0 3 3 1
0 0 4 3 1
0 0 4 4 4
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
  Game? game;
  
  @override
  void initState() {
    super.initState();

    () async{
      final board = await StringBoardLoader().loadBoard(_board);
      if (context.mounted) {
        setState(() {
          game = Game(board: board);
        });
      }
    }();
  }
  
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: game == null //
              ? const CircularProgressIndicator()
              : GameScreen(game: game!),
        ),
      ),
    );
  }
}
