#!/bin/bash
#
# Script to verify the integrity of the apt-mirror
# Run this after the apt-mirror cronjob

# First arg is the Release file to check
rel_file=$1
root_path=`dirname $rel_file`

# Where to start and end parsing the Release file, based on hashing method
begin_str=`echo $2|tr [:lower:] [:upper:]`
end_str=`echo $3|tr [:lower:] [:upper:]`

# Debug info
echo -e "Input vars :\n\trel_file = $rel_file\n\tbegin_str = $begin_str\n\tend_str = $end_str\n"

# Input sanity checking: is the begin_str earlier in the file than end_str
if [ -e $rel_file ] && [ -n $begin_str ] && [ -n $end_str ]; then
	if [ `grep -n $begin_str $rel_file|cut -f1 -d:` -gt `grep -n $end_str $rel_file|cut -f1 -d:` ]; then
        	echo "Wrongly defined begin and end strings, exiting.."
        	exit 1
	fi
fi

# Hasing method based on begin_str
sum_meth=`echo $begin_str|tr [:upper:] [:lower:]`sum

# Setup diag files
echo `date` >> /mnt/mirror/failed.log
echo `date` >> /mnt/mirror/success.log

# Loop:
# 	We tail the Release file, skippping the first few lines until the begin string is encountered.
#	Adding one to skip the begin string too
# 	Grep-ing arch specific entries only, otherwise we'll be missing files erronously
tail -n+$(expr `grep -n "$begin_str" $rel_file|cut -f1 -d:` + 1) $rel_file \
	|while read line
	do 
	if [ `echo $line|grep $end_str` ]; then
		echo "End string reached, exiting.."
		exit 0
	fi
#	echo "Line is $line"
	checksum=`echo $line|awk '{print $1}'`
	file="$root_path/"`echo $line|awk '{print $3}'`
	if [ -e $file ]; then
		if [ "$checksum" = `eval $sum_meth $file|awk '{print $1}'` ]; then
			echo "File $file is OK"
			echo $file >> /mnt/mirror/success.log
		else
			echo "File $file checksum failed!"
			echo $file >> /mnt/mirror/failed.log
		fi
	else
		echo "File $file is missing, skipping"
	fi
	done
