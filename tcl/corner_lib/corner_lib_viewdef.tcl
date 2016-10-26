#! /bin/env tclsh


set lib_dir [file dirname [info script]]
source $lib_dir/corner_lib_setup.tcl

################################################################################
## when script is executed (not sourced from tclsh or other program) , fake EDI commands will 'puts' into viewDef.tcl

if { [info exists ::argv0] && [file tail $::argv0]=="corner_lib_viewdef.tcl" } {

    set VDEF [open "viewDef.tcl" w]

    # magic proc to puts into VDEF the name+args of caller proc
    proc puts_vdef { {line false} } {
        upvar #0 VDEF VDEF

        if { $line == false } {
            set line "[info level -1]\n"
        }

        puts $VDEF $line
    }

    proc puts_vdef_split { {line false} } {
        upvar #0 VDEF VDEF


        if { $line == false } {
            set tmp  [info level -1]

            set line [lindex $tmp 0]
            set args [lrange $tmp 1 end]
            set last_arg [lindex $args end-1]

            foreach { arg val } $args {
                if { [llength $val] > 1 } {
                    append line "    $arg { $val }"
                } else {
                    append line "    $arg $val"
                }
                if {$arg==$last_arg} {
                    append line "\n"
                } else {
                    append line " \\\n"
                }
            }

        }

        puts $VDEF $line
    }

    puts_vdef "

## file created by corner_lib_viewdef.tcl

"
    proc all_library_sets        {}     {}
    proc create_library_set      {args} { 
         puts_vdef_split 
    }


    proc create_rc_corner        {args} { puts_vdef_split }
    proc create_op_cond          {args} { puts_vdef_split }
    proc create_delay_corner     {args} { puts_vdef_split }
    proc update_delay_corner     {args} { puts_vdef_split }

    proc create_constraint_mode  {args} { 
    }



    proc create_analysis_view    {args} { puts_vdef_split }
    proc set_analysis_view       {args} { puts_vdef_split }
    proc set_timing_derate       {args} { puts_vdef }

}

################################################################################


#package require at91sta ...
# TODO ? source ./scripts/tcl_setup.tcl

# setup global variable for encounter
# TODO ? global array at91mmmc_db_attributes

# Source the file that contains the variables related to parasitics factors used in RC correlation
# TODO ? source /eng/mcu/ultra/users/crobicho/jubilee_U3011_F_rev361554_SP6/backend/CONF_VIEW_CPF_GENERATION/FLAT/./VIEW_DEF/kfactors_setting.tcl


################################################################################
puts_vdef "
#
# Create library sets
#
"

set libSetList [all_library_sets]

#  libs-bc_core_1v0_3v3
#  libs-bc_core_1v2_1v8
#  libs-bc_core_1v2_3v3
#  libs-bcht_core_1v2_3v3
#  libs-bcht_io_1v2_3v3
#  libs-bc_io_1v0_3v3
#  libs-bc_io_1v2_1v8
#  libs-bc_io_1v2_3v3
#  libs-tc_core_1v0_3v3
#  libs-tc_core_1v2_1v8
#  libs-tc_core_1v2_3v3
#  libs-tc_io_1v0_3v3
#  libs-tc_io_1v2_1v8
#  libs-tc_io_1v2_3v3
#  libs-wc_core_1v0_1v8
#  libs-wc_core_1v2_1v8
#  libs-wc_core_1v2_3v3
#  libs-wc_io_1v0_1v8
#  libs-wc_io_1v2_1v8
#  libs-wc_io_1v2_3v3
#  libs-wclt_core_1v2_1v8
#  libs-wclt_core_1v2_3v3
#  libs-wclt_io_1v2_1v8
#  libs-wclt_io_1v2_3v3




foreach { dlc } [lsort -dictionary [array names ::corner::opcond_spec]] {
    lappend delay_corner_list $dlc
}

foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    if { [lsearch -exact $libSetList "libs-core_$dlc"] == -1 } {
        create_library_set -name "libs-core_$dlc" \
            -timing [::lib::all_lib  ccs.lib  core] \
            -si     [::lib::all_lib  cdb      core]
    }


    if { [lsearch -exact $libSetList "libs-io_$dlc"] == -1 } {
        create_library_set -name "libs-io_$dlc" \
            -timing [::lib::all_lib  ccs.lib  io] \
            -si     [::lib::all_lib  cdb      io]
    }

}


################################################################################
puts_vdef "
#
# Create RC corner
#
"

##todo: add -preRoute_res, .... 

