#! /bin/env tclsh

set lib_dir [file dirname [info script]]

## workaround : info script behaves differently in tclsh / DC / PT
## tclsh + PT : relative path
## DC         : absolute path
## => force relative path

if { $lib_dir == [file normalize $lib_dir] } {
    ## compare pwd and lib_dir and find first diff
    set pwd [pwd]
    set pwd_len     [string length $pwd]
    set lib_dir_len [string length $lib_dir]
    for { set i 0 } { $i<$pwd_len && $i<$lib_dir_len } { incr i } {
        if { [string index $pwd $i] != [string index $lib_dir $i] } { break }
    }
    ## keep end of pwd and lib_dir (the diff)
    set pwd     [string range $pwd $i end]
    set lib_dir [string range $lib_dir $i end]
    ## build the relative path
    if { $pwd == "" } {
        if { $lib_dir == "" } { set lib_dir . } else { set lib_dir ./$lib_dir }
    } else {
        set pwd_depth [llength [split $pwd /]]
        set lib_dir [string repeat "../" $pwd_depth]$lib_dir
    }
}

puts "-I- corner_lib_setup.tcl : lib_dir = $lib_dir"


################################################################################
## source package first

source $lib_dir/corner_lib.tcl

################################################################################

namespace eval corner {

    ####################
    ## opcond

    set opcond_index { P V T VCO VIO VIOB }
    array set opcond_spec {
        delay_corner_1     {typ     12_33_18     25    1.2     3.3    1.8}
        delay_corner_2     {typ     12_33_33     25    1.2     3.3    3.3}
        delay_corner_3     {typ     12_18_18     25    1.2     1.8    1.8}
        delay_corner_7     {fast    12_33_18    -40    1.32    3.6    1.95}
        delay_corner_8     {fast    12_33_33    -40    1.32    3.6    3.6}
        delay_corner_9     {fast    12_18_18    -40    1.32    1.95   1.95}
        delay_corner_10    {slow    12_18_18    -40    1.08    1.6    1.6}
        delay_corner_11    {slow    12_33_18    -40    1.08    2.85   1.6}
        delay_corner_12    {slow    12_33_33    -40    1.08    2.85   2.85}
        delay_corner_16    {slow    12_18_18    125    1.08    1.6    1.6}
        delay_corner_17    {slow    12_33_18    125    1.08    2.85   1.6}
        delay_corner_18    {slow    12_33_33    125    1.08    2.85   2.85}

        delay_corner_22    {typ     10_xx_xx     25    1.0     3.3    3.3}
        delay_corner_24    {fast    10_xx_xx    -40    1.1     3.6    3.6}
        delay_corner_25    {slow    10_xx_xx    -40    0.9     1.6    1.6}
        delay_corner_27    {slow    10_xx_xx    125    0.9     1.6    1.6}

        delay_corner_29    {fast    12_33_33    125    1.32    3.6    3.6}
    }

    ####################
    ## RC

    array set rc_spec {
        "fast -40"     {cbest_m40  cworst_m40  rcbest_m40  rcworst_m40}
        "fast 125"     {cbest_125  cworst_125  rcbest_125  rcworst_125}
        "typ 25"       {ctyp_25}
        "slow -40"     {cworst_m40  cbest_m40  rcworst_m40  rcbest_m40}
        "slow 125"     {cworst_125  cbest_125  rcworst_125  rcbest_125}
    }

    ####################
    ## MODE
    ## FIXME : missing func_qspi_div1_mode_1v8 ?

    array set mode_spec {
        "12_33_33"    {func_mode      func_qspi_div1_mode  sti_mode  scan_shift  scan_capture  capture_fast dont_touch}
        "12_18_18"    {func_mode_1v8  func_qspi_div1_mode  sti_mode}
        "12_33_18"    {func_mode_1v8  func_qspi_div1_mode}
        "10_xx_xx"    {func_mode_backup}
    }


