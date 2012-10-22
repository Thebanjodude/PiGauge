#!/bin/bash

ROOT_UID=0

#check to see if we are running as root
if [ `id -u` != $ROOT_UID ]
then
	echo "Please run as root or sudo $0"
else
	chown `whoami`:www-data -R *
fi

chmod 644 index.php
chmod 644 MoveServos.py
chmod 600 README.md
chmod 700 run_tests.sh
chmod 700 fix_perms.sh
find test_cases/ -type d -exec chmod 700 {} \;
find test_cases/ -type f -exec chmod 600 {} \;

