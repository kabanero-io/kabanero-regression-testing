#!/bin/bash

if ! oc whoami; then
    echo "Must login using oc before running"
    exit 1
fi

# Time to run tests now
scriptHome=$(dirname $(readlink -f $0))
level=$(date "+%Y-%m-%d_%H%M%S")
buildPath=$scriptHome/build_${level}
cd $scriptHome/tests
mkdir -p $buildPath
ln -fsvn $buildPath $scriptHome/build

let anyfail=0
failed=""


# find any bucket.yml and run them to load outside test repos
testDirs=()
bucketTests=()
buckets=$(find . -name "bucket.y*ml" -type f | sort)
for bucket in $( echo "$buckets") ; do
   bucketName=$(basename $(dirname $bucket))
   bucketHome=$(dirname $bucket)
   outputPath=$buildPath/$bucketName/output
   mkdir -p $outputPath
   gitRepo=$(cat $bucket | grep -i git_repo: | awk '{print $2}')
   testDir=$(cat $bucket | grep -i test_dir: | awk '{print $2}')
   cd $bucketName
   git init .
   git remote add origin $gitRepo
   git pull origin master
   cd ..
   dir=$(find ./$bucketName -name "$testDir" -type d)
   testDirs+=$dir" "
   bucketTests+=$(ls -rtd $dir/*)" "
done


# find any .sh|test.yaml|test.yml
regressionTestScripts=$(find . -name [0-9]* -type f |egrep '*.sh|*.yml|*.yaml'| sort)
#remove duplicates that may have been picked up
allTests=$(echo $bucketTests" "$regressionTestScripts  | tr ' ' '\n' | sort -u)
for testcase in $( echo "$allTests") ; do
   if [ -f "$testcase" ] ; then
     testsuiteName=$(basename $(dirname $testcase))
     testcaseScript=$(basename "$testcase")
     testcaseName=${testcaseScript%.*}
     testcasePath=$buildPath/$testsuiteName/$testcaseName
     outputPath=$testcasePath/output
     resultsPath=$testcasePath/results
     mkdir -p $outputPath
     mkdir -p $resultsPath
     echo "*** Running testcase $testcase"
     cd $(dirname "$testcase") 
     
     if [[ $testcase == *.sh ]] ; then
       bash ./$testcaseScript > >(tee -a $resultsPath/${testcaseScript}.stdout.txt) 2> >(tee -a $resultsPath/${testcaseScript}.stderr.txt >&2)
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
         touch $testcasePath/FAILED.TXT
       else
         touch $testcasePath/PASSED.TXT
       fi

     fi
     if [[ $testcase == *.yaml ]] || [[ $testcase == *.yml ]] ; then
       ansible-playbook $testcaseScript  > >(tee -a $resultsPath/${testcaseScript}.stdout.txt) 2> >(tee -a $resultsPath/${testcaseScript}.stderr.txt >&2)
       if [ $? -ne 0 ]; then
         let anyfail+=1
         failed="$failed $testcase"
         touch $testcasePath/FAILED.TXT
       else
         touch $testcasePath/PASSED.TXT
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
cd $buildPath
$scriptHome/scripts/kabanero-mustgather.sh

exit $anyfail
