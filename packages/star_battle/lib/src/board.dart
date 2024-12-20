import 'package:meta/meta.dart';
import 'package:star_battle/src/bidimensional_list.dart';

import 'position.dart';

/// A Star Battle board.
final class Board {
  Board({
    required this.dimension,
    required List<BoardRegion> regions,
  })  : assert(
          regions.length > 1,
          'A board must contain at least two regions.',
        ),
        assert(
          checkBoardCompleteness(dimension: dimension, regions: regions),
          'The regions do not cover all possible positions on the board.',
        ),
        regionsMap = regions.asMap(),
        _cells = _computeCells(dimension: dimension, regions: regions),
        _positionRegion = _computePositionRegion(regions: regions);

  /// The dimension of the board.
  ///
  /// The board is a square, so this is the length of both sides.
  final int dimension;

  /// The regions on the board.
  List<BoardRegion> get regions => [...regionsMap.values];

  @visibleForTesting
  final Map<int, BoardRegion> regionsMap;

  /// Returns the region at the given position.
  BoardRegion regionAt(int x, int y) {
    final region = _positionRegion[Position(x, y)];
    assert(region != null, 'No region found at position ($x, $y).');
    return region!;
  }

  final Map<Position, BoardRegion> _positionRegion;

  /// A matrix representation of the board.
  ///
  /// The matrix is a 2D list where each cell contains the index of the region
  /// it belongs to.
  ///
  /// The first index is the x-coordinate and the second is the y-coordinate.
  BidimensionalList<int> get cells => _cells;

  final BidimensionalList<int> _cells;

  static Map<Position, BoardRegion> _computePositionRegion({
    required List<BoardRegion> regions,
  }) {
    final positionRegion = <Position, BoardRegion>{};

    for (final region in regions) {
      for (final position in region.positions) {
        positionRegion[position] = region;
      }
    }

    return positionRegion;
  }

  static BidimensionalList<int> _computeCells({
    required int dimension,
    required List<BoardRegion> regions,
  }) {
    final cells = List.generate(
      dimension,
      (index) => List<int>.filled(dimension, -1),
    );

    for (int i = 0; i < regions.length; i++) {
      for (final position in regions[i].positions) {
        cells[position.y][position.x] = i;
      }
    }

    assert(() {
      final flatCells = cells.expand((row) => row).toList();
      return !flatCells.contains(-1) && flatCells.length == dimension * dimension;
    }());

    return BidimensionalList.fromRows(cells);
  }
}

/// A region on the board.
extension type BoardRegion._(Set<Position> _value) {
  /// Creates a new board region with the given set of positions.
  BoardRegion(Set<Position> positions)
      : assert(
          positions.isNotEmpty,
          'A board region must contain at least one position.',
        ),
        assert(
          checkRegionContiguousness(positions),
          'A board region must be contiguous.',
        ),
        _value = positions;

  /// The positions that make up the board region.
  Set<Position> get positions => this as Set<Position>;

  /// Returns `true` if the board region contains the given position.
  ///
  /// Out of bounds positions are considered to not be contained.
  bool contains(int x, int y) {
    if (x < 0 || x >= 255 || y < 0 || y >= 255) {
      return false;
    } else {
      return _value.contains(Position(x, y));
    }
  }

  /// Returns whether the given position has a neighbor to the west.
  bool hasNeighborWest(int x, int y) => contains(x - 1, y);

  /// Returns whether the given position has a neighbor to the east.
  bool hasNeighborEast(int x, int y) => contains(x + 1, y);

  /// Returns whether the given position has a neighbor to the north.
  bool hasNeighborNorth(int x, int y) => contains(x, y - 1);

  /// Returns whether the given position has a neighbor to the south.
  bool hasNeighborSouth(int x, int y) => contains(x, y + 1);
}

/// Checks if the given set of positions is contiguous.
bool checkRegionContiguousness(Set<Position> positions) {
  assert(positions.isNotEmpty);

  for (final position in positions) {
    final x = position.x;
    final y = position.y;

    if ((x - 1 >= 000 && positions.contains(Position(x - 1, y))) || //
        (x + 1 <= 255 && positions.contains(Position(x + 1, y))) ||
        (y - 1 >= 000 && positions.contains(Position(x, y - 1))) ||
        (y + 1 <= 255 && positions.contains(Position(x, y + 1)))) {
      continue;
    }

    return false;
  }

  return true;
}

/// Whether the [regions] cover all possible positions on a board of the given [dimension].
bool checkBoardCompleteness({
  required int dimension,
  required Iterable<BoardRegion> regions,
}) {
  final positions = {
    for (final region in regions) ...region.positions,
  };

  return positions.length == dimension * dimension;
}
