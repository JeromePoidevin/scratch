#! /bin/bash

dir=`dirname $0`

lef+=" -lef ../../../lib/import/PROJECTDHD/lef/ascdhd.lef"
lef+=" -lef ../../../lib/import/DPRAM_1Kx32cm4bw/lef/DPRAM_1Kx32cm4bw.lef"
lef+=" -lef ../../../lib/import/DPRAM_256x32cm4bw/lef/DPRAM_256x32cm4bw.lef"
lef+=" -lef ../../../lib/import/SRAM_1Kx32cm4bw/lef/SRAM_1Kx32cm4bw.lef"
lef+=" -lef ../../../lib/import/SRAM_2Kx32cm8bw/lef/SRAM_2Kx32cm8bw.lef"
lef+=" -lef ../../../lib/import/SRAM_6Kx32cm16bw/lef/SRAM_6Kx32cm16bw.lef"
lef+=" -lef ../../../lib/import/SRAM_8Kx32cm16bw/lef/SRAM_8Kx32cm16bw.lef"

#echo "script dir = " $dir
#echo "lef = " $lef
#echo "argv = " $*

python $dir/def_viewer.py -window 1000x1000 -color $dir/def_viewer.color $lef $*


exit


## usage examples :

../ultra/def_viewer.sh -def OUTPUT/chip_prects_leak_route_opt.def.gz

