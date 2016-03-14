# Comment
FROM ubuntu:trusty

# Maintainer
MAINTAINER rdejong

# Prep atp-mirror env
# First we surpress the debconf errors
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Makes default installation paths work without additional editing
RUN mkdir -p /var/spool/apt-mirror/
RUN mkdir -p /mnt/mirror
RUN ln -s /mnt/mirror /var/spool/apt-mirror/

# Build apt-cache
RUN apt-get update -qq

# Install apt-mirror
RUN apt-get install -qq -y apt-mirror

# Install lighttpd for serving the packages
# Lighttpd has rate limiting capabilities, we're using them to restrict 
RUN apt-get install -qq -y lighttpd

# Enabling evasive mod we're using to throttle client access
RUN lighttpd-enable-mod evasive

# Add mod_evasive to the config
RUN echo "evasive.max-conns-per-ip = 10" >> /etc/lighttpd/lighttpd.conf

# Enable global dir listing for lighty
RUN echo "dir-listing.activate = \"enable\"" >> /etc/lighttpd/lighttpd.conf

# Debug option
RUN echo "debug.log-request-handling = \"enable\"" >> /etc/lighttpd/lighttpd.conf

# Now we add the RFC1918 ranges to the whitelisting in lighttpd
# 172.16.0.0/20, 192.168.0.0/16, 10.0.0.0/24 ranges
RUN echo "\$HTTP[\"remoteip\"] != \"192.168.0.0/16\" {\n" >> /etc/lighttpd/lighttpd.conf
RUN echo "\$HTTP[\"remoteip\"] != \"172.16.0.0/12\" {\n" >> /etc/lighttpd/lighttpd.conf
RUN echo "\$HTTP[\"remoteip\"] != \"10.0.0.0/24\" {\n" >> /etc/lighttpd/lighttpd.conf
RUN echo "\turl.access-deny = ( \"\" )\n"
RUN echo "}\n}\n}\n" >> /etc/lighttpd/lighttpd.conf

# Exposing the mirror repo to lighttpd
RUN ln -s /mnt/mirror /var/www/

# In place replacement of the source hostnames
RUN sed -i 's/deb\ \(http.*\)\ \(.*\n\)/deb\ http\:\/\/nl\.archive\.ubuntu\.com\/ubuntu\ \2/g' /etc/apt/mirror.list

# Adding test file(s)
ADD test/* /tmp/

# Adding stratup script
ADD start.sh /tmp/

# Add updating the mirror repo to crontab, it runs everynight at 01.05
RUN (crontab -l; echo '5 1 * * * apt-mirror	/usr/bin/apt-mirror > /var/spool/apt-mirror/var/cron.log && for file in `find /mnt/mirror -name Release`;do sh /tmp/verify.sh $file md5 sha1;done')|crontab -
