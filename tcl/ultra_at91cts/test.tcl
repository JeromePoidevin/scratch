
source ../../tools_rfo2/CTS/ultra/ultra_at91cts.tcl

::at91cts::reset_CTS

redirect test.log {
    ::at91cts::add_CTS_tree -root U_TOP_LOGIC/U_PDSW/U_MCLK/U_MAIN_CLOCKS/U_ZSM/perdivx0xximplementedxU_PMUX_DIV/UxMUX/Z -type network
    ::at91cts::trace_CTS -case_sensitive
}
    
    report_attribute [get_pins -hier]
    
redirect -append test.log {
    ::at91cts::add_CTS_tree -root U_TOP_LOGIC/U_PDSW/U_MCLK/U_MAIN_CLOCKS/U_ZSM/perdivx1xximplementedxU_PMUX_DIV/UxMUX/Z -type network
    ::at91cts::trace_CTS -case_sensitive
}

redirect -append test.log {
    ::at91cts::check_CTS
}

    report_attribute [sort_collection [get_pins -hier -filter defined(cts_num)] cts_num] -nosplit

return

save_session test_session

