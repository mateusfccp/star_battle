# Star Battle file format

This package describes the format of a Star Battle board  and provides an
implementation of a `BoardLoader` that reads the file.

The file is composed of the following structure:

```
<header><board_description>
```

## Header

The header is composed of the first byte of the file, which contains the format
version and the board dimension.

```
| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
| Format version    | Dimension |
```

### Format version

The first 5 bits of the first byte indicate the version of the file format.

The current documentation is the version 1, and it can go up to version 32
without changing the file format.

### Board dimension

The next 3 bits of the first byte indicate the dimension of the board. The
dimension is the number of rows and columns of the board. As the board is
square, the dimension is the same for both rows and columns.

A value of 0 indicates a 5x5 board, the minimum size. A value of 7 indicates a
12x12 board, the maximum size.

## Board description

The rest of the file is the description of the board. In the current format,
each region is described by 4 bits, which means that a cell can be part of up
to 16 regions. In practice, the number of regions is smaller, as it always match
the number of stars in the board.

The cells are described row by row, from left to right, top to bottom. Each byte
contains 2 cells, and the description is done in a bit-packed way. The first cell
is described by the 4 most significant bits, and the second cell is described by
the 4 least significant bits.

```
| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
|---|---|---|---|---|---|---|---|
| Cell 0        | Cell 1        |
```

When the board dimension is odd, the last byte of the file contains the description
of the last cell of the board, and the remaining bits are ignored.

For instance, a board with dimension 5 will have 25 cells, which will be encoded
in 13 bytes.
