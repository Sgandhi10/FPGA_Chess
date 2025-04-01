## i2c

8 bits has max of 256 possibilities

32 Pieces on a chess board --> Need 5 bits to indicate what piece is being moved
64 Spots on the board --> Need 6 bits to indicate a position on the board

Group i2c messages into 3 Byte Packets

- first byte indicates command
- second & third byte sends information

0x00: Start Game
0x01: Game Time (optional) <- decide how long the game will be
0x02: Send Piece Move
0x03: Read Piece Move
