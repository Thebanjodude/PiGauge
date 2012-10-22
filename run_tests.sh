#!/bin/bash

# a script to run test cases against PiGauge
# tests should be stored in the $TEST_CASE_DIR
#   tests should end with $TEST_SUFFIX
#   expected results should end with $OUT_SUFFIX
#
# running with --output will create output files for
# tests that do not have them

# cleanup on a CTRL-C
trap clean_exit SIGINT

PYTHON_SCRIPT="MoveServos.py"
PHP_SCRIPT="index.php"
TEST_CASE_DIR="./test_cases"

TEST_SUFFIX="test"
OUT_SUFFIX="output"

EXIT_CODE=0
EXIT_CODE_TEST_FAILURE=1
EXIT_CODE_BAD_SETUP=2
EXIT_CODE_SOMETHINGS_GONE_WRONG=3

# generate color pass/fail messages
PASS=`tput setaf 2; echo -n "***"; tput smso; echo -n " PASS "; tput rmso; echo -n "***"; tput op`
FAIL=`tput setaf 1; echo -n "***"; tput smso; echo -n " FAIL "; tput rmso; echo -n "***"; tput op`
UNDERLINE_ON=`tput smul`
UNDERLINE_OFF=`tput rmul`

IFS=''

clean_exit()
{ 	
	exit $EXIT_CODE
}


create_output_files()
{
	echo "Checking for the existance of output files"
	for TEST_CASE in ${TEST_CASE_DIR}/*$TEST_SUFFIX
	do
		TEST=`echo $TEST_CASE | sed s/\.$TEST_SUFFIX$//`
		OUTPUT=$TEST.output
		echo -n "For test - $TEST:  "
		if [ ! -e $OUTPUT ]
		then
			echo "Missing  -  generating output file for $TEST"
			. $TEST_CASE > $OUTPUT
		else
			echo "Present"
		fi
	done
}


run_test()
{	# run tests
	NUM_TEST=0
	NUM_TEST_PASSED=0
	for TEST_CASE in ${TEST_CASE_DIR}/*$TEST_SUFFIX
	do
		NUM_TEST=$(( NUM_TEST + 1))
		TEST=`echo $TEST_CASE | sed s/\.$TEST_SUFFIX$//`
		OUTPUT=$TEST.output

		if [ ! -e $OUTPUT ]
		then #no output file to check against
			echo "$FAIL--- no output file for $TEST --- Unable to run test!"
			continue
		fi

		echo -en "   Running  - Test: $TEST\r"
		
		#run the test and save the results for comparison
		RESULTS=$(. $TEST_CASE)
		
		#check the actual results against the expected results
		if [ `echo $RESULTS | diff $OUTPUT - >/dev/null ; echo $?` -gt 0 ]
		then #test failure
			EXIT_CODE=$EXIT_CODE_TEST_FAILURE
			echo $FAIL
			printf "%sExpected Results% 23s Actual Results% 23s%s \n" "$UNDERLINE_ON" "|" "" "$UNDERLINE_OFF"
			echo $RESULTS | diff --side-by-side --width=80  $OUTPUT - 
		else #test passed
			echo $PASS
			NUM_TEST_PASSED=$(( NUM_TEST_PASSED + 1 ))
		fi
	done
	printf "%s tests out of %s tests passed, %s tests failed\n" "$NUM_TEST_PASSED" "$NUM_TEST" "$((NUM_TEST - NUM_TEST_PASSED))"
}

# Ensure that we are ready to run the script
if [ ! -d "$TEST_CASE_DIR" ] ||  
	[ ! "`ls $TEST_CASE_DIR/*.$TEST_SUFFIX >/dev/null 2>&1; echo $?`" == "0" ] || 
	[ ! -e "$PHP_SCRIPT" ] || 
	[ ! -x "$PYTHON_SCRIPT" ]
then
	echo "Please run from the directory where PiGauge files are located and "
	echo "put the test files into the $TEST_CASE_DIR directory"
	echo "Test files should be named name_of_test.$TEST_SUFFIX"
	EXIT_CODE=$EXIT_CODE_BAD_SETUP
	clean_exit
fi

if [ "$1" = "--outputs" ]
then
	create_output_files
	clean_exit
fi

# We are ready... so do it.
run_test
clean_exit

#### We should never get this far into the script ####
exit $EXIT_CODE_SOMETHINGS_GONE_WRONG

############## NOTES #################################
# php testing
wget localhost/PiGauge/index.php --output-document - --quiet  --post-data "text=$1" | php -R 'echo strip_tags($argn)."\n";'
