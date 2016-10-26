
namespace eval timer {

    variable ref
    set ref(t0)  [clock seconds]
    set ref(ela) 0
    set ref(cpu) [cputime]
    set ref(mem) [mem]

    proc delta {key new} {
        variable ref
        switch -exact $key {
            ela { set new [expr $new - $ref(t0)] }
        }
        set last       $ref($key)
        set ref($key)  $new
        set delta      [expr $new - $last]
       #puts "$key : $new - $last = $delta"
        switch -exact $key {
            ela - cpu  { return "[fmt_time $new] ( + [fmt_time $delta] )" }
            mem        { return "[fmt_mem  $new] ( + [fmt_mem  $delta] )" }
        }
    }

    proc fmt_time {sec} {
        set s   [expr $sec % 60]
        set min [expr $sec / 60]
        set m   [expr $min % 60]
        set h   [expr $min / 60]
        return  [format "%d:%02d:%02d" $h $m $s]
    }

    proc fmt_mem {kb} {
        set mb [expr $kb / 1024]
        return [format "%.0f" $mb]
    }

    proc print { {msg ""} } {
        set ela [delta ela [clock seconds]]
        set cpu [delta cpu [cputime]]
        set mem [delta mem [mem]]
        puts "::timer::print ($msg) : elapse = $ela , cputime = $cpu , memory = $mem MB"
    }

} ; # end namespace


