#!/bin/bash
# *****************************************************************
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# *****************************************************************

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
   fi
done

