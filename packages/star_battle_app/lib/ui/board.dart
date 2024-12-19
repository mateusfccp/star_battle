import 'package:flutter/material.dart';
import 'package:star_battle/star_battle.dart' hide Board;
import 'package:star_battle/star_battle.dart' as core show Board;

final class Board extends StatelessWidget {
  const Board({
    super.key,
    required this.state,
    required this.board,
    required this.onTapCell,
  });

  final List<List<CellState>> state;
  final core.Board board;
  final void Function(int x, int y) onTapCell;

  @override
  Widget build(BuildContext context) {
    final cells = board.cells;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide / board.dimension;
        return Column(
          children: [
            for (int y = 0; y < board.dimension; y++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int x = 0; x < board.dimension; x++) //
                    _BoardCell(
                      state: state[y][x],
                      color: cells[y][x],
                      dimension: size,
                      onTap: () => onTapCell(x, y),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

final class _BoardCell extends StatefulWidget {
  const _BoardCell({
    required this.state,
    required this.color,
    required this.dimension,
    required this.onTap,
  });

  final CellState state;
  final int color;
  final double dimension;
  final VoidCallback onTap;

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell> with TickerProviderStateMixin {
  late DecorationTween _tween;
  late AnimationController _controller;
  late Animation<Decoration> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _tween = DecorationTween(
      begin: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: _colorFromState(),
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
      ),
      end: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: _colorFromState().withAlpha(200),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
    );

    _animation = _controller.drive(
      _tween.chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      _tween = DecorationTween(
        begin: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: _colorFromState(),
          border: Border.all(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        end: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: _colorFromState().withAlpha(200),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      );

      _animation = _controller.drive(
        _tween.chain(
          CurveTween(curve: Curves.easeInOut),
        ),
      );

      // if (widget.state == CellState.empty) {
      //   _controller.reverse();
      // }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _controller.forward(),
      onExit: (event) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBoxTransition(
          decoration: _animation,
          child: SizedBox.square(
            dimension: widget.dimension,
            child: _childFromState(),
          ),
        ),
      ),
    );
  }

  Widget? _childFromState() {
    return switch (widget.state) {
      CellState.empty || CellState.marked => null,
      CellState.star => Center(
          child: const Icon(
            Icons.star,
            color: Colors.black,
            size: 32.0,
          ),
        ),
    };
  }

  Color _colorFromState() {
    return switch (widget.state) {
      CellState.empty || CellState.star => switch (widget.color) {
          0 => Colors.red[300]!,
          1 => Colors.blue[300]!,
          2 => Colors.green[300]!,
          3 => Colors.yellow[300]!,
          4 => Colors.purple[300]!,
          5 => Colors.orange[300]!,
          6 => Colors.teal[300]!,
          7 => Colors.pink[300]!,
          8 => Colors.indigo[300]!,
          _ => throw ArgumentError('Invalid color value: $widget.color')
        },
      CellState.marked => Colors.black
    };
  }
}
