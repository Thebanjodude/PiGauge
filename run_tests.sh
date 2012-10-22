#!/bin/bash

# a script to run test cases against PiGauge
# tests should be stored in the $TEST_CASE_DIR
#   tests should end with $TEST_SUFFIX
#   expected results should end with $OUT_SUFFIX

# cleanup on a CTRL-C
trap clean_exit SIGINT

PYTHON_SCRIPT="MoveServos.py"
PHP_SCRIPT="index.php"
TEST_CASE_DIR="./test_cases"
TEST_TEMP_DIR="/dev/shm/PiGauge"

TEST_SUFFIX="test"
OUT_SUFFIX="output"

TEST_PIPE="$TEST_TEMP_DIR/testpipe.$$"
OUT_PIPE="$TEST_TEMP_DIR/outpipe.$$"
DIFF_PIPE="$TEST_TEMP_DIR/diffpipe.$$"

EXIT_CODE=0
EXIT_CODE_TEST_FAILURE=1
EXIT_CODE_BAD_SETUP=2
EXIT_CODE_SOMETHINGS_GONE_WRONG=3

OLD_IFS="$IFS"
IFS="\n"

#RESULTS=""

# generate color pass/fail messages
PASS=`tput setaf 2; echo -n "***"; tput smso; echo -n " PASS "; tput rmso; echo -n "***"; tput op`
FAIL=`tput setaf 1; echo -n "***"; tput smso; echo -n " FAIL "; tput rmso; echo -n "***"; tput op`
UNDERLINE_ON=`tput smul`
UNDERLINE_OFF=`tput rmul`


clean_exit()
{ 	# remove pipes and tmp files
	rm -rf $TEST_TEMP_DIR
	exit $EXIT_CODE
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
		echo -en " Running    - Test: $TEST\r"
		
		#setup to capture the test results
		#tee -a $DIFF_PIPE < $OUT_PIPE > $TEST_PIPE &
		
		#run the test and save the results for comparison
		#source $TEST_CASE 2>&1 | tee $OUT_PIPE > $TEST_PIPE &
		#source $TEST_CASE 2>&1 > $OUT_PIPE &
		#blah=$(source $TEST_CASE 2>&1)
		#blah=`source $TEST_CASE 2>&1`
		#blah=$(. $TEST_CASE)
		RESULTS=$(. $TEST_CASE)
		
		#check the actual results against the expected results
		#if [ `diff $OUTPUT $DIFF_PIPE ; echo $?` -gt 0 ]
		#if [ `diff $OUTPUT $DIFF_PIPE >/dev/null 2>&1; echo $?` -gt 0 ]
		#if [ `diff $OUTPUT $OUT_PIPE >/dev/null 2>&1; echo $?` -gt 0 ]
		#if [ `diff $OUTPUT $OUT_PIPE >/dev/null ; echo $?` -gt 0 ]
		#if [ `echo $blah | diff $OUTPUT - >/dev/null ; echo $?` -gt 0 ]
		#if [ `echo $blah | diff $OUTPUT - >/dev/null ; echo $?` -gt 0 ]
		if [ `echo $RESULTS | diff $OUTPUT - >/dev/null ; echo $?` -gt 0 ]
		#if [[ `. $TEST_CASE | diff --side-by-side --width=80 $OUTPUT - ` ]]
		then #test failure
			EXIT_CODE=$EXIT_CODE_TEST_FAILURE
			echo $FAIL
			printf "%sExpected Results% 23s Actual Results% 23s%s \n" "$UNDERLINE_ON" "|" "" "$UNDERLINE_OFF"
			echo $RESULTS | diff --side-by-side --width=80  $OUTPUT - 
			#echo -e "\n"
		else #test passed
			echo $PASS
			# flush test pipe so it is ready for next test
			#cat $TEST_PIPE >/dev/null
			NUM_TEST_PASSED=$(( NUM_TEST_PASSED + 1 ))
		fi
	done
	printf "%s tests out of %s tests passed, %s tests failed\n" "$NUM_TEST_PASSED" "$NUM_TEST" "$((NUM_TEST - NUM_TEST_PASSED))"
	if [ ! $NUM_TEST_PASSED -eq $NUM_TEST ]
	then
		echo "***WARNING*** Test failures have occured!"
	fi
}

setup()
{	# create file structure and test files
	mkdir -p $TEST_TEMP_DIR
	mkfifo $OUT_PIPE
	mkfifo $TEST_PIPE
	mkfifo $DIFF_PIPE
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

# We are ready... so do it.
setup
run_test
clean_exit

#### We should never get this far into the script ####
exit $EXIT_CODE_SOMETHINGS_GONE_WRONG

############## NOTES #################################
# php testing
wget localhost/PiGauge/index.php --output-document - --quiet  --post-data "text=$1" | php -R 'echo strip_tags($argn)."\n";'