set PDK_DIR_CADENCE $env(PDK_DIR)/at65n/techfile/at65nM6_0T1F/cadence

foreach {rct file_suffix} {
    cbest_125 cbest
    cbest_m40 cbest
    ctyp_25 typ
    cworst_125 cworst
    cworst_m40 cworst
    rcbest_125 rcbest
    rcbest_m40 rcbest
    rcworst_125 rcworst
    rcworst_m40 rcworst
} {
    set tmp [split $rct _]
    set rc [lindex $tmp 0]
    set t  [string map {m -} [lindex $tmp 1]]

    create_rc_corner -name $rct \
        -cap_table    $PDK_DIR_CADENCE/at65n_${file_suffix}.CapTbl \
        -qx_tech_file $PDK_DIR_CADENCE/at65n_${file_suffix}.tch \
        -T $t
        # kfactors : vars(rcworst_m40,preRoute_res)
}


################################################################################
puts_vdef "
#
# Create Operating Corners
#
"

#  core
#  DEFAULT_fast_1v10_tm40_ccs_oc
#  DEFAULT_fast_1v32_t125_ccs_oc
#  DEFAULT_fast_1v32_tm40_ccs_oc
#  DEFAULT_slow_0v90_t125_ccs_oc
#  DEFAULT_slow_1v08_t125_ccs_oc
#  DEFAULT_slow_1v08_tm40_ccs_oc
#  DEFAULT_typ_1v00_t25_ccs_oc
#  DEFAULT_typ_1v20_t25_ccs_oc
#  
#  io
#  PD_IO_fast_1v95_tm40_ccs_oc
#  PD_IO_fast_3v60_t125_ccs_oc
#  PD_IO_fast_3v60_tm40_ccs_oc
#  PD_IO_slow_1v60_t125_ccs_oc
#  PD_IO_slow_1v60_tm40_ccs_oc
#  PD_IO_slow_2v85_t125_ccs_oc
#  PD_IO_slow_2v85_tm40_ccs_oc
#  PD_IO_typ_1v80_t25_ccs_oc
#  PD_IO_typ_3v30_t25_ccs_oc
#  
#  DEFAULT_typ_1v20_t25_ccs_oc
#  PD_ANA_typ_3v30_t25_ccs_oc
#  PD_FLEXRAMA_typ_1v20_t25_ccs_oc
#  PD_FLEXRAMBC_typ_1v20_t25_ccs_oc
#  PD_IOB_typ_3v30_t25_ccs_oc
#  PD_IO_typ_3v30_t25_ccs_oc
#  PD_RAMPICOP0_typ_1v20_t25_ccs_oc
#  PD_RAMPICOP1_typ_1v20_t25_ccs_oc
#  PD_SW_typ_1v20_t25_ccs_oc
#  PD_VSWOUT_typ_3v30_t25_ccs_oc
#  
#  create_op_cond -name DEFAULT_typ_1v20_t25_ccs_oc \
#     -library_file /eng/mcu/ultra/users/crobicho/jubilee_U3011_F_rev361554_SP6/lib/import/uk65lsclpmvbbr/synopsys/ccs/uk65lsclpmvbbr-typ_1v20_t25+ccs.lib.gz \
#     -P 1 -V 1.20 -T 25.00

proc oc_name { type } {

    array set oc $::corner::opcondstr

    switch -exact $type {
        core    { set tmp [list  $type  $oc(P)  $oc(VCO)  $oc(T) ] }
        io      { set tmp [list  $type  $oc(P)  $oc(VIO)  $oc(T) ] }
        default { error "oc_name : unknown type '$type'" }
    }
    return "oc-[join $tmp _]"
}

proc oc_lib { type {short ""} } {

    # TODO core==target1v2 ; io==target3v3
    switch -exact $type {
        core    { set tmp [::lib::all_lib  ccs.lib  target1v2] }
        io      { set tmp [::lib::all_lib  ccs.lib  target3v3] }
        default { error "oc_lib : unknown type '$type'" }
    }
    set oc_lib [lindex $tmp 0]

    if { $short == "-short" } {
        set i [string last ".lib" $oc_lib]
        incr i -1
        set oc_lib [file tail [string range $oc_lib 0 $i]]
    }
    return $oc_lib
}


foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    array set oc $::corner::opcond

    # TODO : avoid redifinitions

    create_op_cond -name [oc_name core] \
       -library_file [oc_lib core] \
       -P 1 -V $oc(VCO) -T $oc(T)

    create_op_cond -name [oc_name io] \
       -library_file [oc_lib io] \
       -P 1 -V $oc(VIO) -T $oc(T)

}


