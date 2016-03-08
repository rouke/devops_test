# devops_test

Example setup dockerizing apt-mirror.

Assumptions :
* /mnt/mirror is provisioned by the orchestrator
* /mnt/mirror has enough space

Access to the repo is limited as  per spec to RFC1918 subnets.

Used components :
 * dockerhub ubuntu:trusty image
 * apt-mirror
 * lighttpd
 * http://nl.archive.ubuntu.com/ubuntu (trusty flavour) as source repo
 * test/verify.sh is run after the apt-mirror cron job ends successfully, doing :
  - per Release file parse the list between begin and end strings (hashing methods)
  - use the list to check if the specced file is there and verify its hash
  - verification output is posted in the webserver root
  - Additional actions can be added to the test/verify.sh script, i.e. removal of mismatching packages
