#!/bin/bash 
# 
# 
# find ./ -name '*.v' -print0 |xargs -0 echo
# cdir=`find ./ | egrep "*\.?v$"`
# echo $cdir
# find ./ | grep "\.v$"
# files=$(find ./ | egrep "*\.?v$")
# echo $files

files1=$(find .. -name "*.v")
files2=$(find .. -name "*.sv")


# cat $files > files.svv
cat $files1 $files2 | gen_hielist.py > hielist.json

# cat $files | gen_hierarchy.py > hie.json

# for filename in `find ./ | egrep "*\.v$"`
# do
# 	# echo $filename
# 	cat $filename | gen_hierarchy.py
# done