    #####################
    ## constraints prefix file name for tcl into constraints/PNR_SETTINGS
    # used in create_constraints_mode
    # used to generate the following lines in the EDI view definition file :
    # for func_mode_1v8: ./constraints/PNR_SETTINGS/func_mode_POSTCTS_setting.tcl
    array set pnr_settings_constraints_prefix_name {
          func_mode  func_mode
          func_qspi_div1_mode func_mode
          sti_mode sti_mode
          scan_shift scan_shift
          scan_capture scan_capture
          capture_fast capture_fast
          func_mode_1v8 func_mode
          dont_touch dont_touch
          func_mode_backup func_mode_backup
	 }

    #####################
    ## constraints prefix file name for tcl into constraints/TIMING_MODE
    # used in create_constraints_mode
    array set timing_modes_constraints_prefix_name {
          func_mode  func_mode_1v8
          func_qspi_div1_mode func_qspi_div1_mode
          sti_mode  sti
          scan_shift scan_shift
          scan_capture capture
          capture_fast capture
          func_mode_1v8 func_mode_1v8
          dont_touch drv
		  func_mode_backup func_mode_backup
	}


}


################################################################################

namespace eval lib {

    ####################
    ## package variables

    set search_path  "$lib_dir/patch  $lib_dir/import"
    set view_list  {dir  lef  mw  nldm.lib  nldm.db  ccs.lib  ccs.db  cdb  apl.cdev  apl.pwcdev  apl.spiprof}
    set pvt_view_list            {nldm.lib  nldm.db  ccs.lib  ccs.db  cdb  apl.cdev  apl.pwcdev  apl.spiprof}

    array set pvt_spec {
        1v2              { ${P}_${VCO}_${T} }
        1v2_3v3          { ${P}_${VCO}_${VIO}_${T} }
        1v2_3v3_scaling  { ${P}_${VCO}_${VIO}_${T}  ${P}_${VCO}_${VIOB}_${T} }
        3v3              { ${P}_${VIO}_${T} }
        3v3_scaling      { ${P}_${VIO}_${T}  ${P}_${VIOB}_${T} }
        3v3_1v2          { ${P}_${VIO}_${VCO}_${T} }
        3v3_1v2_scaling  { ${P}_${VIO}_${VCO}_${T}  ${P}_${VIOB}_${VCO}_${T} }
        3v3_3v3          { ${P}_${VIO}_${VIOB}_${T} ${P}_${VIOB}_${VIO}_${T} }
    }

