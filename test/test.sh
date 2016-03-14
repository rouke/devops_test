#!/bin/bash
#
# Build script for devops-ddy docker setup
# Runs test(s), builds docker image and pushes it to dockerhub
#
# Supposed to run on travis-ci

set -e

# Name
name=$2

# If there's a tag, set it, otherwise make the built image sortable with epoch tag
tag=${3-$e_date}

# case $1 in
#	test*)
	if [ -e /tmp/mirror.list ];then
	cp -f /tmp/mirror.list /etc/apt/
		apt-mirror
		/tmp/verify.sh /mnt/mirror/archive.ubuntu.com/ubuntu/dists/`grep secu /etc/apt/mirror.list|awk '{print $3}'|cut -f1 -d-|uniq`-backports/Release md5 sha1
		if grep -n failed /mnt/mirror/failed.log;then
			echo "Failed checksums :"
			cat /mnt/mirror/failed.log
			exit 1
		else
			echo "Success!"
		fi
	else
		echo "No mirror.list available, are we in the container?"
		exit 1
	fi
#	;;
#	*)
#	echo -e "Usage :\n\ttest : testing the apt-mirror with a replacement .list by building the container and running the verify step with a scaled down ubuntu repo.\n\t\tVerify.sh checks the integrity of the create repo by comparing hashes as specced in the Release file.\n\t\tThis test run takes about 1.4GB."
#	exit 0
#	;;
#esac
