#! /usr/bin/perl

$MAX = 100 ;

%ta = () ;
%tb = () ;
%tc = () ;
%td = () ;

for ($i=-$MAX;$i<$MAX;$i++)
{
    for ($j=-$MAX;$j<$MAX;$j++)
    {
        $a = $i+$j ; $ta{$ii,$jj} = $a ;
        $b = $i-$j ; $tb{$ii,$jj} = $b ;
        $c = $i*$j ; $tc{$ii,$jj} = $c ;
        if ($j!=0) { $d = $i/ $j }
        else       { $d = 123.789 }
        $td{$ii,$jj} = $d ;
        printf( "%d %d : %d %d %d %.1f\n" , $i,$j,$a,$b,$c,$d ) ;
    }
}

