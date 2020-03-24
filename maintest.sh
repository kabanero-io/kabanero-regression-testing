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

MAIN_DIR=`dirname $0`
cd "${MAIN_DIR}"
MAIN_DIR=`pwd`

if ! oc whoami; then
    echo "Must login using oc before running"
    exit 1
fi

# Time to run tests now
cd ${MAIN_DIR}/tests

# loop on all directories
for testcase in `ls -d *`; do
   echo "Running testcase $testcase"
   cd $testcase
   if [ -f test.sh ]; then
     ./test.sh
     # do something to publish test results
   elif [ -f test.yaml ]; then
     ansible-playbook test.yaml
     # do something to publish test results
   else
     echo "No test found in $testcase"
   fi
done