################################################################################
puts_vdef "
#
# Create delay corners = library_set + opcond + rc + all pd
#
"

#  create_delay_corner -name delay_corner_1 \
#     -library_set libs-tc_core_1v2_3v3 \
#     -opcond_library uk65lsclpmvbbr-typ_1v20_t25+ccs \
#     -opcond DEFAULT_typ_1v20_t25_ccs_oc \
#     -rc_corner ctyp_25
#  
#  update_delay_corner -name delay_corner_1 \
#     -library_set libs-tc_core_1v2_3v3 \
#     -power_domain DEFAULT \
#     -opcond_library uk65lsclpmvbbr-typ_1v20_t25+ccs \
#     -opcond DEFAULT_typ_1v20_t25_ccs_oc 
#  
#  update_delay_corner -name delay_corner_1 \
#     -library_set libs-tc_core_1v2_3v3 \
#     -power_domain PD_SW \
#     -opcond_library uk65lsclpmvbbr-typ_1v20_t25+ccs \
#     -opcond PD_SW_typ_1v20_t25_ccs_oc 
#  
#  update_delay_corner -name delay_corner_1 \
#     -library_set libs-tc_io_1v2_3v3 \
#     -power_domain PD_IO \
#     -opcond_library S39SC33X25lib-typ_3v30_t25+ccs \
#     -opcond PD_IO_typ_3v30_t25_ccs_oc 

foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    foreach rc [::corner::all_rc] {

        set name ${dlc}_${rc}

        create_delay_corner -name $name \
           -library_set libs-core_${dlc} \
           -opcond_library [oc_lib core -short] \
           -opcond [oc_name core] \
           -rc_corner $rc
        
        foreach { pd type } {
            DEFAULT       core
            PD_FLEXRAMA   core
            PD_FLEXRAMBC  core
            PD_RAMPICOP0  core
            PD_RAMPICOP1  core
            PD_SW         core
            PD_ANA        io
            PD_IO         io
            PD_IOB        io
            PD_VSWOUT     io
        } {
            update_delay_corner -name $name \
               -library_set libs-${type}_${dlc} \
               -power_domain $pd \
               -opcond_library [oc_lib $type -short] \
               -opcond [oc_name $type]
        } ; # pd
    } ; # rc
} ; # dlc



################################################################################
puts_vdef "
#
# Create constraint modes (combination between STA modes and 
#   constraint file associated to delay corner) 
#
"

#  capture_fast-ctyp_25-delay_corner_2
#  capture_fast-ctyp_25-delay_corner_22
#  func_mode_1v8-ctyp_25-delay_corner_1
#  func_mode_1v8-ctyp_25-delay_corner_3
#  func_mode-ctyp_25-delay_corner_2
#  func_mode-ctyp_25-delay_corner_22
#  func_qspi_div1_mode-ctyp_25-delay_corner_1
#  func_qspi_div1_mode-ctyp_25-delay_corner_2
#  func_qspi_div1_mode-ctyp_25-delay_corner_22
#  func_qspi_div1_mode-ctyp_25-delay_corner_3
#  mbist_mode-ctyp_25-delay_corner_1
#  mbist_mode-ctyp_25-delay_corner_2
#  mbist_mode-ctyp_25-delay_corner_22
#  mbist_mode-ctyp_25-delay_corner_3
#  scan_capture-ctyp_25-delay_corner_2
#  scan_capture-ctyp_25-delay_corner_22
#  scan_shift-ctyp_25-delay_corner_2
#  scan_shift-ctyp_25-delay_corner_22
#  sti_mode-ctyp_25-delay_corner_1
#  sti_mode-ctyp_25-delay_corner_2
#  sti_mode-ctyp_25-delay_corner_22
#  sti_mode-ctyp_25-delay_corner_3

foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    foreach rc [::corner::all_rc] {
    foreach mode [::corner::all_modes] {

        set name ${mode}-${rc}-${dlc}

        set prefix_pnr_settings $::corner::pnr_settings_constraints_prefix_name(${mode})
        set prefix_timing_modes $::corner::timing_modes_constraints_prefix_name(${mode})


                     #./scripts/tcl_setup.tcl \
                     #./scripts/run_setup.tcl \
                     #./scripts/pt_setup.tcl \
                     #./scripts/load_db.tcl \
                     #./scripts/pt_si_setup.tcl \

puts_vdef ""
puts_vdef "create_constraint_mode -name $name \\"
puts_vdef "   -sdc_files \\"
puts_vdef "        \[list  \\"
puts_vdef "           ./constraints/SOCK/sock.tcl \\"
puts_vdef "           ./constraints/DELAY_CORNERS/${dlc}_setting.tcl \\"
puts_vdef "           ./constraints/PNR_SETTINGS/${prefix_pnr_settings}_PRECTS_setting.tcl \\"
puts_vdef "           ./constraints/TIMING_MODES/${prefix_timing_modes}_internal_constraints.tcl \\"
puts_vdef "    ] \\"
puts_vdef "    -ilm_sdc_files \\"
puts_vdef "         \[list  \\"
puts_vdef "           ./constraints/SOCK/sock.tcl \\"
puts_vdef "           ./constraints/DELAY_CORNERS/${dlc}_setting.tcl \\"
puts_vdef "           ./constraints/PNR_SETTINGS/${prefix_pnr_settings}_PRECTS_setting.tcl \\"
puts_vdef "           ./constraints/TIMING_MODES/${prefix_timing_modes}_internal_constraints.tcl \\"
puts_vdef "    ]"
puts_vdef ""

    } ; # mode
    } ; # rc
} ; # dlc


################################################################################
puts_vdef "
#
# Create analysis views
#
"

#  AV_capture_fast-ctyp_25-delay_corner_2
#  AV_capture_fast-ctyp_25-delay_corner_22
#  AV_func_mode_1v8-ctyp_25-delay_corner_1
#  AV_func_mode_1v8-ctyp_25-delay_corner_3
#  AV_func_mode-ctyp_25-delay_corner_2
#  AV_func_mode-ctyp_25-delay_corner_22
#  AV_func_qspi_div1_mode-ctyp_25-delay_corner_1
#  AV_func_qspi_div1_mode-ctyp_25-delay_corner_2
#  AV_func_qspi_div1_mode-ctyp_25-delay_corner_22
#  AV_func_qspi_div1_mode-ctyp_25-delay_corner_3
#  AV_mbist_mode-ctyp_25-delay_corner_1
#  AV_mbist_mode-ctyp_25-delay_corner_2
#  AV_mbist_mode-ctyp_25-delay_corner_22
#  AV_mbist_mode-ctyp_25-delay_corner_3
#  AV_scan_capture-ctyp_25-delay_corner_2
#  AV_scan_capture-ctyp_25-delay_corner_22
#  AV_scan_shift-ctyp_25-delay_corner_2
#  AV_scan_shift-ctyp_25-delay_corner_22
#  AV_sti_mode-ctyp_25-delay_corner_1
#  AV_sti_mode-ctyp_25-delay_corner_2
#  AV_sti_mode-ctyp_25-delay_corner_22
#  AV_sti_mode-ctyp_25-delay_corner_3

foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    foreach rc [::corner::all_rc] {
    foreach mode [::corner::all_modes] {

        set name ${mode}-${rc}-${dlc}

        create_analysis_view -name AV_${name} \
            -constraint_mode $name \
            -delay_corner ${dlc}_${rc} 

    } ; # mode
    } ; # rc
} ; # dlc



################################################################################
puts_vdef "
#
# set the analysis views
#
"

# TODO ? source /eng/mcu/ultra/users/crobicho/jubilee_U3011_F_rev361554_SP6/backend/CONF_VIEW_CPF_GENERATION/FLAT/./VIEW_DEF/implementation_views.tcl

set_analysis_view -setup {AV_func_mode-cworst_125-delay_corner_18} \
                  -hold  {AV_func_mode-cworst_125-delay_corner_18}

################################################################################
puts_vdef "
#
# Create instructions to load timing derate informations
#
# Such kind of constraints MUST be sourced and not be a part of design
#    timing constraints (means here not specified in \"constraint mode\")
#
"

# TODO ? group with create_delay_corner

foreach dlc $delay_corner_list {

    ::corner::set_corner $dlc

    array set oc $::corner::opcond

    foreach rc [::corner::all_rc] {

        set name ${dlc}_${rc}

        switch -exact $oc(P) {
            slow    { set_timing_derate -early 0.95 -late 1    -clock -delay_corner $name }
            typ     { set_timing_derate -early 1    -late 1.10 -clock -delay_corner $name }
            fast    { set_timing_derate -early 1    -late 1.10 -clock -delay_corner $name }
            default { error "timing_derate : unknown P '$::corner::P'" }
        }
    }
}



################################################################################
## when script is executed (not sourced from tclsh or other program) , fake EDI commands will 'puts' into viewDef.tcl

if { [info exists ::argv0] && [file tail $::argv0]=="corner_lib_viewdef.tcl" } {
    close $VDEF
}

