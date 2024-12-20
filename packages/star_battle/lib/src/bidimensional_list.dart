import 'dart:collection';

import 'position.dart';

/// A bidimensional list.
final class BidimensionalList<E> {
  /// Creates a new bidimensional list with the given [width] and [height].
  BidimensionalList.generate({
    required int width,
    required int height,
    required E Function(int x, int y) create,
  })  : _rows = [
          for (int y = 0; y < height; y++)
            [
              for (int x = 0; x < width; x++) create(x, y),
            ],
        ],
        _columns = [
          for (int x = 0; x < width; x++)
            [
              for (int y = 0; y < height; y++) create(x, y),
            ],
        ];

  /// Creates a new bidimensional list from the given [rows].
  BidimensionalList.fromRows(List<List<E>> rows)
      : assert(
          rows.every((row) => row.length == rows[0].length),
          'All rows must have the same length.',
        ),
        _rows = rows,
        _columns = [
          for (int x = 0; x < rows[0].length; x++)
            [
              for (int y = 0; y < rows.length; y++) rows[y][x],
            ],
        ];

  /// Returns the row at the given y-coordinate.
  List<E> row(int y) => _rows[y];

  /// Returns the column at the given x-coordinate.
  List<E> column(int x) => _columns[x];

  /// Returns the width of the list.
  int get width => _columns.length;

  /// Returns the height of the list.
  int get height => _rows.length;

  /// The rows of the list.
  UnmodifiableListView<List<E>> get rows => UnmodifiableListView(_rows);
  final List<List<E>> _rows;

  /// The columns of the list.
  UnmodifiableListView<List<E>> get columns => UnmodifiableListView(_columns);
  final List<List<E>> _columns;

  /// Returns the element at the given position.
  E call(int x, int y) => _columns[x][y];

  /// Updates the element at the given position.
  void set(int x, int y, E value) {
    _rows[y][x] = value;
    _columns[x][y] = value;
  }

  /// Returns a list of positions where the elements satisfy the given [test].
  List<Position> where(bool Function(E) test) {
    final positions = <Position>[];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (test(this(x, y))) {
          positions.add(Position(x, y));
        }
      }
    }

    return positions;
  }
}
