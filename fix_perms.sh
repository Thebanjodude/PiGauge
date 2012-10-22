#!/bin/bash

chmod 644 index.php
chmod 644 MoveServos.py
chmod 600 README.md
chmod 700 run_tests.sh
find test_cases/ -type d -exec chmod 700 {} \;
find test_cases/ -type f -exec chmod 600 {} \;

