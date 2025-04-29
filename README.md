## UART
15: Piece Move
14: Unused
13-11: oldx
10-8: oldy
7-5: newx
4-2: newy
1-0: unused

15: Game State
14: Unused
13: Player
12-11: Game Mode
10-0: Unused

## I/O Breakdown
SW 0: Axis selection (x or y) <br>
SW 1: Game Mode Sel 1 (Bullet(00):1, Blitz(01):3, Rapid(10):10, Classic(11):30) <br>
SW 2: Game Mode Sel 2 <br>
SW 3: Player (White/Black)
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
