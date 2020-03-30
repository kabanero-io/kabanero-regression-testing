#!/bin/bash

MAIN_DIR=`dirname $0`
cd "${MAIN_DIR}"
MAIN_DIR=`pwd`

if ! oc whoami; then
    echo "Must login using oc before running"
    exit 1
fi

# Time to run tests now
cd ${MAIN_DIR}/tests

let anyfail=0
failed=""

# loop on all directories
for testcase in `ls -d *`; do
   if [ -d "$testcase" ] ; then
     echo "*** Running testcase $testcase"
     cd $testcase
     if [ -f test.sh ]; then
       ./test.sh
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
       fi
       # do something to publish test results
     elif [ -f test.yaml ]; then
       ansible-playbook test.yaml
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
       fi
       # do something to publish test results
     else
       echo "*** No test found in $testcase"
     fi
   fi
done

# Summarize results
if [ $anyfail -eq 0 ]; then
   echo "*** All testcases ran without error"
else
   echo "*** There were $anyfail testcase failures - $failed"
fi 

exit $anyfail
