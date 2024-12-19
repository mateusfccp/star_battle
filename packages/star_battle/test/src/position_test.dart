import 'package:star_battle/star_battle.dart';
import 'package:test/test.dart';

void main() {
  group('A position', () {
    test(
      'should encode a position into 2 bytes.',
      () {
        final position = Position(1, 2);
        final bytes = position.internalValue.getUint16(0);

        expect(bytes, 0x0102);
      },
    );

    test(
      "should have a x and y based on it's construction.",
      () {
        final position = Position(1, 2);

        expect(position.x, 1);
        expect(position.y, 2);
      },
    );
  });
}
