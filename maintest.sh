#!/bin/bash

if ! oc whoami; then
    echo "Must login using oc before running"
    exit 1
fi

# Time to run tests now
cd $(dirname $(readlink -f $0))/tests

let anyfail=0
failed=""

# find any .sh|test.yaml|test.yml
regressionTestScripts=$(find . -name [0-9]* -type f |egrep '*.sh|*.yml|*.yaml'| sort)
for testcase in $( echo "$regressionTestScripts") ; do
   if [ -f "$testcase" ] ; then
     echo "*** Running testcase $testcase"
     cd $(dirname "$testcase")
     if [[ $testcase == *.sh ]] ; then
       ./$(basename "$testcase")
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
       fi
     fi
     if [[ $testcase == *.yaml ]] || [[ $testcase == *.yml ]] ; then
       ansible-playbook $(basename "$testcase")
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
       fi
     fi
     cd -
   else
     echo "*** No test found in $testcase"
   fi
done

# Summarize results
if [ $anyfail -eq 0 ] ; then
   echo "*** All testcases ran without error"
else
   echo "*** There were $anyfail testcase failures - $failed"
fi 

# get the logs
cd $(dirname $(readlink -f $0))
scripts/kabanero-mustgather.sh

exit $anyfail
