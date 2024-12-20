import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Represents a position in a 2D space.
///
/// The position is represented by two integers, [x] and [y].
final class Position {
  /// Creates a new position with the given [x] and [y] coordinates.
  ///
  /// As the position is stored in a [ByteData] with a length of 2, the values
  /// of [x] and [y] must be between 0 and 255, inclusive.
  ///
  /// Any value outside of this range will be clamped to the nearest bound.
  Position(int x, int y)
      : assert(
          !x.isNegative && !y.isNegative,
          'Position values must be non-negative.',
        ),
        internalValue = ByteData(2)
          ..setUint8(0, x)
          ..setUint8(1, y);

  @visibleForTesting
  final ByteData internalValue;

  /// The x-coordinate of the position.
  int get x => internalValue.getUint8(0);

  /// The y-coordinate of the position.
  int get y => internalValue.getUint8(1);

  /// Gets the neighbors of this position.
  ///
  /// The neighbors are the positions that surrounds this position, including
  /// the diagonals.
  ///
  /// If a neighbor is outside of the bounds of the board, it will not be
  /// included in the list.
  Iterable<Position> neighbors({int? xbound, int? ybound}) sync* {
    final horizontalBound = min(xbound ?? 255, 255);
    final verticalBound = min(ybound ?? 255, 255);
    for (final dx in [-1, 0, 1]) {
      for (final dy in [-1, 0, 1]) {
        if (dx == 0 && dy == 0) {
          continue;
        }

        final x = this.x + dx;
        final y = this.y + dy;

        if (x >= 0 && x < horizontalBound && y >= 0 && y < verticalBound) {
          yield Position(x, y);
        }
      }
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.internalValue.getUint16(0) == internalValue.getUint16(0);
  }

  @override
  int get hashCode => internalValue.getUint16(0).hashCode;

  @override
  String toString() => 'Position(x: $x, y: $y)';
}
