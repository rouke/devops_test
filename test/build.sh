#!/bin/bash
#
# Build script for devops-ddy docker setup
# Runs test(s), builds docker image and pushes it to dockerhub
#
# Supposed to run on travis-ci

set -e
i
# Name
name==$2
# If there's a tag, set it, otherwise make the built image sortable with epoch tag
tag=${3-$e_date}

case $1 in
	test*)
	cp -f /tmp/mirror.list /etc/apt/
	/tmp/verify.sh `grep secu /etc/apt-mirror.list|awk '{print $3}'|cut -f1 -d-|uniq` md5 sha1
	if grep -n failed /mnt/mirror/failed.log;then
		echo "Failed checksums :"
		cat /mnt/mirror/failed.log
		exit 1
	fi
	;;
	build*)
	e_date=`date +"%s"`
	docker build ../. ddy -t $tag
	;;
	push*)
	docker push ddy:$tag
	*)
	echo "Usage :\n\ttest : testing the apt-mirror with a replacement .list\n\tbuild : build docker image and push\n"
	exit 0
	;;
esac
