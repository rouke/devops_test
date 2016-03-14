#!/bin/bash
#
# Build script for devops-ddy docker setup
# Runs test(s), builds docker image and pushes it to dockerhub
#
# Supposed to run on travis-ci

set -e

# Name
def_name=devops-ddy
name=${2-$def_name}

# If there's a tag, set it, otherwise make the built image sortable with epoch tag
tag=${3-$e_date}

case $1 in
	build*)
	e_date=`date +"%s"`
	docker build -t $name:$tag .
	;;
	push*)
	docker tag $name:$tag rdejong/devops-ddy
	docker push rdejong/$name:$tag
	;;
	test*)
	docker run --rm $name:$tag "/tmp/test.sh"
	if [ `echo $?` -eq 0 ];then
		echo "Test run success"
	else
		echo "Failed"
		exit 1
	fi
	;;
	all*)
	sh $0 build && sh $0 test && sh $0 push
	;;
	*)
	echo -e "Usage :\n\tbuild : build docker image\n\tpush : push built image to dockerhub repo\n\ttest : run the created image with the testing script\n\tall : first build, test, then push\n\tArgs available : <build,push,test,all> <name (defaults to ddy)> <tag (defaults to epoch)>"
	exit 0
	;;
esac
