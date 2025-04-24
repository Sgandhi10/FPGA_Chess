## UART
8 bits has max of 256 possibilities

32 Pieces on a chess board --> Need 5 bits to indicate what piece is being moved
--> Will use 6 bits for extra bits needed for pawn promotion
64 Spots on the board --> Need 6 bits to indicate a position on the board

3 bits for different operations

0x00: Start Game <br>
0x01: Game Time (optional) <br>
0x02: Send Piece Move <br>
0x03: Read Piece Move 

## I/O Breakdown
SW 0: Axis selection (x or y) <br>
SW 1: Game Mode Sel 1 (Bullet(00):1, Blitz(01):3, Rapid(10):10, Classic(11):30) <br>
SW 2: Game Mode Sel 2 <br>
SW 3: <br>
SW 4: <br>
SW 5: <br>
SW 6: <br>
SW 7: <br>
SW 8: <br>
SW 9: <br>

KEY 0: rst_n  <br>
KEY 1: + dir  <br>
KEY 2: - dir  <br>
KEY 3: enter  <br>

HEX 0: Time 0 <br>
HEX 1: Time 1 <br>
HEX 2: Time 2 <br>
HEX 3: Time 3 <br>
HEX 4: <br>
HEX 5: <br>

// Probably would be best to use these outputs as debug signals
LED 0: PLL Lock <br>
LED 1: Game Started <br>
LED 2: Player turn <br>
LED 3: <br>
LED 4: <br>
LED 5: <br>
LED 6: <br>
LED 7: <br>
LED 8: <br>
LED 9: <br>
