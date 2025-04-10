set_global_assignment -entity "uart_pll" -library "lib_uart_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "uart_pll" -library "lib_uart_pll" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "uart_pll" -library "lib_uart_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_uart_pll" -name SPD_FILE [file join $::quartus(sip_path) "uart_pll.spd"]

set_global_assignment -library "lib_uart_pll" -name MISC_FILE [file join $::quartus(sip_path) "uart_pll_sim/uart_pll.vo"]
