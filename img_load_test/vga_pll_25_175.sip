set_global_assignment -entity "vga_pll_25_175" -library "lib_vga_pll_25_175" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "vga_pll_25_175" -library "lib_vga_pll_25_175" -name IP_TOOL_VERSION "23.1"
set_global_assignment -entity "vga_pll_25_175" -library "lib_vga_pll_25_175" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_vga_pll_25_175" -name SPD_FILE [file join $::quartus(sip_path) "vga_pll_25_175.spd"]

set_global_assignment -library "lib_vga_pll_25_175" -name MISC_FILE [file join $::quartus(sip_path) "vga_pll_25_175_sim/vga_pll_25_175.vo"]
