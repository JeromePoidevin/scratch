
################################################################################

namespace eval corner {

    ####################
    ## opcond

    variable opcond_index
    variable opcond_spec
    variable opcond
    variable opcondstr

    proc v2str { val } {
        if { ! [string is double -strict $val] } {
            error "::corner::v2str : '$val' not a valid double"
        }
        return [string map {. v} [format "%.2f" $val]]
    }

    proc t2str { val } {
        if { ! [string is integer -strict $val] } {
            error "::corner::v2str : '$val' not a valid integer"
        }
        set val [string map {- m} $val]
        return "t$val"
    }

    proc set_opcond { values } {

        if { [llength $values] != [llength $::corner::opcond_index] } {
            error "::corner::set_opcond : values'length differs from opcond_index'length
    values = { $values }
    opcond_index  = { $::corner::opcond_index }
"
        }

        set ::corner::opcond {}
        set ::corner::opcondstr {}

        # double iteration : idx in index'list / val in values'list
        foreach idx $::corner::opcond_index val $values {
            lappend ::corner::opcond $idx $val
            switch -glob $idx {
                V       { lappend ::corner::opcondstr $idx $val }
                V*      { lappend ::corner::opcondstr $idx [::corner::v2str $val] }
                T       { lappend ::corner::opcondstr $idx [::corner::t2str $val] }
                default { lappend ::corner::opcondstr $idx $val }
            }
        }
        puts "-I- ::corner::set_opcond $values
    opcond    = $::corner::opcond
    opcondstr = $::corner::opcondstr
    all_rc    = [::corner::all_rc]
    all_modes = [::corner::all_modes]"

        ::lib::eval_pvt_spec
    }

    proc set_corner { name } {
        set key_val [array get ::corner::opcond_spec $name]
        if { $key_val == "" } {
            error "::corner::set_corner '$name' : not defined"
        }
        puts "-I- ::corner::set_corner $name"
        ::corner::set_opcond [lindex $key_val 1]
    }

    proc eval_pvt { pvt_string } {
        foreach { idx val } $::corner::opcondstr {
            # define variables P V T according to ::corner
            set $idx $val
        }
        # evaluate pvt = f( P V T )
        set pvt [subst $pvt_string]
        return $pvt
    }

    ####################
    ## RC

    variable RC
    variable rc_spec

    proc all_rc {} {
        array set tmp $::corner::opcond
        set key_val [array get ::corner::rc_spec "$tmp(P) $tmp(T)"]
        return [lindex $key_val 1]
    }

    proc set_rc { name } {
        if { [lsearch [::corner::all_rc] $name] < 0 } {
            error "::corner::set_rc $name : not defined for P='$::corner::opcond(P) T='$::corner::opcond(T)'"
        }
        puts "-I- ::corner::set_rc $name"
        set ::corner::RC $name
    }

    ####################
    ## MODE

    variable MODE
    variable mode_spec

    proc all_modes {} {
        array set tmp $::corner::opcond
        set key_val [array get ::corner::mode_spec $tmp(V)]
        return [lindex $key_val 1]
    }

    proc set_mode { name } {
        if { [lsearch [::corner::all_modes] $name] < 0 } {
            error "::corner::set_mode $name : not defined for V='$::corner::opcond(V)'"
        }
        puts "-I- ::corner::set_mode $name"
        set ::corner::MODE $name
    }
}


################################################################################

namespace eval lib {

    ####################
    ## package variables

    variable search_path { ../../lib/patch  ../../lib/import }
    variable opt
    array set opt { short_long "-long" all_pvt "-one" }

    variable view_list
    variable pvt_view_list

    variable pvt_spec

    # lib_list = { name { spec = dir type } name { spec } ... }
    variable lib_list

    # lib_spec (array) = same data as lib_list , but array for convenient access
    variable lib_spec
#    array set lib_spec $lib_list

    # libset (array) = defines several libsets (eg. for different tasks / power-domains / sites)
    variable libset
    # libset '' = default libset with all libs (important note: keep order of lib_list)
#    foreach { name spec } $::lib::lib_list {
#        lappend libset() $name
#    }

    variable pvt_exceptions

    ####################
    ## checker procs

    proc check_search_path {} {
        puts "-I- ::lib::check_search_path : $::lib::search_path"
        foreach path $::lib::search_path {
            if { ! [file isdirectory $path] } {
                error "::lib::check_search_path : path not found '$path'"
            }
        }
    }

    proc check_view { view } {
        if { [lsearch -exact $::lib::view_list $view] >= 0 } { return 1 }
        error "::lib::check_view $view : unknow view"
    }
    
    proc view_is_pvt { view } {
        return [expr [lsearch -exact $::lib::pvt_view_list $view] >= 0]
    }
    
    ####################
    ## get_file_name
    ## this is only a very basic template which should be overriden in corner_lib_setup.tcl !!

    proc get_file_name { name view pvt } {

        set dir [lindex $::lib::lib_spec($name) 0]

        switch -exact $name {
            default   {
                switch -exact $view {
                    dir                 { return ${dir} }
                    default             { return ${dir}/${view}/${name}-${pvt}.${view} }
                }
            }
        }
    }

