#! /usr/bin/perl

## how to get/redirect time's output ?
## time prints to stderr
## redirect it 2> txt file ...

sub time_run
{
    $cmd = shift ;
    `sh -c "time ./$cmd > $cmd.out" 2> time.txt` ;
    $out = `cat time.txt` ;
    ($time) = ($out =~ /(\d+\.\d+)user/ );
    ($cpu) = ($out =~ /(\d+)\%CPU/ );
    ($mem) = ($out =~ /(\d+)maxresident/ );
    print " $time $cpu $mem ," ;
}

print "C , C dbg , C prof\n" ;
for ($i=1;$i<=10;$i++)
{
    time_run( "test_arith" );
    time_run( "test_arith_g" );
    time_run( "test_arith_pg" );
    print "\n" ;
}

print "C , py list , py dict , pl list , pl hash\n" ;
for ($i=1;$i<=10;$i++)
{
    time_run( "test_arith" );
    time_run( "test_arith_list.py" );
    time_run( "test_arith_dict.py" );
    time_run( "test_arith_list.pl" );
    time_run( "test_arith_hash.pl" );
    print "\n" ;
}