    # lib_list = { name { spec = dir type } name { spec } ... }
    set lib_list {
        uk65lsclpmvbbr    { uk65lsclpmvbbr    1v2  core }
        uk65lsclpmvbbh    { uk65lsclpmvbbh    1v2  core }
        rfo_s9hvtecocdmlib_n001    { RFO_S9HVTECOCDMLIB_N001    1v2 core }
        rfo_s9hvtecolib_n001    { RFO_S9HVTECOLIB_N001    1v2 core }
        nto_pws_core100m_n1    { NTO_PWS_CORE100M_N1    1v2 core }
        rfo_s9rvtlpsclib    { RFO_S9RVTLPSCLIB    1v2 core }
        rfo_s9hvtdelay    { RFO_S9HVTDELAY    1v2 core }
        rfo_s9hvtcsclib_n001    { RFO_S9HVTCSCLIB_N001    1v2 core }
        rfo_decapox25lib    { RFO_DECAPOX25LIB    1v2 core }
        rfo_s9hvtlevelshifter_3v3_1v2_n001    { RFO_S9HVTLEVELSHIFTER_3V3_1V2_N001    3v3_1v2_scaling core }
        rfo_s39x3hvtlevelshifter_1v2_3v3    { RFO_S39X3HVTLEVELSHIFTER_1V2_3V3    1v2_3v3_scaling  io }
        S39SC33X25lib    { S39SC33X25LIB    3v3_scaling  io }
        S39CSC33X25lib    { S39CSC33X25LIB    3v3_scaling  io }
        rfo_s39x3ecodmlib    { RFO_S39X3ECOCDMLIB    3v3_scaling io }
        ascdd7    { PROJECTDD7    3v3_3v3 io }
        rfo_dio33x25hm6_0t1flib    { RFO_DIO33X25HM6_0T1FLIB    1v2_3v3_scaling io }
        rfo_dtwio33x25hm6_0t1flib    { RFO_DTWIO33X25HM6_0T1FLIB    1v2_3v3_scaling io }
        rfo_dbkupio33x25hm6_0t1flib    { RFO_DBKUPIO33X25HM6_0T1FLIB    1v2_3v3_scaling io }
        rfo_desd33x25m6_0t1flib    { RFO_DESD33X25M6_0T1FLIB    1v2_3v3_scaling io }
        rfo_dio33hvm6_0t1flib    { RFO_DIO33HVM6_0T1FLIB    1v2_3v3_scaling io }
        ascdhd    { PROJECTDHD    1v2_3v3 core }
        nto_ring_osc_n1    { NTO_RING_OSC_N1    1v2 core }
        nto_mposc_48m_n1    { NTO_MPOSC_48M_N1    3v3 io }
        nto_rcosc_ulp32k_n1    { NTO_RCOSC_ULP32k_N1    3v3  io }
        nto_por33_n1    { NTO_POR33_N1    3v3  io}
        sjo_dfll48m    { SJO_DFLL48M    1v2_3v3  core }
        nto_topreg_samd50_n1    { NTO_TOPREG_SAMD50_N1    1v2_3v3 io }
        nto_adc_sar12blp_n1    { NTO_ADC_SAR12BLP_N1    1v2_3v3 io }
        sjo_ana_acsystem_n1    { SJO_ANA_ACSYSTEM_N1    3v3 io }
        nto_detref_samd50_n1    { NTO_DETREF_SAMD50_N1    1v2_3v3 io }
        rfo_cdm_dusb33x25hm6_0t1f    { RFO_CDM_DUSB33X25HM6_0T1F    1v2_3v3 io }
        nto_xtalosc_32k_n1    { NTO_XTALOSC_32K_N1    3v3 io }
        rfo_dac_da112_at65100    { RFO_DAC_DA112_AT65100    1v2_3v3 io }
        rfo_psw_sram_001    { RFO_PSW_SRAM_001    1v2 core }
        rfo_pll_digpllat65n_200m_n0    { RFO_PLL_DIGPLLAT65N_200M_N0    1v2 core }
        nto_ptc_n1    { NTO_PTC_N1    3v3  io}
        nto_pws_vswout_n1    { NTO_PWS_VSWOUT_N1    3v3 io }
        rfo_cap_cap054    { RFO_CAP_CAP054    1v2 core }
        DPRAM_256x32cm4bw    { DPRAM_256x32cm4bw    1v2 core }
        DPRAM_1Kx32cm4bw    { DPRAM_1Kx32cm4bw    1v2 core }
        SRAM_1Kx32cm4bw    { SRAM_1Kx32cm4bw    1v2 core }
        SRAM_2Kx32cm8bw    { SRAM_2Kx32cm8bw    1v2 core }
        SRAM_6Kx32cm16bw    { SRAM_6Kx32cm16bw    1v2 core }
        SRAM_8Kx32cm16bw    { SRAM_8Kx32cm16bw    1v2 core }
        REGFILE_256x32cm4bw    { REGFILE_256x32cm4bw    1v2 core }
        REGFILE_64x21cm4bw    { REGFILE_64x21cm4bw    1v2  core }
        REGFILE_16x24cm4bw    { REGFILE_16x24cm4bw    1v2  core }
        ROM_10240x32    { ROM_10240x32    1v2 core }
    }

    # lib_spec (array) = same data as lib_list , but array for convenient access
    array set lib_spec $lib_list

    # libset (array) = defines several libsets (eg. for different tasks / power-domains / sites)
    # libset '' = default libset with all libs (important note: keep order of lib_list)
    foreach { name spec } $::lib::lib_list {
        lappend libset() $name
    }

    # libsets per site (1v2 or 3v3)
    foreach { name spec } $::lib::lib_list {
        set type [lindex $spec 2]
        switch -exact $type {
            core  { lappend libset(core) $name }
            io    { lappend libset(io) $name }
        }

#        set type [lindex $spec 1]
#        switch -exact $type {
#            1v2 -               3v3_1v2 - 3v3_1v2_scaling              { lappend libset(core) $name }
#            3v3 - 3v3_scaling - 1v2_3v3 - 1v2_3v3_scaling - 3v3_3v3    { lappend libset(io) $name }
#        }

    }

