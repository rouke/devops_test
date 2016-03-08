#!/bin/bash
#
# Start wrapper to be called at container initialization
/usr/bin/apt-mirror > /var/spool/apt-mirror/var/cron.log && for file in `find /mnt/mirror -name Release`;do sh /tmp/verify.sh $file md5 sha1;done && /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
