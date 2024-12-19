import 'package:star_battle/star_battle.dart';
import 'package:test/test.dart';

void main() {
  test(
    "'checkRegionContiguousness' should check whether a set of positions form a valid region.",
    () {
      final contiguousPositions = {
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(1, 1),
      };

      expect(
        checkRegionContiguousness(contiguousPositions),
        isTrue,
      );

      final uncontiguousPositions = {
        Position(0, 0),
        Position(0, 1),
        Position(1, 0),
        Position(2, 2),
      };

      expect(
        checkRegionContiguousness(uncontiguousPositions),
        isFalse,
      );
    },
  );

  test(
    "'checkBoardCompleteness' should check whether a set of regions cover all possible positions on a board.",
    () {
      final regions = [
        BoardRegion({
          Position(0, 0),
          Position(0, 1),
          Position(1, 0),
          Position(1, 1),
          Position(2, 0),
          Position(2, 1),
          Position(3, 0),
          Position(3, 1),
        }),
        BoardRegion({
          Position(0, 2),
          Position(0, 3),
          Position(1, 2),
          Position(1, 3),
          Position(2, 2),
          Position(2, 3),
          Position(3, 2),
          Position(3, 3),
        }),
      ];

      expect(
        checkBoardCompleteness(
          dimension: 4,
          regions: regions,
        ),
        isTrue,
      );

      final incompleteRegions = [
        BoardRegion({
          Position(0, 0),
          Position(0, 1),
          Position(1, 0),
          Position(1, 1),
        }),
      ];

      expect(
        checkBoardCompleteness(
          dimension: 4,
          regions: incompleteRegions,
        ),
        isFalse,
      );
    },
  );
}
