import 'dart:io';
import 'dart:typed_data';

import 'package:star_battle/star_battle.dart';
import 'package:star_battle_file/star_battle_file.dart';

void main() async {
  final thisFile = File(Platform.script.toFilePath());
  final directory = thisFile.parent;
  final file = File('${directory.path}/sample_board');
  final fileHandle = file.openRead().cast<Uint8List>();
  final loader = BoardByteLoader();
  final board = await loader.loadBoard(fileHandle);
  printBoardAsGrid(board);
}

void printBoardAsGrid(Board board) {
  for (var y = 0; y < board.dimension; y++) {
    for (var x = 0; x < board.dimension; x++) {
      final cell = board.cells[x][y];
      stdout.write(cell);
      stdout.write(' ');
    }
    stdout.writeln();
  }
}
