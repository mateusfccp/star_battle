import 'package:star_battle/star_battle.dart';
import 'package:test/test.dart';

const _board = '''
0 0 1 1 2
0 1 1 2 2
0 1 1 2 2
3 3 4 4 4
3 3 3 4 4
''';

void main() {
  test(
    "'StringBoardLoader' should load a string board file with the expected format.",
    () async {
      final loader = StringBoardLoader();
      final board = await loader.loadBoard(_board);

      expect(
        board.dimension,
        equals(5),
      );

      expect(
        board.regions,
        equals({
          0: BoardRegion({
            Position(0, 0),
            Position(1, 0),
            Position(0, 1),
            Position(0, 2),
          }),
          1: BoardRegion({
            Position(2, 0),
            Position(3, 0),
            Position(1, 1),
            Position(2, 1),
            Position(1, 2),
            Position(2, 2),
          }),
          2: BoardRegion({
            Position(4, 0),
            Position(3, 1),
            Position(4, 1),
            Position(3, 2),
            Position(4, 2),
          }),
          3: BoardRegion({
            Position(0, 3),
            Position(1, 3),
            Position(0, 4),
            Position(1, 4),
            Position(2, 4),
          }),
          4: BoardRegion({
            Position(2, 3),
            Position(3, 3),
            Position(4, 3),
            Position(3, 4),
            Position(4, 4),
          }),
        }),
      );
    },
  );
}