    array set libset {
        target    { uk65lsclpmvbbr uk65lsclpmvbbh S39SC33X25lib S39CSC33X25lib ascdd7 rfo_s9hvtlevelshifter_3v3_1v2_n001 rfo_s39x3hvtlevelshifter_1v2_3v3 rfo_s9rvtlpsclib}
        target1v2 { uk65lsclpmvbbr uk65lsclpmvbbh  rfo_s9hvtlevelshifter_3v3_1v2_n001 rfo_s9rvtlpsclib}
        target3v3 { S39SC33X25lib S39CSC33X25lib  rfo_s39x3hvtlevelshifter_1v2_3v3 ascdd7}
    }

    array set pvt_exceptions {
        {rfo_decapox25lib typ_1v00_t25} typ_1v20_t25
        {rfo_decapox25lib fast_1v10_tm40} fast_1v32_tm40
        {rfo_dio33x25hm6_0t1flib fast_1v10_3v60_t125} fast_1v32_3v60_t125
        {rfo_dtwio33x25hm6_0t1flib fast_1v10_3v60_t125} fast_1v32_3v60_t125
        {rfo_dbkupio33x25hm6_0t1flib fast_1v10_3v60_t125} fast_1v32_3v60_t125
        {ascdhd typ_1v00_1v80_t25} typ_1v20_1v80_t25 
        {ascdhd typ_1v00_3v30_t25} typ_1v20_3v30_t25
        {ascdhd fast_1v10_1v95_tm40} fast_1v32_1v95_tm40
        {ascdhd fast_1v10_3v60_tm40} fast_1v32_3v60_tm40
        {ascdhd fast_1v32_1v95_t125} fast_1v32_1v95_tm40
        {ascdhd fast_1v32_3v60_t125} fast_1v32_3v60_tm40
        {ascdhd slow_0v90_2v85_tm40} slow_1v00_2v85_tm40
        {ascdhd slow_0v90_2v85_t125} slow_1v00_2v85_tm40
        {rfo_cdm_dusb33x25hm6_0t1f slow_0v90_1v60_tm40} slow_1v08_1v60_tm40
        {rfo_cdm_dusb33x25hm6_0t1f slow_0v90_2v85_tm40} slow_1v08_2v85_tm40
        {rfo_cdm_dusb33x25hm6_0t1f slow_0v90_1v60_t125} slow_1v08_1v60_t125
        {rfo_cdm_dusb33x25hm6_0t1f slow_0v90_2v85_t125} slow_1v08_2v85_t125
        {rfo_dac_da112_at65100 typ_1v00_1v80_t25} typ_1v20_1v80_t25
        {rfo_dac_da112_at65100 typ_1v00_3v30_t25} typ_1v20_3v30_t25
        {rfo_dac_da112_at65100 fast_1v10_1v95_tm40} fast_1v32_1v95_tm40
        {rfo_dac_da112_at65100 fast_1v10_3v60_tm40} fast_1v32_3v60_tm40
        {rfo_dac_da112_at65100 fast_1v10_3v60_t125} fast_1v32_3v60_tm40
        {rfo_dac_da112_at65100 fast_1v32_3v60_t125} fast_1v32_3v60_tm40
        {rfo_dac_da112_at65100 slow_0v90_1v60_tm40} slow_1v08_1v60_tm40
        {rfo_dac_da112_at65100 slow_0v90_2v85_tm40} slow_1v08_2v85_tm40
        {rfo_dac_da112_at65100 slow_0v90_1v60_t125} slow_1v08_1v60_t125
        {rfo_dac_da112_at65100 slow_0v90_2v85_t125} slow_1v08_2v85_t125
        {rfo_psw_sram_001 typ_1v00_t25} typ_1v20_t25
        {rfo_psw_sram_001 fast_1v10_tm40} fast_1v32_tm40
        {rfo_cap_cap054 typ_1v00_t25} typ_1v20_t25
        {rfo_cap_cap054 fast_1v10_tm40} fast_1v32_tm40
        {rfo_cap_cap054 slow_0v90_tm40} slow_1v08_tm40
        {rfo_cap_cap054 slow_0v90_t125} slow_1v08_t125
    }

