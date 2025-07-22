#!/bin/bash
if [ -f /var/run/reboot-required ]; then
	echo "restart needed!"
fi
msg=$(needrestart -k -q -p)
code=$?
if [ $code -eq 2 ] || [ $code -eq 1 ]; then
	echo "restart needed!"
fi
