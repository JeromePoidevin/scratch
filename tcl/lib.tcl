#! /bin/env tclsh

namespace eval lib {

    variable root_dir "lib/import"
    variable P
    variable VCO
    variable VIO
    variable VIOB
    variable T
    variable lib_list {
        { ubh         { ${P}_${VCO}_${T} } }
        { ls_12_33    { ${P}_${VCO}_${VIO}_${T}  ${P}_${VCO}_${VIOB}_${T} } }
        { ls_33_33    { ${P}_${VIO}_${VIOB}_${T} ${P}_${VIOB}_${VIO}_${T} } }
    }

    proc check_view { view } {
        if { [lsearch -exact {lef nldm ccs cdb} $view] >= 0 } { return 1 }
        error "-E- check_view $view : unknow view"
    }
    
    proc view_is_pvt { view } {
        return [expr [lsearch -exact {nldm ccs cdb} $view] >= 0]
    }
    
    proc get_file { name view {pvt ""} } {

        if { $pvt=="" && [view_is_pvt $view] } {
            error "-E- get_file $view : must specify 'pvt'"
        }

        variable root_dir
        set dir "${root_dir}/[string toupper $name]"

        switch -exact $name {
            ubh - ubb   {
                switch -exact $view {
                    lef        { set f "${dir}/lef/${name}.lef" }
                    nldm - ccs { set f "${dir}/synopsys/${name}-${pvt}+${view}.lib" }
                    cdb        { set f "${dir}/cdb/${name}-${pvt}.cdb" }
                }
            }
            default   {
                switch -exact $view {
                    lef        { set f "${dir}/lef/${name}.lef" }
                    nldm - ccs { set f "${dir}/lib/${name}-${pvt}+${view}.lib" }
                    cdb        { set f "${dir}/cdb/${name}-${pvt}.cdb" }
                }
            }
        }
        
        # ok
        if [file exists $f] {
            puts "-I- $f"
            return $f
        }
        
        # not found
        if { $view=="ccs" } {
            puts "-W- $f : not found , try 'nldm'"
            return [get_file $name nldm $pvt]
        }
        
        # failed
        puts "-E- $f : not found"
        return
    }

    proc get_lib { name view {pvt ""} } {
        variable P
        variable VCO
        variable VIO
        variable VIOB
        variable T

        if { $pvt=="" } {
            return [get_file $name $view]
        } else {
            # evaluate pvt = P VCO VIO VIOB T
            set pvt [subst $pvt]
            # exceptions
            switch -exact [list $name $pvt] {
                "toto fast_1v0_tm40" { set pvt "fast_1v2_tm40" }
            }
            return [get_file $name $view $pvt]
        }
    }
    
    proc all_lib { view } {
        variable lib_list
        check_view $view
        set view_is_pvt [view_is_pvt $view]

        set all {}
        foreach spec $lib_list {
            set name [lindex $spec 0]
            if $view_is_pvt {
                # pvt = first combination of P VCO VIO VIOB T
                set pvt  [lindex [lindex $spec 1] 0]
                set f [get_lib $name $view $pvt]
            } else {
                set f [get_lib $name $view]
            }
            if { $f != "" } { lappend all $f }
        }
        return $all
    }

    proc all_scaling_lib { view } {
        variable lib_list
        variable VIO
        variable VIOB
        check_view $view
        if { ! [view_is_pvt $view] } { return }
        if { $VIO == $VIOB } { return }

        set all {}
        foreach spec $lib_list {
            set name   [lindex $spec 0]
            set pvt_l  [lindex $spec 1]
            set file_l {}
            # at least two pvt to scale
            if { [llength $pvt_l] < 2 } { continue }
            foreach pvt $pvt_l {
                set f [get_lib $name $view $pvt]
                if { $f != "" } { lappend file_l $f }
            }
            lappend $all $file_l
        }
        return $all
    }
    
    proc set_corner { P VCO VIO VIOB T } {
        set lib::P $P
        set lib::VCO $VCO
        set lib::VIO $VIO
        set lib::VIOB $VIOB
        set lib::T $T
    }
    
    proc test { P VCO VIO VIOB T } {
        set_corner $P $VCO $VIO $VIOB $T
        foreach view { lef nldm ccs cdb } {
            puts "... all_lib $view"
            all_lib $view
            puts "... all_scaling_lib $view"
            all_scaling_lib $view
        }
    }
}


lib::test typ 1v2 3v3 1v8 t25

