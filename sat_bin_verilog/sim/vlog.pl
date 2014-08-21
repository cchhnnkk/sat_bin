#!/usr/bin/perl
# $vinfo = `vlog ../src/sat_engine/lit1.v`;
# print $vinfo;
# $vinfo = `vlog ../src/sat_engine/lits.v`;
# print $vinfo;

# # chomp($line = <STDIN>);
# while (<>) {
# 	chomp;
# 	$filename = $_;
# 	print $filename;
# 	my @array = stat("mysql.tar.gz"); 
#    	print "$array[9]\n";	# 修改时间
# }

foreach $filename (@ARGV) {
	print "$filename\n";
	my @array = stat($filename); 
   	# print "$array[9]\n";	# 修改时间
   	$mtime = $array[9];
   	
}