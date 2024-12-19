import 'dart:typed_data';

import 'package:star_battle/star_battle.dart';

final class BoardByteLoader implements BoardLoader<Stream<Uint8List>> {
  @override
  Future<Board> loadBoard(Stream<Uint8List> bytes) async {
    int offset = 0;
    int x = 0;
    int y = 0;

    late int dimension;

    final regions = <int, Set<Position>>{};

    void addRegion(Iterable<int> cells) {
      for (final cell in cells) {
        if (regions[cell] case final region?) {
          region.add(Position(x, y));
        } else {
          regions[cell] = {Position(x, y)};
        }

        x = (x + 1) % dimension;
        if (x == 0) {
          y = (y + 1) % dimension;
        }
      }
    }

    await for (final chunk in bytes) {
      final bytes = chunk.buffer.asByteData(0, chunk.lengthInBytes);

      if (offset == 0) {
        final header = bytes.getUint8(0);
        // As we have only a single version, we can ignore the version.
        dimension = (header & 0x07) + 5;
        addRegion(_unpackByte(bytes, 1));
      } else {
        addRegion(_unpackByte(bytes, 1));
      }

      offset += chunk.lengthInBytes;
    }

    return Board(
      regions: [
        for (final region in regions.values) BoardRegion(region),
      ],
      dimension: dimension,
    );
  }
}

Iterable<int> _unpackByte(ByteData bytes, [int offset = 0]) sync* {
  for (; offset < bytes.lengthInBytes; offset++) {
    final byte = bytes.getUint8(offset);
    yield byte >> 4;
    yield byte & 0x0F;
  }
}
