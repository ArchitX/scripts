#!/bin/sh
rm -rf /tmp/shallalist.tar.gz
wget --no-proxy -P /tmp http://www.shallalist.de/Downloads/shallalist.tar.gz
rm -rf /var/squidGuard/blacklists
tar -xzvf /tmp/shallalist.tar.gz -C /var/squidGuard
mv /var/squidGuard/BL /var/squidGuard/blacklists
squidGuard -b -d -C all
chown -Rv squid:squid /var/squidGuard/blacklists
service squid restart  

