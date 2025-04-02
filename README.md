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


## I/O Breakdown
SW 0: Axis selection (x or y)
SW 1: Game Mode Sel 1 (Blitz, Bullet, Classic, etc)
SW 2: Game Mode Sel 2
SW 3: 
SW 4:
SW 5:
SW 6:
SW 7:
SW 8:
SW 9:

KEY 0: RST
KEY 1: + dir
KEY 2: - dir
KEY 3: Enter

HEX 0: Time 0
HEX 1: Time 1
HEX 2: Time 2
HEX 3: Time 3
HEX 4: 
HEX 5:

// Probably would be best to use these outputs as debug signals
LED 0: PLL Lock
LED 1: Game Started 
LED 2: Player turn
LED 3: 
LED 4:
LED 5:
LED 6:
LED 7:
LED 8:
LED 9:

