
package provide at91cts 1.0

package require at91com 1.0


namespace eval at91cts {

variable debug 1

variable cts_attributes {
    { cts_num                  design  int      "all"  "design          : number , incremented for each add_CTS_tree" }
    { cts_tree_param           design  string   "all"  "design          : " }
    { cts_macromodel_param     design  string   "all"  "design          : " }
    { cts_num                  pin   int      "all"  "root (output) pins : number , incremented for each add_CTS_tree" }
    { cts_tree                 pin   string   "all"  "root (output) pins : array of properties set by add_CTS_tree" }
    { cts_tree_group           pin   string   "all"  "root (output) pins : optional group set by add_CTS_tree" }
    { cts_stats                pin   string   ""     "root (output) pins : array of statistics" }
    { cts_spec                 pin   string   "all"  "any (input) pins : specification set by set_CTS_pin_attribute" }
    { cts_group                pin   string   "all"  "any (input) pins : optional leafpingroup set by set_CTS_pin_attribute" }
    { cts_macromodel           pin   string   "all"  "any (input) pins : MacroModel specification set by add_CTS_macromodel" }
    { cts_dynamic              pin   string   "all"  "any (input) pins : DynamicMacroModel specification set by add_CTS_macromodel" }
    { cts_traced               pin   string   ""     "any         pins : list of 'cts_num' traced through pin" }
    { cts_traced               cell  string   ""     "any        cells : list of 'cts_num' traced through cell" }
    { cts_data                 pin   boolean  ""     "any (input) pins : CTS traced through pin but pin is data" }
    { cts_unpropagated         pin   string   ""     "any (input) pins : in case_sensistive mode , list of 'cts_num' not propagated" }
    { cts_loop                 pin   string   ""     "any (input) pins : when loop is detected (list of 'cts_num')" }
    { cts_intra_reconv         pin   string   ""     "any (input) pins : when intra-reconvergence is detected (list of 'cts_num')" }
    { cts_inter_reconv         pin   string   ""     "any (input) pins : when inter-reconvergence is detected (list of 'cts_num')" }
    { cts_preserve_not_traced  pin   string   ""     "any (input) pins : when preserve_not_traced is detected (list of 'cts_num')" }
}
# note: design'cts_num is redundant (one can find all pin'cts_num) ; but it helps avoid incremental update_timing during constraints-read

variable reset_attributes
array set reset_attributes     { design {} pin {} cell {} alldesign {} allpin {} allcell {} }

foreach attribute $cts_attributes {
    set attr  [lindex $attribute 0]
    set class [lindex $attribute 1]
    set type  [lindex $attribute 2]
    set rst   [lindex $attribute 3]
    set msg   [lindex $attribute 4]
    puts "-I- $attr : $class : $type : reset $rst : $msg"
    define_user_attribute $attr -class $class -type $type 
    lappend reset_attributes(all$class) $attr
    if { $rst == "" } {
        lappend reset_attributes($class) $attr
    }
}

variable cts_spec_valid_values { leaf unsync excluded through preserve }

variable cts_options
set cts_options(case_sensitive) 1
set cts_options(stop_at_intra_reconv) 1
set cts_options(stop_at_inter_reconv) 0
set cts_options(stop_at_preserve_not_traced) 0

variable tree_param
variable macromodel_param

# TODO : store tree_param and macromodel_param as chip'attributes ?

################################################################################ 

proc reset_CTS {{opt ""}} {

    foreach attr $::at91cts::reset_attributes(${opt}design) {
        remove_user_attribute -quiet [get_design] $attr
    }
    foreach attr $::at91cts::reset_attributes(${opt}pin) {
        remove_user_attribute -quiet [get_pins -hier -leaf] $attr
    }
    foreach attr $::at91cts::reset_attributes(${opt}cell) {
        remove_user_attribute -quiet [get_cells -hier -filter {is_hierarchical==false} ] $attr
    }
}

################################################################################ 

proc _sort_get_pins { pins_list } {

    set pins_coll [get_pins -leaf $pins_list]
    set pins_coll [sort_collection -dictionary $pins_coll full_name]
    return $pins_coll
}

################################################################################ 

proc set_CTS_pin_attribute { args } {

    set help {
# SYNTAX
#           at91cts::set_CTS_pin_attribute
#                    (-spec spec_name)
#                     -pin  pin_object
#                     -type type_name 
#                    (-group group_name)
#
#         ( string             spec_name - for backward compatibility )
#           collection|string  pin_object
#           string             type_name
#         ( string             group_name )
#
# DESCRIPTION
#           Sets a CTS attribute on pin(s).
}

    # {{{ Arguments analysis
    ::at91com::get_switches [list \
      Switches { \
        {-spec} { \
          Variable {_backward_compatibility_} \
          Double   {True} \
        } \
        {-pin} { \
          Variable {pin_list} \
          Double   {True} \
          Required {True} \
        } \
        {-type} { \
          Variable {type} \
          Double   {True} \
          Array    { leaf unsync excluded through preserve leafpingroup } \
          Required {True} \
        } \
        {-group} { \
          Variable {group_name} \
          Double   {True} \
          Required {{ -type leafpingroup }} \
        } \
      } \
      {Args} {args} \
      Usage [::at91com::get_robodoc_syntax $help] \
      Help  $help \
    ]
    # }}} Arguments analysis
  
  
    set pin_list [::at91cts::_sort_get_pins $pin_list]
  
    if { $type == "leafpingroup" } {

        foreach_in_collection pin $pin_list {
            set cts_group [get_attribute -quiet $pin cts_group]
            if { $cts_group == "" } {
                puts "-I- set_CTS_pin_attribute -group $group -pin [get_object_name $pin]"
                set_user_attribute -quiet $pin cts_group $group_name
            } elseif { $group_name == $cts_group } {
                puts "-W- set_CTS_pin_attribute -group $group -pin [get_object_name $pin] : already set"
            } else {
                puts "-W- set_CTS_pin_attribute -group $group -pin [get_object_name $pin] : '$cts_group' previously set (keeping first definition)"
            }
        }

     } else {

        foreach_in_collection pin $pin_list {
            set cts_spec [get_attribute -quiet $pin cts_spec]
            if { $cts_spec == "" } {
                puts "-I- set_CTS_pin_attribute -type $type -pin [get_object_name $pin]"
                set_user_attribute -quiet $pin cts_spec $type
            } elseif { $type == $cts_spec } {
                puts "-W- set_CTS_pin_attribute -type $type -pin [get_object_name $pin] : already set"
            } else {
                puts "-W- set_CTS_pin_attribute -type $type -pin [get_object_name $pin] : '$cts_spec' previously set (keeping first definition)"
            }
        }

    }

}

################################################################################ 

proc delete_CTS_pin_attribute { args } {

set help {
# SYNTAX
#           ::at91cts::delete_CTS_pin_attribute
#                     -pin  pin (list or collection)
#                     -spec _backward_compatibility_
#
# DESCRIPTION
#           Delete CTS pin attributes.
}
  # {{{ Arguments analysis
  ::at91com::get_switches [list \
    Switches { \
      {-pin} { \
        Variable {pin_list} \
        Double   {True} \
        Required {True} \
      } \
      {-spec} { \
        Variable {_backward_compatibility_} \
        Double   {True} \
      } \
    } \
    {Args} {args} \
    Usage [::at91com::get_robodoc_syntax $help] \
    Help  $help \
  ]
  # }}} Arguments analysis


    set pin_list [::at91cts::_sort_get_pins $pin_list]
  
    foreach_in_collection pin $pin_list {
        set cts_spec [get_attribute -quiet $pin cts_spec]
        if { $cts_spec == "" } {
            puts "-W- delete_CTS_pin_attribute -pin [get_object_name $pin] : no cts_spec defined"
        } else {
            puts "-I- delete_CTS_pin_attribute -pin [get_object_name $pin]"
            remove_user_attribute -quiet $pin cts_spec
        }
    }

}
 
################################################################################ 

proc CTS_pin_attributed { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

    ::at91com::get_switches [list \
      Switches { \
        {-pin} { \
          Variable {pin} \
          Double   {True} \
          Required {True} \
        } \
        {-type} { \
          Variable {type} \
          Double   {True} \
          Array    { root leaf macromodel dynamic unsync excluded through preserve } \
        } \
        {-spec} { \
          Variable {_backward_compatibility_} \
          Double   {True} \
        } \
      } \
      {Args} {args} \
      Usage "-I- Usage: CTS_pin_attributed -pin <pin> -type <root|leaf|...>\n" \
    ]


    set pin [get_pins -leaf $pin]

    if { [sizeof_collection $pin] != 1 } {
        error "-E- CTS_pin_attributed -pin [get_object_name $pin] : size of -pin different from one"
    }
  
    if { ! [info exists type] } { set type "" }
    set cts_num  [get_attribute -quiet $pin cts_num]
    set cts_spec [get_attribute -quiet $pin cts_spec]

    if { $type=="root" } {
        return [expr {$cts_num!=""} ]
    } elseif { $type=="" } {
        return [expr {$cts_num!="" || $cts_spec!=""} ]
    } else {
        return [expr {$cts_spec==$type} ]
    }
}

################################################################################ 

proc create_CTS_tree_param { args } {
set help {
# SYNTAX
#           at91cts::create_CTS_tree_param
#                     -name tree_param_name
#                     -min_delay min_delay_value
#                     -max_delay max_delay_value
#                     -max_skew max_skew_value
#                     -sink_max_transition sink_max_transition_value
#                     -buf_max_transition buf_max_transition_value
#                     [-route_clk_net]
#                     -buffer buffer_list
#
#           string    tree_param_name
#           float     min_delay_value
#           float     max_delay_value
#           float     max_skew_value
#           float     sink_max_transition_value
#           float     buf_max_transition_value
#           list      buffer_list
#
# DESCRIPTION
#           Creates a CTS tree parameter object.
}

  # {{{ Arguments analysis
  ::at91com::get_switches [list \
    Switches { \
      {-name} { \
        Variable {name} \
        Double   {True} \
        Required {True} \
      } \
      {-min_delay} { \
        Variable {min_delay} \
        Double   {True} \
        Required {True} \
      } \
      {-max_delay} { \
        Variable {max_delay} \
        Double   {True} \
        Required {True} \
      } \
      {-max_skew} { \
        Variable {max_skew} \
        Double   {True} \
        Required {True} \
      } \
      {-sink_max_transition} { \
        Variable {sink_max_transition} \
        Double   {True} \
        Required {True} \
      } \
      {-buf_max_transition} { \
        Variable {buf_max_transition} \
        Double   {True} \
        Required {True} \
      } \
      {-route_clk_net} { \
        Variable {route_clk_net} \
      } \
      {-buffer} { \
        Variable {buffer} \
        Double   {True} \
        Required {True} \
      } \
      {-maxfanout} { \
        Variable {max_fanout} \
        Double   {True} \
      } \
    } \
    {Args} {args} \
    Usage [::at91com::get_robodoc_syntax $help] \
    Help  $help \
  ]
  # }}} Arguments analysis


    if [info exists ::at91cts::macromodel_param($name)] {
        error "-E- CTS tree param '$name' already created"
    }

    puts "-I- Creating CTS tree param '$name'"
    lappend ::at91cts::tree_param($name) "min_delay" $min_delay
    lappend ::at91cts::tree_param($name) "max_delay" $max_delay
    lappend ::at91cts::tree_param($name) "max_skew" $max_skew
    lappend ::at91cts::tree_param($name) "sink_max_transition" $sink_max_transition
    lappend ::at91cts::tree_param($name) "buf_max_transition" $buf_max_transition
    lappend ::at91cts::tree_param($name) "route_clk_net" [info exists route_clk_net]
    lappend ::at91cts::tree_param($name) "buffer" $buffer
    if { [info exists max_fanout] } {
        lappend ::at91cts::tree_param($name) "max_fanout" $max_fanout
    }

    # TODO : store tree_param as chip'attribute ?
}

 
################################################################################ 

proc _lappend_CTS_attribute { obj attr val } {
#    puts "   -D- _lappend_CTS_attribute { [get_object_name $obj] $attr $val }"
    set tmp [get_attribute -quiet $obj $attr]
    lappend tmp $val
    set_user_attribute -quiet $obj $attr $tmp
}

################################################################################ 

proc add_CTS_tree { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

    # {{{ Arguments analysis
    ::at91com::get_switches [list \
      Switches { \
        {-root} { \
          Variable {root} \
          Double   {True} \
          Required {True} \
        } \
        {-type} { \
          Variable {type} \
          Double   {True} \
          Array    { net network } \
          Required {True} \
        } \
        {-allow_reconv} { \
          Variable {allow_reconv} \
        } \
        {-master_end} { \
          Variable {master_end} \
          Double   {True} \
          Array    { root_only leaf macromodel unsync excluded through preserve }
        } \
        {-tree_param} { \
          Variable {tree_param} \
          Double   {True} \
        } \
        {-group} { \
          Variable {group} \
          Double   {True} \
        } \
        {-spec} { \
          Variable {_backward_compatibility_} \
          Double   {True} \
        } \
      } \
      {Args} {args} \
      Usage [::at91com::get_robodoc_syntax $help] \
      Help  $help \
    ]
    # }}} Arguments analysis
  
  
    ## check root_pin
  
    set root_pin  [get_pins -leaf $root]
    set root_name [get_object_name $root_pin]

    if { [sizeof_collection $root_pin] != 1 } {
        error "-E- add_CTS_tree -root $root_name : size of -root different from one"
    }
    if { [get_attribute $root_pin direction] != "out" } {
        error "-E- add_CTS_tree -root $root_name : not an output pin"
    }
    if { [get_attribute -quiet $root_pin cts_num] == "" } {
        puts "-I- add_CTS_tree -root $root_name"
    } else {
        puts "-W- add_CTS_tree -root $root_name : already defined"
    }
  
    ## check other args
  
    if { [info exists tree_param] && ![info exists ::at91cts::tree_param($tree_param)] } {
        error "-E- add_CTS_tree -tree_param $tree_param : does not exist"
    }

    ## cts_num
  
    # note: design'cts_num is redundant (one can find all pin'cts_num) ; but it helps avoid incremental update_timing during constraints-read
    set cts_num [get_attribute -quiet [get_design] cts_num]
    if { $cts_num == "" } { set cts_num 0 } else { incr cts_num }

    set_user_attribute -quiet $root_pin    cts_num $cts_num
    set_user_attribute -quiet [get_design] cts_num $cts_num
  
    ## cts_tree
  
    lappend cts_tree "type" $type

    # TODO : implement allow_reconv or not ?
    lappend cts_tree "allow_reconv" [info exists allow_reconv]

    if { ! [info exists tree_param] } { set tree_param 0 }
    lappend cts_tree "tree_param" $tree_param

    set_user_attribute -quiet $root_pin cts_tree $cts_tree
  
    ## cts_tree_group
  
    if { [info exists group] } {
        set_user_attribute -quiet $root_pin cts_tree_group $group
    }

    ## master_end
  
    if { [info exists master_end] && $master_end!="root_only" } {
        set input_pins [get_pins -of [get_cells -of $root_pin] -filter direction=="in"]
        ::at91cts::set_CTS_pin_attribute -pin $input_pins -type $master_end
    }

}

################################################################################ 

proc create_CTS_macromodel_param { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

  # {{{ Arguments analysis
  ::at91com::get_switches [list \
    Switches { \
      {-name} { \
        Variable {name} \
        Double   {True} \
        Required {True} \
      } \
      {-group} { \
        Variable {_backward_compatibility_} \
        Double   {True} \
        Required {True} \
      } \
      {-min_rise} { \
        Variable {min_rise} \
        Double   {True} \
        Required {True} \
      } \
      {-max_rise} { \
        Variable {max_rise} \
        Double   {True} \
        Required {True} \
      } \
      {-min_fall} { \
        Variable {min_fall} \
        Double   {True} \
        Required {True} \
      } \
      {-max_fall} { \
        Variable {max_fall} \
        Double   {True} \
        Required {True} \
      } \
    } \
    {Args} {args} \
    Usage [::at91com::get_robodoc_syntax $help] \
    Help  $help \
  ]
  # }}} Arguments analysis


    if [info exists ::at91cts::macromodel_param($name)] {
        error "-E- CTS macromodel param '$name' already created"
    }

    puts "-I- Creating CTS macromodel param '$name'"
    set ::at91cts::macromodel_param($name) [format "%sns %sns %sns %sns" $min_rise $max_rise $min_fall $max_fall ]

    # TODO : store macromodel_param as chip'attribute ?
}

################################################################################ 

proc add_CTS_macromodel { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

  # {{{ Arguments analysis
  ::at91com::get_switches [list \
    Switches { \
      {-spec} { \
        Variable {_backward_compatibility_} \
        Double   {True} \
      } \
      {-group} { \
        Variable {group} \
        Double   {True} \
      } \
      {-dynamic} { \
        Variable {dynamic} \
      } \
      {-ref_pin} { \
        Variable {ref_pin} \
        Double   {True} \
        Required { -dynamic } \
      } \
      {-offset} { \
        Variable {offset} \
        Double   {True} \
      } \
      {-pin} { \
        Variable {pin_list} \
        Double   {True} \
        Required {True} \
      } \
      {-param} { \
        Variable {param_name} \
        Double   {True} \
        RequiredNot { {-dynamic} } \
      } \
    } \
    {Args} {args} \
    Usage [::at91com::get_robodoc_syntax $help] \
    Help  $help \
  ]
  # }}} Arguments analysis


    set pin_list [::at91cts::_sort_get_pins $pin_list]

    if ![info exists group] { set group default }

    if [info exists dynamic] {

        if ![info exists offset] { set offset 0.0 }

        switch -exact [sizeof [get_pins -leaf -quiet $ref_pin]] {
            0       { error "-E- add_CTS_macromodel -ref_pin $ref_pin : no pin found" }
            1       {}
            default { error "-E- add_CTS_macromodel -ref_pin $ref_pin : found several pins ($nref)" }
        }

        set attr [list [get_object_name $ref_pin] $offset]
        foreach_in_collection pin $pin_list { set_user_attribute -quiet $pin cts_dynamic $attr }

    } else {

        set attr $::at91cts::macromodel_param($param_name)
        foreach_in_collection pin $pin_list { set_user_attribute -quiet $pin cts_macromodel $attr }

    }

}

################################################################################ 

proc _trace_CTS_output_pin { pin depth } {

    ## upvar from trace_CTS
    upvar cts_num   cts_num
    upvar cts_stats cts_stats

    set pin  [get_pins -leaf $pin]
    set name [get_object_name $pin]
  
#    puts "   -D- _trace_CTS_output_pin { $name $depth }"

    if { [sizeof_collection $pin] != 1 } {
        error "-E- (internal) _trace_CTS_output_pin <pin> $name : size of <pin> differs from one"
    }
    if { [get_attribute $pin direction] != "out" } {
        error "-E- (internal) _trace_CTS_output_pin <pin> $name : not an output pin"
    }
   #if ![string is digit $depth] {
   #    error "-E- (internal) _trace_CTS_output_pin <depth> $depth : <depth> not a digit"
   #}
  
    ## tag pin

    ::at91cts::_lappend_CTS_attribute $pin cts_traced $cts_num

    ## tag cell for root_pins
    ## useful to detect correctly preserve(in)->root(out) and not flag error

    if { $depth==0 } {
        set cell [get_cells -of $pin]
        set lib_pin [get_attribute $pin lib_pin_name]
        _lappend_CTS_attribute $cell cts_traced [list $cts_num $lib_pin]
    }

    ## detect attributes on pin

    set stop_trace 0

    set pin_cts_num [get_attribute -quiet $pin cts_num]
    if { $depth>0 && $pin_cts_num!="" } { set stop_trace 1 }

    set case_value [get_attribute -quiet $pin case_value]
    if { $case_value != "" } { set stop_trace 1 }

    ## check net

    set net [get_nets -quiet -of $pin]
    if { $net == "" } {
        set stop_trace 1
    } else {
        set load_pins [get_pins -leaf -quiet -of $net -filter {direction=="in"}]
        if { $load_pins == "" } { set stop_trace 1 }
    }

    ## print

    set indent [string repeat "  " $depth]
    set ref    [get_attribute [get_cells -of $pin] ref_name]
    set line   "$indent  *DEPTH $depth: $name  ($ref)"

    if { $pin_cts_num != "" } { append line "  (root)" }
    if { $case_value != "" } { append line "  (case_value)" }
    if { $net == "" || $load_pins == "" } { append line "  (unconnected)" }
    if { $stop_trace } { append line "(stop)" }
  
    puts "-I- $line"
  
    ## stop

    if { $stop_trace } { return }

    ## continue trace -> load_pins

    set load_pins [sort_collection -dictionary $load_pins full_name]
  
#    puts "   -D- _trace_CTS_output_pin -> [sizeof $load_pins]"

    foreach_in_collection load $load_pins { ::at91cts::_trace_CTS_input_pin $load [expr $depth+1] }

}

################################################################################ 

variable report_disable_timing
array set report_disable_timing {
    c  "case-analysis"
    C  "Conditional arc"
    d  "default conditional arc"
    f  "false net-arc"
    l  "loop breaking"
    L  "db inherited loop breaking"
    m  "mode"
    p  "propagated constant"
    u  "user-defined"
    U  "User-defined library arcs"
}

proc _all_cell_output_pins { from_pin trace_arcs } {

    set fanout [all_fanout -flat -from $from_pin -pin_levels 1 -trace_arcs $trace_arcs]
    set fanout [remove_from_collection $fanout $from_pin]
    if { [sizeof $fanout] > 0 } { return $fanout }

    ## fanout empty -> investigate why
    set cell   [get_cells -of $from_pin]
    redirect -variable rpt { report_disable_timing $cell -nosplit }
    set cell_name          [get_object_name $cell]
    set from_pin_name      [get_attribute $from_pin lib_pin_name]
    set disable_l {}
    foreach line [split $rpt "\n"] {
        if { [lindex $line 0] != $cell_name } { continue }
        if { [lindex $line 1] != $from_pin_name } { continue }
       #set out [lindex $line 2]
        set flag [lindex $line 4]
        set long $::at91cts::report_disable_timing($flag)
        set reason [lrange $line 5 end]
        set tmp "$flag $long"
        if { $reason != "" } { append tmp " ($reason)" }
        lappend disable_l $tmp
    }
    set disable_l [lsort -dictionary -unique $disable_l]
    set disable   [join $disable_l]

#    ## re-try 'fanout all'
#    if { $trace_arcs != "all" } {
#        set fanout [all_fanout -flat -from $from_pin -pin_levels 1 -trace_arcs all]
#        set fanout [remove_from_collection $fanout $from_pin]
#    }

    return [list $fanout $disable]
}

################################################################################ 

proc _test_attribute { obj attr {val true} } {
    set test [get_attribute -quiet $obj $attr]
    return [expr {$val == $test}]
}

proc _get_lib_pin_type { pin } {

    if [_test_attribute $pin object_class lib_pin] {
        set lib_pin $pin
    } elseif [_test_attribute $pin object_class pin] {
        set lib_pin  [get_lib_pins -of $pin]
    } else {
        error "-E- (internal) _get_lib_pin_type [get_object_name $pin] : not a pin / lib_pin"
    }

    set lib_cell [get_lib_cells -of $lib_pin]

    if [_test_attribute $lib_cell is_integrated_clock_gating_cell] {
        if [_test_attribute $lib_pin clock] { return "gating" }
        return "data"
    }

    if [_test_attribute $lib_cell is_sequential] {
        if [_test_attribute $lib_pin clock] { return "sync" }
        if [_test_attribute $lib_pin is_async_pin] { return "async" }
        return "data"
    }

    # lib_cell is 'other'
        if [_test_attribute $lib_pin clock] { return "sync" }
        if [_test_attribute $lib_pin is_three_state] { return "data" }
        if [_test_attribute $lib_pin is_three_state_enable_pin] { return "data" }
        return "gating"
}

################################################################################ 

proc _trace_CTS_input_pin { pin depth } {

    ## upvar from trace_CTS
    upvar cts_num   cts_num
    upvar cts_stats cts_stats

    set pin  [get_pins -leaf $pin]
    set name [get_object_name $pin]
  
#    puts "   -D- _trace_CTS_input_pin { $name $depth }"

    if { [sizeof_collection $pin] != 1 } {
        error "-E- (internal) _trace_CTS_input_pin <pin> $name : size of <pin> differs from one"
    }
    if { [get_attribute $pin direction] != "in" } {
        error "-E- (internal) _trace_CTS_input_pin <pin> $name : not an input pin"
    }
   #if ![string is digit $depth] {
   #    error "-E- (internal) _trace_CTS_input_pin <depth> $depth : <depth> not a digit"
   #}
  
    ## tag pin

    ::at91cts::_lappend_CTS_attribute $pin cts_traced $cts_num

    ########################################
    ## detect attributes on pin

    set cts_spec [get_attribute -quiet $pin cts_spec]

    set pin_type $cts_spec
    if { $pin_type=="" } {
        set pin_type [_get_lib_pin_type $pin]
    }
  
    switch -exact $pin_type {
        leaf - macromodel - dynamic - unsync - excluded { set stop_trace 1 }
        through - preserve                              { set stop_trace 0 }
        sync - data - async                             { set stop_trace 1 }
        gating                                          { set stop_trace "?" }
        default {
            error "-E- (internal) _trace_CTS_input_pin <pin> $name : <pin_type> '$pin_type' unknown"
        }
    }

    ## cts_stats

    incr cts_stats($pin_type)

    if { $pin_type=="sync" || $pin_type=="leaf" } {
        if { $depth > $cts_stats(max_depth) } { set cts_stats(max_depth) $depth }
        if { $depth < $cts_stats(min_depth) } { set cts_stats(min_depth) $depth }
    }

    ## if stop : print + return

    set indent [string repeat "  " $depth]
    set line   "$indent  ($pin_type)$name"

    if { $stop_trace == 1 } {
        puts "-I- $line"
        return
    }

    ########################################
    ## not stop : find outputs

    ##     stop_trace==? && case_sensitive -> all_fanout (considers case_analysis for propagation)
    ##     stop_trace==0                   -> all_outputs
    ##     case_sensitive==0               -> all_outputs

    if { $stop_trace=="?" && $::at91cts::cts_options(case_sensitive) } {
        set cell_outputs [_all_cell_output_pins $pin timing]
    } else {
        set cell_outputs [_all_cell_output_pins $pin all]
    }


    ## check unpropagated ?
    ## _all_cell_output_pins returns
    ##    1 pin-collection
    ##  + 1 string in case of error

    if { [llength $cell_outputs] > 1 } {
       #set all_outputs [lindex $cell_outputs 0]
        set disable     [lindex $cell_outputs 1]

        append line "  (unpropagated)(stop)"
        ::at91cts::_lappend_CTS_attribute $pin cts_unpropagated "$cts_num $disable"

        set stop_trace 1
        puts "-W- $line"
        return
    }

    set stop_trace 0  ; # case "?" is now cleared

    ########################################
    ## check loop , intra- or inter-reconvergence ?

    set err [ ::at91cts::_trace_CTS_cell $pin ]

    if { $err != "" } {
        append line "  ($err)"
        switch -exact $err {
            loop                { set stop_trace 1 }
            intra_reconv        { if $::at91cts::cts_options(stop_at_intra_reconv) { set stop_trace 1 } }
            inter_reconv        { if $::at91cts::cts_options(stop_at_inter_reconv) { set stop_trace 1 } }
            preserve_not_traced { if $::at91cts::cts_options(stop_at_preserve_not_traced) { set stop_trace 1 } }
            default             { error "-E- (internal) _trace_CTS_cell returned unknwon error code '$err'" }
        }
        if { $stop_trace } { append line "(stop)" }
    }

    ## print

    if { $err=="" } {
        puts "-I- $line"
    } else {
        puts "-W- $line"
    }

    ## stop

    if { $stop_trace } { return }

    ########################################
    ## continue trace -> cell_outputs

    foreach_in_collection output $cell_outputs { ::at91cts::_trace_CTS_output_pin $output $depth }

}

################################################################################ 

proc _trace_CTS_cell { from_pin } {

    ## upvar from trace_CTS
    upvar cts_num   cts_num

    set cell [get_cells -of $from_pin]
    set name [get_object_name $cell]
    set f_pin [get_attribute $from_pin lib_pin_name]

    if { [sizeof_collection $cell] != 1 } {
        error "-E- (internal) _trace_CTS_cell <cell> $name : size of <cell> differs from one"
    }
    if { [get_attribute $cell is_hierarchical] != "false" } {
        error "-E- (internal) _trace_CTS_cell <cell> $name : not a leaf cell"
    }

    set cts_traced [get_attribute -quiet $cell cts_traced]
    set err ""

    ## check preserve + not traced so far
    set cts_spec [get_attribute -quiet $from_pin cts_spec]
    if { $cts_spec=="preserve" && $cts_traced=="" } { set err "preserve_not_traced" }
    
    ## search previous CTS traces ; reverse to first find intra_reconv
    foreach t_num_pin [lreverse $cts_traced] {
        set t_num [lindex $t_num_pin 0]
        set t_pin [lindex $t_num_pin 1]
        if { $t_num==$cts_num } {
            if { $t_pin==$f_pin } { set err "loop" } else { set err "intra_reconv" }
        } else {
            if { $t_pin!=$f_pin } {
                if { $cts_spec != "preserve" } { set err "inter_reconv" }
            }
        }
        if { $err != "" } { break }
    }

    ## trace through cell
    _lappend_CTS_attribute $cell cts_traced [list $cts_num $f_pin]

    switch -exact $err {
        loop                { _lappend_CTS_attribute $from_pin cts_loop $cts_num }
        intra_reconv        { _lappend_CTS_attribute $from_pin cts_intra_reconv $cts_num }
        inter_reconv        { _lappend_CTS_attribute $from_pin cts_inter_reconv $cts_num }
        preserve_not_traced { _lappend_CTS_attribute $from_pin cts_preserve_not_traced $cts_num }
    }

    return $err
}

################################################################################ 

proc trace_CTS { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

    # {{{ Arguments analysis
    ::at91com::get_switches [list \
      Switches { \
        {-root} { \
          Variable {root_list} \
          Double   {True} \
        } \
        {-case_sensitive} { \
          Variable {case_sensitive} \
        } \
      } \
      {Args} {args} \
      Usage [::at91com::get_robodoc_syntax $help] \
      Help  $help \
    ]
    # }}} Arguments analysis
  
  
    puts "##################################################"
    puts "-I- trace_CTS $args"

    ## check root_pin
  
    if [info exists root_list] {

        set root_pins [get_pins $root_list]

    } else {

        set root_pins [get_pins -hier -filter {defined(cts_num) && undefined(cts_traced)} ]
        set root_pins [sort_collection $root_pins cts_num]

    }

    foreach_in_collection root $root_pins {
        if { [get_attribute $root direction] != "out" } {
            error "-E- trace_CTS -root [get_object_name $root] : not an output pin"
        }
    }

    ## cts_options
  
    if [info exists case_sensitive] { set ::at91cts::cts_options(case_sensitive) 1 } else { set ::at91cts::cts_options(case_sensitive) 0 }

    foreach opt [lsort -dictionary [array names ::at91cts::cts_options]] {
        puts "    . $opt = $::at91cts::cts_options($opt)"
    }


    ## start trace

    foreach_in_collection root $root_pins {

        set cts_num [get_attribute $root cts_num]

        puts "##################################################"
        puts "-I- trace_CTS -root [get_object_name $root] (cts_num = $cts_num)"

        set cts_stats(min_depth) 1000
        set cts_stats(max_depth) 0
        set cts_stats(sync)      0
        set cts_stats(gating)    0
        set cts_stats(data)      0
        foreach cts_spec $::at91cts::cts_spec_valid_values { set cts_stats($cts_spec) 0 }
        
        ::at91cts::_trace_CTS_output_pin $root 0

        set cts_stats(depth) [expr $cts_stats(max_depth) - $cts_stats(min_depth) ]

        set_user_attribute -quiet $root cts_stats [array get cts_stats]

        puts "##################################################"
        puts "-I- statistics for trace_CTS -root [get_object_name $root] (cts_num = $cts_num)"
        puts "-I- sync+leaf depth : min = $cts_stats(min_depth) , max = $cts_stats(max_depth) , real = $cts_stats(depth)"
        foreach stat [concat sync gating data $::at91cts::cts_spec_valid_values] {
            if { $cts_stats($stat) > 0 } { puts "-I- $stat = $cts_stats($stat)" }
        }
    }
  
}


################################################################################ 

proc _map_cts_auto_to_spec { from to } {

    set pin_list [get_pins -quiet -hier -filter defined($from)]
    if { $pin_list == "" } { return }

    set_CTS_pin_attribute -pin $pin_list -type $to
    remove_user_attribute $pin_list $from

}

proc complete_CTS_spec { args } {
## TODO
# no_clock -> root ?
# unpropagated -> unsync
# loop -> exclude
# intra_reconv -> exclude ?
# inter_reconv -> preserve ?
# preserve_not_traced -> ?
    ::at91cts::_map_cts_auto_to_spec  cts_unpropagated  unsync
    ::at91cts::_map_cts_auto_to_spec  cts_loop  excluded
   #::at91cts::_map_cts_auto_to_spec  cts_intra_reconv  excluded
}

################################################################################ 

proc _check_and_print_errors { verbose coll msg {attr ""} } {

    set size [sizeof_collection $coll]
    if { $size==0 } { set type "I" } else { set type "E" }
    puts "-$type- $msg : $size"

    if { ! $verbose } { return }

    # for reconv : print cell'cts_traced
    if { $attr=="cts_intra_reconv" || $attr=="cts_inter_reconv" } {
        set coll [get_cells -of $coll]
        set attr cts_traced
    }

    switch -exact $attr {
        ""      { ::at91cts::_write_collection  stdout  "        %s"  $coll }
        default { ::at91cts::_write_collection  stdout  "        %s    %s"  $coll  $attr }
    }

}

################################################################################ 

proc check_CTS { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

    # {{{ Arguments analysis
    ::at91com::get_switches [list \
      Switches { \
        {-verbose} { \
          Variable {verbose} \
        } \
      } \
      {Args} {args} \
      Usage [::at91com::get_robodoc_syntax $help] \
      Help  $help \
    ]
    # }}} Arguments analysis
  

    puts "##################################################"
    puts "-I- check_CTS $args"

    if [info exists verbose] { set verbose 1 } else { set verbose 0 }


    ## root pins
    set all_root [get_pins -hier -filter defined(cts_num) ]
    puts "-I- 'root' pins : [sizeof $all_root]"
    if { $verbose } {
        set all_root [sort_collection -dictionary $all_root full_name]
        foreach_in_collection root_pin $all_root {
            set cts_num  [get_attribute $root_pin cts_num]
            set cts_tree [get_attribute $root_pin cts_tree]
            puts "        [get_object_name $root_pin]  (cts_num = $cts_num)  { $cts_tree }"
        }
    }

    ## sync (clock) pins
    set all_ck  [all_registers -clock_pins]
    set all_ck  [filter_collection $all_ck {is_async_pin==false && undefined(constant_value)}]
    puts "-I- 'sync' (clock) pins : [sizeof $all_ck]"

    ## check sync pins no traced
    set all_ck_not_cts [filter_collection $all_ck undefined(cts_traced) ]
    #TODO : waive spare ...
    ::at91cts::_check_and_print_errors  $verbose  $all_ck_not_cts  "check 'sync' (clock) pins not traced"

    ## cts_macromodel pins
    set all_cts_macromodel [get_pins -hier -filter defined(cts_macromodel) ]
    puts "-I- cts_macromodel pins : [sizeof $all_cts_macromodel]"
    if { $verbose } {
        ::at91cts::_write_collection  stdout  "        %s"  $all_cts_macromodel
    }

    ## cts_dynamic pins
    set all_cts_dynamic [get_pins -hier -filter defined(cts_dynamic) ]
    puts "-I- cts_dynamic pins : [sizeof $all_cts_dynamic]"
    if { $verbose } {
        ::at91cts::_write_collection  stdout  "        %s"  $all_cts_dynamic
    }

    ## cts_spec pins

    foreach cts_spec $::at91cts::cts_spec_valid_values { set statistics($cts_spec) 0 }
    set all_cts_spec       [get_pins -quiet -hier -filter defined(cts_spec) ]
    set notvalid_cts_spec  {}

    foreach_in_collection pin $all_cts_spec {
        set cts_spec [get_attribute $pin cts_spec]
        if { [lsearch -exact $::at91cts::cts_spec_valid_values $cts_spec] >= 0 } {
            incr statistics($cts_spec) 1
        } else {
            append_to_collection notvalid_cts_spec $pin
        }
    }

    foreach cts_spec $::at91cts::cts_spec_valid_values { puts "-I- cts_spec = '$cts_spec' pins : $statistics($cts_spec)" }

    if { $verbose } {
        ::at91cts::_write_collection  stdout  "        %s    %s"  $all_cts_spec  cts_spec
    }

    ## check cts_spec not valid
    ::at91cts::_check_and_print_errors  $verbose  $notvalid_cts_spec  "check 'cts_spec' not valid"  cts_spec

    ## check cts_data pins
    set all_data  [get_pins -quiet -hier -filter defined(cts_data) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_data  "check 'cts_data' pins"

    ## check unpropagated
    set all_unpropagated [get_pins -quiet -hier -filter defined(cts_unpropagated) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_unpropagated  "check 'cts_unpropagated' pins"  cts_unpropagated

    ## check loop
    set all_loop [get_pins -quiet -hier -filter defined(cts_loop) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_loop  "check 'cts_loop' pins"  cts_loop

    ## check preserve_not_traced
    set all_intra_reconv [get_pins -quiet -hier -filter defined(cts_preserve_not_traced) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_intra_reconv  "check 'cts_preserve_not_traced' pins"  cts_preserve_not_traced

    ## check intra_reconv
    set all_intra_reconv [get_pins -quiet -hier -filter defined(cts_intra_reconv) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_intra_reconv  "check 'cts_intra_reconv' pins"  cts_intra_reconv

    ## check inter_reconv
    set all_inter_reconv [get_pins -quiet -hier -filter defined(cts_inter_reconv) ]
    ::at91cts::_check_and_print_errors  $verbose  $all_inter_reconv  "check 'cts_inter_reconv' pins"  cts_inter_reconv
}
 
################################################################################ 

proc _write_collection { channel template coll {attr ""} } {

    set coll [sort_collection -dictionary $coll full_name]
#    switch -exact $attr {
#        ""            { set coll [sort_collection -dictionary $coll full_name] }
#        default       { set coll [sort_collection -dictionary $coll [concat $attr full_name]] }
#    }

    foreach_in_collection obj $coll {
        switch -exact $attr {
            ""             { set line [format $template [get_object_name $obj] ] }
            cts_dynamic    { set tmp [get_attribute -quiet $obj $attr]
                             set line [format $template [lindex $tmp 0] [get_object_name $obj] [lindex $tmp 1] ] }
            default        { set line [format $template [get_object_name $obj] [get_attribute -quiet $obj $attr] ] }
        }
        puts $channel $line
    }

}

################################################################################ 

proc write_edi_fects { args } {

    set help "
# SYNTAX
# DESCRIPTION
"

    # {{{ Arguments analysis
    ::at91com::get_switches [list \
      Switches { \
        {-output} { \
          Variable {output} \
          Double   {True} \
          Required {True} \
        } \
        {-input} { \
          Variable {input_netlist} \
          Double   {True} \
        } \
      } \
      {Args} {args} \
      Usage [::at91com::get_robodoc_syntax $help] \
      Help  $help \
    ]
    # }}} Arguments analysis


    set cts_file [open $output w]

    puts $cts_file "\n\n# ::at91cts::write_edi_fects -output $output"
    if [info exists input_netlist] {
        puts $cts_file "#                            -input $input_netlist"
    }

    set all_cts_num       [sort_collection [get_pins -quiet -hier -filter defined(cts_num)] cts_num]
    set all_cts_num_group [filter_collection $all_cts_num defined(cts_tree_group)]

    set all_cts_spec       [get_pins -quiet -hier -filter defined(cts_spec)]
    set all_cts_group      [get_pins -quiet -hier -filter defined(cts_group)]
    set all_cts_macromodel [get_pins -quiet -hier -filter defined(cts_macromodel)]
    set all_cts_dynamic    [get_pins -quiet -hier -filter defined(cts_dynamic)]

    puts $cts_file "\n########################################\n"

    set clk_groups [lsort -dictionary -unique [get_attribute -quiet $all_cts_num_group cts_tree_group]]
    foreach group $clk_groups {
        puts $cts_file "\n## ClkGroup $group"
        puts $cts_file "ClkGroup"
        ::at91cts::_write_collection $cts_file "+ %s" [filter_collection $all_cts_num_group cts_tree_group==$group]
    }

    puts $cts_file "\n########################################\n"

    set leafpin_groups [lsort -dictionary -unique [get_attribute -quiet $all_cts_group cts_group]]
    foreach group $leafpin_groups {
        puts $cts_file "\n## LeafPinGroup $group"
        puts $cts_file "LeafPinGroup"
        ::at91cts::_write_collection $cts_file "+ %s" [filter_collection $all_cts_group cts_group==$group]
    }

    puts $cts_file "\n########################################\n"

    ::at91cts::_write_collection $cts_file "MacroModel pin %s %s" $all_cts_macromodel cts_macromodel

    puts $cts_file "\n########################################\n"

    ::at91cts::_write_collection $cts_file "DynamicMacroModel ref %s pin %s offset %s" $all_cts_dynamic cts_dynamic

    puts $cts_file "\n########################################\n"

    foreach { head cts_spec } {
        GlobalLeafPin      leaf
        GlobalExcludedPin  excluded
        GlobalUnsyncPin    unsync
        GlobalThroughPin   through
        GlobalPreservePin  preserve
    } {
        puts $cts_file "\n$head"
        ::at91cts::_write_collection $cts_file "+ %s" [filter_collection $all_cts_spec cts_spec==$cts_spec]
    }

    puts $cts_file "\n########################################\n"

    foreach_in_collection root_pin $all_cts_num {

        set cts_num [get_attribute $root_pin cts_num]

        puts $cts_file "
########################################
# Root [get_object_name $root_pin] cts_num = $cts_num
#   specification : [get_attribute $root_pin cts_tree]
#   statistics    : [get_attribute $root_pin cts_stats]
"

        ::at91cts::_write_collection $cts_file "# %s %s" [filter_collection $all_cts_spec "cts_traced==$cts_num"] cts_spec

        array set tmp [get_attribute -quiet $root_pin cts_tree]
        set name $tmp(tree_param)
        if { $name == 0 } { set name "CTS_default_tree_param" }

        array set tree_param $::at91cts::tree_param($name)

        puts $cts_file "
AutoCTSRootPin [get_object_name $root_pin]
    MaxDelay    $tree_param(max_delay)
    MinDelay    $tree_param(min_delay)
    SinkMaxTran $tree_param(sink_max_transition)
    BufMaxTran  $tree_param(buf_max_transition)
    MaxSkew     $tree_param(max_skew)
    RouteClkNet YES
    PostOpt     YES
    NoGating    NO
    Buffer      $tree_param(buffer)
End
"
    }

    close $cts_file
}

 
################################################################################ 

## TODO or _backward_compatibility_ ?

proc add_CTS_tree_pio { args } {
    puts "
-W- add_CTS_tree_pio : dummy proc
    ( $args )
"
}

################################################################################ 
# end of namespace

}



