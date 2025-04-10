set_global_assignment -entity "vga_pll_25_2" -library "lib_vga_pll_25_2" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "vga_pll_25_2" -library "lib_vga_pll_25_2" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "vga_pll_25_2" -library "lib_vga_pll_25_2" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_vga_pll_25_2" -name SPD_FILE [file join $::quartus(sip_path) "vga_pll_25_2.spd"]

set_global_assignment -library "lib_vga_pll_25_2" -name MISC_FILE [file join $::quartus(sip_path) "vga_pll_25_2_sim/vga_pll_25_2.vo"]