    ####################
    ## get_file

    proc get_file { name view {pvt ""} } {

        if { $pvt=="" && [::lib::view_is_pvt $view] } {
            error "::lib::get_file $view : must specify 'pvt'"
        }

        # name + view + pvt -> file_name
        set file [::lib::get_file_name $name $view $pvt]

        # look for file in search_path
        foreach path $::lib::search_path {

            if { $path != "" } { set f $path/$file }

            # found
            if [file exists $f] {
                switch -exact -- $::lib::opt(short_long) {
                    "-short" { set f [file tail $f] }
                    "-long"  { }
                    default     { error "::lib::get_file : bad option short_long = $::lib::opt(short_long)" }
                }
                return $f
            }
        }
        
        # not found
        if [string equal -length 3 $view "ccs"] {
            set nldm "nldm.[string range $view 4 end]"
            puts "-W- $f : not found , use '$nldm'"
            return [::lib::get_file $name $nldm $pvt]
        }
        
        # failed
        puts "-E- $f : not found"
        return
    }

    ####################
    ## get_lib

    proc get_lib { name view } {

        # view is not PVT
        if { ! [::lib::view_is_pvt $view] } {
            return [::lib::get_file $name $view]
        }

        # view is PVT
        set spec  $::lib::lib_spec($name)
        set dir   [lindex $spec 0]
        set type  [lindex $spec 1]
        set pvt_l $::lib::pvt_spec_eval($type)

        # depending on opt(all_pvt) , return first PVT / all PVT / none
        switch -exact -- $::lib::opt(all_pvt) {
            "-one"      { set pvt_l [lindex $pvt_l 0] }
            "-all"      {}
            "-scaling"  { if { [llength $pvt_l] < 2 } { return } }
            default     { error "::lib::get_lib : bad option all_pvt = $::lib::opt(all_pvt)" }
        }

        set files_l {}
        foreach pvt $pvt_l {
            # exceptions
            set ex [array get ::lib::pvt_exceptions "$name $pvt"]
            if { $ex != "" } {
                set ex [lindex $ex 1] ; # array get returns {name val} ; keep val
                puts "-W- ::lib::get_lib $name : exception $pvt -> $ex"
                set pvt $ex
            }
            # get file
            set f [::lib::get_file $name $view $pvt]
            if { $f != "" } { lappend files_l $f }
        }
        return $files_l
    }
    
    ####################
    ## all_lib

    proc all_lib { view args } {

        ::lib::check_view $view
        ::lib::check_search_path

        # arguments

        set libset ""

        set ::lib::opt(short_long) "-long"
        set ::lib::opt(all_pvt) "-one"

        foreach a $args {
            switch -glob -- $a {
                "-long"    { set ::lib::opt(short_long) $a }
                "-short"   { set ::lib::opt(short_long) $a }
                "-one"     { set ::lib::opt(all_pvt) $a }
                "-all"     { set ::lib::opt(all_pvt) $a }
                "-scaling" { set ::lib::opt(all_pvt) $a }
                "-*"       { lappend err $a }
                default    {
                    if [info exists ::lib::libset($a)] { set libset $a } else { lappend err $a }
                }
            }
        }

        puts "-I- ::lib::all_lib  '$view'  '$libset'  $::lib::opt(all_pvt)  $::lib::opt(short_long)"

        if [info exists err] {
            error "::lib::all_lib : bad options ignored : $err"
        }
        if { ! [::lib::view_is_pvt $view] } {
            if { $::lib::opt(all_pvt) != "-one" } {
                error "::lib::all_lib : '$view' is not pvt , cannot use $::lib::opt(all_pvt)"
            }
        }
        if { ! $::lib::pvt_is_scaling } {
            if { $::lib::opt(all_pvt) == "-scaling" } {
                puts "-W- ::lib::all_lib : pvt requires no scaling , -scaling returns {}"
                return
            }
        }

        # loop on libs

        set all {}
        foreach name $::lib::libset($libset) {
            set f [::lib::get_lib $name $view]
            if { $f != "" } { lappend all $f }
        }
        return $all
    }

    ####################
    ## eval_pvt_spec

    variable pvt_spec_eval
    variable pvt_is_scaling 0

    proc eval_pvt_spec { } {
        puts "-I- ::lib::eval_pvt_spec"

        set ::lib::pvt_is_scaling 0

        foreach { type } [lsort -dictionary [array names ::lib::pvt_spec]] {

            set pvt_l {}

            # evaluate pvt'list = f( P V T )
            set pvt_eval [::corner::eval_pvt $::lib::pvt_spec($type)]

            # uniquify the list
            foreach pvt $pvt_eval {
                if { [lsearch -exact $pvt_l $pvt] < 0 } { lappend pvt_l $pvt }
            }

            # remember when any lib requires scaling
            if { [llength $pvt_l] > 1 } { set ::lib::pvt_is_scaling 1 }

            set ::lib::pvt_spec_eval($type) $pvt_l
            puts "    $type    { $pvt_l }"
        }
    }

}


################################################################################

