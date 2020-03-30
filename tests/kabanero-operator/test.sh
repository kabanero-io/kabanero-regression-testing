#!/bin/bash

let anyfail=0
failed=""

# loop on all files, with exceptions
for test in `ls -f *`; do
   if [ "$test" == "test.sh" ]; then
     # skip
     echo "*** Skipping $test"
   elif [ "$test" == "pipelinerun.sh" ]; then
     # skip
     echo "*** Skipping $test"
   elif [ "$test" == "rstr.sh" ]; then
     # skip
     echo "*** Skipping $test"
   elif [ -x "$test" ]; then 
     echo "*** Running test $test"
     ./$test
     if [ $? -ne 0 ]; then
       let anyfail+=1
       failed="$failed $test"
     fi
     sleep 300
   fi
done

# Summarize results
if [ $anyfail -eq 0 ]; then
   echo "*** All tests ran without error"
else
   echo "*** There were $anyfail test failures - $failed"
fi 

exit $anyfail
