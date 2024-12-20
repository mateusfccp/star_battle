import 'dart:convert';

import 'package:star_battle/src/bidimensional_list.dart';

import 'board.dart';
import 'position.dart';

/// A class that loads a board from a generic source.
abstract interface class BoardLoader<T> {
  /// Loads a board from the given [source].
  Future<Board> loadBoard(T source);
}

/// A board loader that loads a board from a representation string.
///
/// The string must have the following format:
///
/// ```
/// 0 0 1 1 2
/// 0 1 1 2 2
/// 0 1 1 2 2
/// 3 3 4 4 4
/// 3 3 3 4 4
/// ```
///
/// Each integer (from 0 to 9) represents a region on the board.
final class StringBoardLoader implements BoardLoader<String> {
  @override
  Future<Board> loadBoard(String source) async {
    final board = _parseBoard(source);
    final dimension = board.width;
    final regions = <int, Set<Position>>{};

    for (var y = 0; y < dimension; y++) {
      for (var x = 0; x < dimension; x++) {
        final region = board(x, y);
        final position = Position(x, y);

        if (regions[region] case final region?) {
          region.add(position);
        } else {
          regions[region] = {position};
        }
      }
    }

    return Board(
      dimension: dimension,
      regions: [
        for (final region in regions.values) BoardRegion(region),
      ],
    );
  }

  static final _singleDigit = RegExp(r'\b\d\b');

  static BidimensionalList<int> _parseBoard(String source) {
    final lines = LineSplitter.split(source);
    final board = <List<int>>[];

    for (final line in lines) {
      final matches = _singleDigit.allMatches(line);
      board.add([
        for (final match in matches) int.parse(match.group(0)!),
      ]);
    }

    return BidimensionalList.fromRows(board);
  }
}
