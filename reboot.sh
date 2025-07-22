#!/bin/bash
if [ -f /var/run/reboot-required ]; then
	sudo /usr/sbin/shutdown -r now
fi
msg=$(needrestart -k -q -p)
code=$?
if [ $code -eq 2 ] || [ $code -eq 1 ]; then
	sudo /usr/sbin/shutdown -r now
fi
