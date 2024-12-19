import 'dart:async';

import 'package:collection/collection.dart';

import 'board.dart';
import 'position.dart';

/// An instance of a Star Battle game.
final class Game {
  /// Creates a new game with the given [board].
  Game({required this.board})
      : _cachedState = _createEmptyState(board.dimension),
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
  UnmodifiableListView<UnmodifiableListView<CellState>> get state {
    return UnmodifiableListView([
      for (final row in _cachedState) UnmodifiableListView(row),
    ]);
  }
  _State _cachedState;

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
    _cachedState = _createEmptyState(board.dimension);
    _startTime = DateTime.now();
    _stateController.add(null);
  }

  /// Gets the state of the cell at the given position.
  CellState cellStateAt(int x, int y) {
    return _cachedState[y][x];
  }

  /// Adds a star to the board at the given position.
  void addStar(int x, int y) {
    final position = Position(x, y);
    final event = AddStar(position);
    _addEvent(event);
  }

  /// Removes a star from the board at the given position.
  void removeStar(int x, int y) {
    final position = Position(x, y);
    final event = RemoveStar(position);
    _addEvent(event);
  }

  /// Marks a cell on the board at the given position.
  void markCell(int x, int y) {
    final position = Position(x, y);
    final event = MarkCell(position);
    _addEvent(event);
  }

  /// Unmarks a cell on the board at the given position.
  void unmarkCell(int x, int y) {
    final position = Position(x, y);
    final event = UnmarkCell(position);
    _addEvent(event);
  }

  /// Undoes the last action performed on the game.
  void undo() {
    if (!canUndo) return;

    final event = _events.removeLast();
    _redoEvents.add(event);
    _cachedState = _computeState();
    _stateController.add(null);
  }

  /// Redoes the last action that was undone.
  void redo() {
    if (!canRedo) return;

    final event = _redoEvents.removeLast();
    _events.add(event);
    _cachedState = _computeState(
      initialState: _cachedState,
      from: _events.length - 1,
    );
    _stateController.add(null);
  }

  void _addEvent(GameEvent event) {
    _redoEvents.clear();
    _events.add(event);
    _cachedState = _computeState(
      initialState: _cachedState,
      from: _events.length - 1,
    );
    _stateController.add(null);
  }

  _State _computeState({
    _State? initialState,
    int from = 0,
  }) {
    final _State state;

    if (initialState == null) {
      state = _createEmptyState(board.dimension);
    } else {
      state = [...initialState];
    }

    for (var i = from; i < _events.length; i++) {
      final event = _events[i];

      final Position(:x, :y) = event.position;

      switch (event) {
        case AddStar():
          assert(state[y][x] != CellState.star);
          state[y][x] = CellState.star;
        case RemoveStar():
          assert(state[y][x] == CellState.star);
          state[y][x] = CellState.empty;
        case MarkCell():
          assert(state[y][x] != CellState.marked);
          state[y][x] = CellState.marked;
        case UnmarkCell():
          assert(state[y][x] == CellState.marked);
          state[y][x] = CellState.empty;
      }
    }

    return state;
  }
}

typedef _State = List<List<CellState>>;

@pragma('vm:prefer-inline')
_State _createEmptyState(int dimension) {
  return _State.generate(
    dimension,
    (index) => List.filled(dimension, CellState.empty),
  );
}

/// The possible states of a cell on the board.
enum CellState {
  empty,
  star,
  marked,
}

/// An action that can be performed on the game.
sealed class GameEvent {
  /// The position where the event will be performed.
  Position get position;
}

/// An action representing the addition of a star to the board.
final class AddStar implements GameEvent {
  const AddStar(this.position);

  /// The position where the star will be added.
  @override
  final Position position;
}

/// An action representing the removal of a star from the board.
final class RemoveStar implements GameEvent {
  const RemoveStar(this.position);

  /// The position from where the star will be removed.
  @override
  final Position position;
}

/// An action representing the marking of a cell on the board.
final class MarkCell implements GameEvent {
  const MarkCell(this.position);

  /// The position of the cell to be marked.
  @override
  final Position position;
}

/// An action representing the unmarking of a cell on the board.
final class UnmarkCell implements GameEvent {
  const UnmarkCell(this.position);

  /// The position of the cell to be unmarked.
  @override
  final Position position;
}