    ####################
    ## get_file_name
    ## override default one !!

    proc get_file_name { name view pvt } {

        set dir [lindex $::lib::lib_spec($name) 0]

        switch -exact $name {
            uk65lsclpmvbbh - uk65lsclpmvbbr {
                switch -exact $view {
                    dir                 { return ${dir} }
                    lef                 { return ${dir}/lef/${name}.lef }
                    mw                  { return ${dir}/astro/${name} }
                    nldm.lib            { return ${dir}/synopsys/${name}-${pvt}+nldm.lib }
                    nldm.db             { return ${dir}/synopsys/${name}-${pvt}+nldm.db }
                    ccs.lib             { return ${dir}/synopsys/ccs/${name}-${pvt}+ccs.lib.gz }
                    ccs.db              { return ${dir}/synopsys/ccs/${name}-${pvt}+ccs.db }
                    cdb                 { return ${dir}/celtic/${name}-${pvt}.cdb }
                    apl.cdev            { return ${dir}/apl/${name}-${pvt}.cdev }
                    apl.pwcdev          { return ${dir}/apl/${name}-${pvt}.pwcdev }
                    apl.spiprof         { return ${dir}/apl/${name}-${pvt}.spiprof }
                }
            }
            default   {
                switch -exact $view {
                    dir                 { return ${dir} }
                    lef                 { return ${dir}/lef/${name}.lef }
                    mw                  { return ${dir}/mw/${name} }
                    nldm.lib            { return ${dir}/lib/${name}-${pvt}+nldm.lib }
                    nldm.db             { return ${dir}/db/${name}-${pvt}+nldm.db }
                    ccs.lib             { return ${dir}/lib/${name}-${pvt}+ccs.lib.gz }
                    ccs.db              { return ${dir}/db/${name}-${pvt}+ccs.db }
                    cdb                 { return ${dir}/cdb/${name}-${pvt}.cdb }
                    apl.cdev            { return ${dir}/apl/${name}-${pvt}.cdev }
                    apl.pwcdev          { return ${dir}/apl/${name}-${pvt}.pwcdev }
                    apl.spiprof         { return ${dir}/apl/${name}-${pvt}.spiprof }
                }
            }
        }

    }

}


################################################################################
## tests are run only when script is executed (not sourced from tclsh or other program)

if { ! [info exists ::argv0] } { return }
if { [file tail $::argv0] != "corner_lib_setup.tcl" } { return }


## test 1 : dir lef

foreach view $::lib::view_list {
    if [::lib::view_is_pvt $view] { continue }
    puts "--------------------------------------------------------------------------------"
    foreach f [::lib::all_lib $view] { puts "        $f" }
}

## test 2 : delay_corner_1 (typ) , print all_lib for some pvt views

set view_l [lsearch -all -inline -not -glob $::lib::pvt_view_list "apl.*"]

puts "--------------------------------------------------------------------------------"
::corner::set_corner  delay_corner_1
foreach view { nldm.lib ccs.db } {
    foreach f [::lib::all_lib $view]                  { puts "        $f" }
    foreach f [::lib::all_lib $view target   -short ] { puts "        $f" }
    foreach f [::lib::all_lib $view core     -short ] { puts "        $f" }
    foreach f [::lib::all_lib $view io       -short ] { puts "        $f" }
    foreach f [::lib::all_lib $view -scaling -short ] { puts "        $f" }
    foreach f [::lib::all_lib $view -all     -short ] { puts "        $f" }
}

## test 3 : all delay_corners , all_lib without printing (pvt views , not apl)

set view_l [lsearch -all -inline -not -glob $::lib::pvt_view_list "apl.*"]

foreach dlc [lsort -dictionary [array names ::corner::opcond_spec]] {
    puts "--------------------------------------------------------------------------------"
    ::corner::set_corner $dlc
    foreach view $view_l {
        ::lib::all_lib $view -all
    }
}

## test 4 : delay_corner_29 (redhawk) , print all_lib (pvt+apl views)

set view_l $::lib::pvt_view_list

puts "--------------------------------------------------------------------------------"
::corner::set_corner  delay_corner_29
foreach view $view_l {
    foreach f [::lib::all_lib $view -all -short] { puts "        $f" }
}


