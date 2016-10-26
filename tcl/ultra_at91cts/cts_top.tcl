
set sh_continue_on_error false

source ultra_at91cts/timer.tcl

package require at91com 1.0
package require at91sta 1.0

set at91mmmc_delay_corner [sta::get_default_delay_corner]

if { $at91mmmc_delay_corner eq "" } {
  at91com::message -type fatal "Failed to find default 'delay_corner' : add 'default = true' for one of your delay corners in atmel_sta.ini"
}

if [catch "sta::get_library_set -delay_corner $at91mmmc_delay_corner" caught] {
  at91com::message -type fatal "Failed to find 'library_set' for delay_corner '$at91mmmc_delay_corner' : $caught"
} else {
  set at91mmmc_library_set $caught
}
if [catch "sta::get_extraction_corner -delay_corner $at91mmmc_delay_corner" caught] {
  at91com::message -type fatal "Failed to find 'extraction_corner' for delay_corner '$at91mmmc_delay_corner' : $caught"
} else {
  set at91mmmc_extraction_corner $caught
}
#set logdir         $logdir/$current_scenario/${modename}
#file mkdir $logdir

::at91com::message -type info " CTS ANALYSIS WITH :"
::at91com::message -type info " DELAY CORNER                  : '$at91mmmc_delay_corner'"
::at91com::message -type info " EXTRACTION CORNER             : '$at91mmmc_extraction_corner'"
::at91com::message -type info " LIBRARY SET                   : '$at91mmmc_library_set'"

if { [info exists debug] && [string match $debug "start"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution at start point"
  return
}


##########################################################
# Either define variables in run.csh or define_run.tcl
# If define_run.tcl is not executed, tcl variables are 
# extracted from CSH variable environments in tcl_setup.tcl
##########################################################
#set sh_script_stop_severity none

foreach file [sta::get_attribute -name "global_constraint_files"] { source $file }

::at91com::message -type info "Date : [sh date]"

::timer::print "load"

if { [info exists debug] && [string match $debug "load_only"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution after loading design"
  return
}


####################################
# Design Paths 
source ./constraints/CTS/ip_paths.tcl
# PNR constraints 
source ./constraints/CTS/define_pnr_CTS_clock.tcl

#########################################################################
# Create SPECs
#########################################################################

# Create a FUNCTIONAL CTS spec.
set func_spec_name func_clock_spec
##at91cts::create_CTS_spec -name $func_spec_name -spare  $spare_list
# spare_list : these paths will be discarded in CTS specification check

#########################################################################
# FUNCTIONAL MODE
#########################################################################

set_app_var case_analysis_log_file  $logdir/case_analysis_func.log

redirect $logdir/source_func.log { source ./constraints/CTS/chip_func_cts.tcl }

#################################################################################
# PROCESS FUNCTIONAL MODE
#################################################################################

update_timing

::timer::print "func update_timing"

redirect $logdir/trace_func.log { ::at91cts::trace_CTS -case_sensitive }
redirect $logdir/check_func.log { ::at91cts::check_CTS ; ::at91cts::check_CTS -verbose } 

::timer::print "func trace_CTS"

save_session $logdir/session_func

::timer::print "func save"

if { [info exists debug] && [string match $debug "check_func"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution after checking functionnal CTS constraints"
  return
}

#################################################################################
# TEST MODE
#################################################################################

reset_design

::timer::print "reset"

set_app_var case_analysis_log_file  $logdir/case_analysis_test.log

redirect $logdir/source_test.log { source ./constraints/CTS/chip_test_cts.tcl }

if { [info exists debug] && [string match $debug "test_constraints"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution after loading test CTS constraints"
  return
}

#################################################################################
# PROCESS TEST MODE
#################################################################################

update_timing

::timer::print "test update_timing"

redirect $logdir/trace_test.log { ::at91cts::trace_CTS -case_sensitive }
redirect $logdir/check_all.log { ::at91cts::check_CTS ; ::at91cts::check_CTS -verbose } 

::timer::print "test trace_CTS"

save_session $logdir/session_all

::timer::print "test save"

if { [info exists debug] && [string match $debug "check_all"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution after checking all CTS constraints"
  return
}

####################################
# Final check + Write

::at91cts::complete_CTS_spec

::at91cts::reset_CTS

redirect $logdir/trace_final.log { ::at91cts::trace_CTS }
redirect $logdir/check_final.log { ::at91cts::check_CTS ; ::at91cts::check_CTS -verbose } 

::timer::print "final trace_CTS"

save_session $logdir/session_final

::timer::print "final save"

redirect $logdir/write_spec.log { ::at91cts::write_edi_fects -input $pnr_netlist_ref -output $logdir/CTS_clock_spec.fects }

::timer::print "final write"

if { [info exists debug] && [string match $debug "end"] } {
  at91com::message -type warning "cts_top ... -debug $debug : stopping script execution at end point"
  return
}

::at91com::message -type info "Date : [sh date]"

##########################################################
if {$quit_session == 1} {quit}

::at91com::message -type info "End of cts_top.tcl script"

