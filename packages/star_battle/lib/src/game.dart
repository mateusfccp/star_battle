import 'dart:async';

import 'package:collection/collection.dart';
import 'package:star_battle/src/bidimensional_list.dart';

import 'board.dart';
import 'position.dart';

/// An instance of a Star Battle game.
final class Game {
  /// Creates a new game with the given [board].
  Game({required this.board})
      : _cachedBoardContent = _createEmptyContent(board.dimension),
        _cachedBoardStatus = _createEmptyStatus(board.dimension),
        _startTime = DateTime.now();

  /// A stream that emits whenever the game state changes.
  Stream<void> get onStateChanged => _stateController.stream;
  final _stateController = StreamController<void>.broadcast();

  /// The board where the game is being played.
  final Board board;

  /// The time when the game started.
  DateTime get startTime => _startTime;
  DateTime _startTime;

  /// The current state of the game board.
  BidimensionalList<CellState> get state {
    final rows = [
      for (var y = 0; y < board.dimension; y++)
        [
          for (var x = 0; x < board.dimension; x++)
            (
              content: _cachedBoardContent(x, y),
              status: _cachedBoardStatus(x, y),
            ),
        ],
    ];

    return BidimensionalList.fromRows(rows);
  }

  BidimensionalList<CellStatus> _cachedBoardStatus;
  BidimensionalList<CellContent> _cachedBoardContent;

  /// Whether the last action can be undone.
  ///
  /// This will only be `false` if the game has just started, i.e. no actions
  /// have been performed yet.
  bool get canUndo => _events.isNotEmpty;
  final _events = QueueList<GameEvent>();

  /// Whether the last undone action can be redone.
  ///
  /// Every time an action is undone, it is added to a redo stack. This stack
  /// is kept until a new action is performed, at which point it is cleared.
  bool get canRedo => _redoEvents.isNotEmpty;
  final _redoEvents = QueueList<GameEvent>();

  /// Resets the game to its initial state.
  void reset() {
    _events.clear();
    _redoEvents.clear();
    _cachedBoardContent = _createEmptyContent(board.dimension);
    _startTime = DateTime.now();
    _stateController.add(null);
  }

  /// Adds a star to the board at the given position.
  void placeStar(int x, int y) {
    final position = Position(x, y);
    final event = PlaceStar(position);
    _addEvent(event);
  }

  /// Marks a cell on the board at the given position.
  void markCell(int x, int y) {
    final position = Position(x, y);
    final event = MarkCell(position);
    _addEvent(event);
  }

  /// Clears a cell on the board at the given position.
  void clearCell(int x, int y) {
    final position = Position(x, y);
    final event = ClearCell(position);
    _addEvent(event);
  }

  /// Undoes the last action performed on the game.
  void undo() {
    if (!canUndo) return;

    final event = _events.removeLast();
    _redoEvents.add(event);
    _cachedBoardContent = _computeContent();
    _cachedBoardStatus = _computeStatus();
    _stateController.add(null);
  }

  /// Redoes the last action that was undone.
  void redo() {
    if (!canRedo) return;

    final event = _redoEvents.removeLast();
    _events.add(event);
    _cachedBoardContent = _computeContent(
      initialContent: _cachedBoardContent,
      from: _events.length - 1,
    );
    _cachedBoardStatus = _computeStatus();
    _stateController.add(null);
  }

  void _addEvent(GameEvent event) {
    _redoEvents.clear();
    _events.add(event);
    _cachedBoardContent = _computeContent(
      initialContent: _cachedBoardContent,
      from: _events.length - 1,
    );
    _cachedBoardStatus = _computeStatus();
    _stateController.add(null);
  }

