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

  final BidimensionalList<CellState> state;
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
                      topBorder: !board.regionAt(x, y).hasNeighborNorth(x, y),
                      rightBorder: !board.regionAt(x, y).hasNeighborEast(x, y),
                      bottomBorder: !board.regionAt(x, y).hasNeighborSouth(x, y),
                      leftBorder: !board.regionAt(x, y).hasNeighborWest(x, y),
                      state: state(x, y),
                      region: cells(x, y),
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
    required this.region,
    required this.dimension,
    required this.onTap,
    required this.topBorder,
    required this.rightBorder,
    required this.bottomBorder,
    required this.leftBorder,
  });

  final CellState state;
  final int region;
  final double dimension;
  final VoidCallback onTap;
  final bool topBorder;
  final bool rightBorder;
  final bool bottomBorder;
  final bool leftBorder;

  @override
  State<_BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<_BoardCell> with TickerProviderStateMixin {
  late DecorationTween tween;
  late AnimationController controller;
  late Animation<Decoration> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    updateDecoration();
  }

  @override
  void didUpdateWidget(covariant _BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      updateDecoration();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateDecoration() {
    final decoration = _BoardCellDecoration(
      topBorder: widget.topBorder,
      rightBorder: widget.rightBorder,
      bottomBorder: widget.bottomBorder,
      leftBorder: widget.leftBorder,
      color: _colorFromState(),
      invalid: widget.state.status == CellStatus.invalid,
    );

    tween = DecorationTween(
      begin: decoration,
      end: decoration.copyWith(
        color: decoration.color.withAlpha(200),
      ),
    );

    animation = controller.drive(
      tween.chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => controller.forward(),
      onExit: (event) => controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DecoratedBoxTransition(
          decoration: animation,
          child: SizedBox.square(
            dimension: widget.dimension,
            child: _childFromState(),
          ),
        ),
      ),
    );
  }

  Widget? _childFromState() {
    return switch (widget.state.content) {
      CellContent.empty => null,
      CellContent.marked => Center(
          child: const Icon(
            Icons.close,
            color: Colors.red,
            size: 64.0,
          ),
        ),
      CellContent.star => Center(
          child: const Icon(
            Icons.star,
            color: Colors.black,
            size: 64.0,
          ),
        ),
    };
  }

  Color _colorFromState() {
    return switch (widget.region) {
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
    };
  }
}

final class _BoardCellDecoration extends Decoration {
  const _BoardCellDecoration({
    required this.topBorder,
    required this.rightBorder,
    required this.bottomBorder,
    required this.leftBorder,
    required this.color,
    required this.invalid,
  });

  final bool topBorder;
  final bool rightBorder;
  final bool bottomBorder;
  final bool leftBorder;
  final Color color;
  final bool invalid;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BoardCellBoxPainter(this);
  }

  _BoardCellDecoration copyWith({
    bool? topBorder,
    bool? rightBorder,
    bool? bottomBorder,
    bool? leftBorder,
    Color? color,
    bool? invalid,
  }) {
    return _BoardCellDecoration(
      topBorder: topBorder ?? this.topBorder,
      rightBorder: rightBorder ?? this.rightBorder,
      bottomBorder: bottomBorder ?? this.bottomBorder,
      leftBorder: leftBorder ?? this.leftBorder,
      color: color ?? this.color,
      invalid: invalid ?? this.invalid,
    );
  }
}

final class _BoardCellBoxPainter extends BoxPainter {
  const _BoardCellBoxPainter(this.decoration);

  final _BoardCellDecoration decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);

    final thickBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final thinBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    if (decoration.invalid) {
      final stripesPaint = Paint()
        ..color = Colors.red.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width / 10.0;

      canvas.save();
      canvas.clipRect(rect);
      for (var i = -rect.width / 2.0; i < rect.width / 2.0; i += rect.width / 6.0) {
        canvas.drawLine(
          rect.topRight.translate(i, i),
          rect.bottomLeft.translate(i, i),
          stripesPaint,
        );
      }
      canvas.restore();
    }

    canvas.drawLine(
      rect.topLeft,
      rect.topRight,
      decoration.topBorder ? thickBorderPaint : thinBorderPaint,
    );

    canvas.drawLine(
      rect.topRight,
      rect.bottomRight,
      decoration.rightBorder ? thickBorderPaint : thinBorderPaint,
    );

    canvas.drawLine(
      rect.bottomRight,
      rect.bottomLeft,
      decoration.bottomBorder ? thickBorderPaint : thinBorderPaint,
    );

    canvas.drawLine(
      rect.bottomLeft,
      rect.topLeft,
      decoration.leftBorder ? thickBorderPaint : thinBorderPaint,
    );
  }
}