  BidimensionalList<CellContent> _computeContent({
    BidimensionalList<CellContent>? initialContent,
    int from = 0,
  }) {
    final BidimensionalList<CellContent> content;

    if (initialContent == null) {
      content = _createEmptyContent(board.dimension);
    } else {
      content = BidimensionalList.fromRows(initialContent.rows);
    }

    for (var i = from; i < _events.length; i++) {
      final event = _events[i];

      final Position(:x, :y) = event.position;

      switch (event) {
        case PlaceStar():
          assert(content(x, y) != CellContent.star);
          content.set(x, y, CellContent.star);
        case MarkCell():
          assert(content(x, y) != CellContent.marked);
          content.set(x, y, CellContent.marked);
        case ClearCell():
          assert(content(x, y) != CellContent.empty);
          content.set(x, y, CellContent.empty);
      }
    }

    return content;
  }

  BidimensionalList<CellStatus> _computeStatus() {
    final status = _createEmptyStatus(board.dimension);

    // Compute columns
    for (int x = 0; x < board.dimension; x++) {
      final column = _cachedBoardContent.column(x);
      final stars = column.where((cell) => cell == CellContent.star);
      if (stars.length > 1) {
        for (int y = 0; y < board.dimension; y++) {
          if (_cachedBoardContent(x, y) == CellContent.star) {
            status.set(x, y, CellStatus.invalid);
          }
        }
      }
    }

    // Compute rows
    for (int y = 0; y < board.dimension; y++) {
      final row = _cachedBoardContent.row(y);
      if (row.where((cell) => cell == CellContent.star).length > 1) {
        for (int x = 0; x < board.dimension; x++) {
          if (_cachedBoardContent(x, y) == CellContent.star) {
            status.set(x, y, CellStatus.invalid);
          }
        }
      }
    }

    // Compute regions
    for (final region in board.regions) {
      final stars = region.positions.where(
        (position) => _cachedBoardContent(position.x, position.y) == CellContent.star,
      );

      if (stars.length > 1) {
        for (final position in region.positions) {
          if (_cachedBoardContent(position.x, position.y) == CellContent.star) {
            status.set(position.x, position.y, CellStatus.invalid);
          }
        }
      }
    }

    // Compute star surrounded cells
    for (final star in _cachedBoardContent.where((cell) => cell == CellContent.star)) {
      for (final neighbor in star.neighbors(xbound: board.dimension, ybound: board.dimension)) {
        if (_cachedBoardContent(neighbor.x, neighbor.y) == CellContent.star) {
          status.set(star.x, star.y, CellStatus.invalid);
          status.set(neighbor.x, neighbor.y, CellStatus.invalid);
        }
      }
    }

    return status;
  }
}

@pragma('vm:prefer-inline')
BidimensionalList<CellContent> _createEmptyContent(int dimension) {
  return BidimensionalList<CellContent>.generate(
    width: dimension,
    height: dimension,
    create: (x, y) => CellContent.empty,
  );
}

@pragma('vm:prefer-inline')
BidimensionalList<CellStatus> _createEmptyStatus(int dimension) {
  return BidimensionalList<CellStatus>.generate(
    width: dimension,
    height: dimension,
    create: (x, y) => CellStatus.valid,
  );
}

/// The state of a cell on the board.
typedef CellState = ({CellContent content, CellStatus status});

/// The possible contents of a cell on the board.
enum CellContent {
  /// An empty cell.
  empty,

  /// A cell with a star.
  star,

  /// A cell that has been marked.
  marked,
}

/// The validity status of a cell on the board.
enum CellStatus {
  /// The cell is in an invalid state.
  invalid,

  /// The cell is in a valid state.
  valid,
}

/// An action that can be performed on the game.
sealed class GameEvent {
  /// The position where the event will be performed.
  Position get position;
}

/// An action representing the addition of a star to the board.
final class PlaceStar implements GameEvent {
  /// Creates a new place star event at the given [position].
  const PlaceStar(this.position);

  /// The position where the star will be added.
  @override
  final Position position;
}

/// An action representing the marking of a cell on the board.
final class MarkCell implements GameEvent {
  /// Creates a new mark cell event at the given [position].
  const MarkCell(this.position);

  /// The position of the cell to be marked.
  @override
  final Position position;
}

/// An action representing the clearing of a cell on the board.
final class ClearCell implements GameEvent {
  /// Creates a new clear cell event at the given [position].
  const ClearCell(this.position);

  @override
  final Position position;
}
