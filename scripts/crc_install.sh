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

cd ~
rm -rf icpa-system-test

#Download the github repo
git clone git@github.ibm.com:IBMCloudPak4Apps/icpa-system-test.git
cd icpa-system-test

cd automation/ansible-playbooks
SVT_DIR=`dirname $0`
cd "${SVT_DIR}"
SVT_DIR=`pwd`

rm ~/ansible.cfg
cp /usr/bin/jq jq.linux64
ln -s ${SVT_DIR}/ansible.cfg ~/ansible.cfg
./oneTimeSetup.sh

# Setup the machine... ignore errors
sudo mkdir /etc/ansible/svtinfo
cd /etc/ansible/svtinfo
sudo rm fyreurls.yml
sudo rm svtvars.yml
sudo ln -s ${SVT_DIR}/fyreurls.yml fyreurls.yml
sudo ln -s ${SVT_DIR}/svtvars.yml svtvars.yml

cd ${SVT_DIR}
sed -i 's/gather_facts: false/gather_facts: true/g' crc_kabanero.yml
sed -i 's/deleteFyrevm.true/deleteFyrevm.false/g' svtinfo.sh

# Run the install
. ./svtinfo.sh
kabaneroRelease=0.5.0
mkdir ~/stdoutLogs

verifySleep='10' # 10 minutes to let pods / containers start
logDir="~/kabanero-crc-logs"
mkdir $logDir
appName="${0##*/}" 
testLogFile="$logDir/$appName.`date +%F-%T`.test.log"
setupLogFile="$logDir/$appName.`date +%F-%T`.setup.log"
kabaneroLogFile="$logDir/$appName.`date +%F-%T`.kabanero.log"
verifyLogFile="$logDir/$appName.`date +%F-%T`.verify.log"
playRecapLogFile="$logDir/$appName.`date +%F-%T`.playRecap.log"

# if False, leave vm enabled
runFakeTest="${runFakeTest:-False}"
runFakeFailTest="${runFakeFailTest:-False}"

control_c()
{
  rm -f .kabanero-svt.running > /dev/null
  rm -f .crctest.complete > /dev/null
  rm -f .kabanero-install.complete > /dev/null
  rm -f .kabanero-svt.published > /dev/null
  echo "Script completed - exiting"
  echo "INFO: $0 ran for $((SECONDS/60)) minutes"
  exit
}

publish_logs()
{
 # temp workaround for running publish 2x when test error - not sure why the exit is not working from within function
 [ -f .kabanero-svt.published ] && return || touch .kabanero-svt.published

 # password scrubbing must be after last logfile output

 scrubpw=`cat .kubeadmin.passwd`
 sed -i "s/$scrubpw/xx-password-xx/g" $testLogFile
 rm -f .kubeadmin.passwd

# break out the single log file into setup/install/verify temp logs
 sed -n "/$log_crc_fyre_start/,/$log_crc_install_end/p" $testLogFile > $setupLogFile
 sed -n "/$log_kabanero_install_start/,/$log_kabanero_install_end/p" $testLogFile > $kabaneroLogFile
 sed -n "/$log_kabanero_verify_start/,/$log_kabanero_verify_end/p" $testLogFile > $verifyLogFile
 sed -n '/PLAY RECAP/,/\$/p' $testLogFile > $playRecapLogFile

# check for failed ansible 
 egrep -i 'fatal|failed]' $setupLogFile > /dev/null
 [ "$?" == '0' ] && setupFailuresFound="True" || setupFailuresFound="False"
 sed -i "1s|^|Original logfile - $testLogFile\n\n|" $setupLogFile
 sed -i "1s|^|Original logfile - $testLogFile\n\n|" $playRecapLogFile

# during crc startup, if there is a newer version out in the cloud, this message is seen:
# A new version (1.4.0) has been published on https://cloud.redhat.com/openshift/install/crc/installer-provisioned
# where 1.4.0 changes
# check and flag it at the end of processing
 newcrcVersionAvail=$(grep 'A new version' $setupLogFile)

 if [ -s $kabaneroLogFile ] ; then
     gKabanero="--contentKabanero $kabaneroLogFile" 
     isKabanero='True'
     # check for failed ansible 
     egrep -i 'fatal|failed]' $kabaneroLogFile > /dev/null
     [ "$?" == '0' ] &&  kabaneroFailuresFound="True" || kabaneroFailuresFound="False"
     sed -i "1s|^|Original logfile - $testLogFile\n\n|" $kabaneroLogFile
 else
     isKabanero='False'
     kabaneroFailuresFound='False'
 fi
 if [ -s $verifyLogFile ] ; then
     gVerify="--contentVerify $verifyLogFile" 
     isVerify='True'
     # check for failed ansible 
     egrep -i 'fatal|failed]' $verifyLogFile > /dev/null
     [ "$?" == '0' ] &&  verifyFailuresFound="True" || verifyFailuresFound="False"
     sed -i "1s|^|Original logfile $testLogFile\n\n|" $verifyLogFile
 else
     isVerify='False'
     verifyFailuresFound='False'
 fi
 if [ -s $playRecapLogFile ] ; then
     gPlayRecap="--contentPlayRecap $playRecapLogFile"
     isPlayRecap='True'
 else
     isPlayRecap='False'
 fi

 # targetHost.txt is hard coded in the firecrcvm.yml - do not change

 ../reports/CreateGitIssues.py \
    --releasecsv ../reports/config/kabanero.release.csv \
    --gtoken ~/.gtoken \
    --isSetup 'True' \
    --isKabanero $isKabanero \
    --isVerify $isVerify \
    --isPlayRecap $isPlayRecap \
    --postfix targetHost.txt \
    --contentSetup $setupLogFile \
    --setupFailuresFound $setupFailuresFound \
    --kabaneroFailuresFound $kabaneroFailuresFound \
    --verifyFailuresFound $verifyFailuresFound \
    $gKabanero \
    $gVerify \
    $gPlayRecap
}
 
# trap keyboard interrupt (control-c)
trap control_c SIGINT EXIT

run_test()
{
 echo "Original logs: $HOSTNAME:$testLogFile"
 echo ""
 ansible-playbook crc_kabanero.yml $kabParms
 [ "$?" != '0' ] && return
 echo "Test complete. overall runtime $((SECONDS/60)) minutes"
 touch .crctest.complete
} 


# run in the same directory as the source script
cd $(dirname $(readlink -f $0))

. ./svtinfo.sh

[ -f .kabanero-svt.running ] && echo "$0 already running - exiting" && exit || true
touch .kabanero-svt.running

[ -d "$logDir" ] && true || mkdir "$logDir"
[ -d hosts ] && true || mkdir -p hosts

[ -n "$kabaneroRelease" ] && kabParms=" -e kabaneroRelease=$kabaneroRelease" || kabParms=''
# clean up the crc vm
if [ "$deleteVm" == "True" ] ; then
 echo "Kabanero Fyre vm will be deleted"
 touch "$deleteFyrevm" 
else
 echo "Kabanero Fyre vm will not be deleted"
 rm -f "$deleteFyrevm" > /dev/null
fi

run_test | tee $testLogFile

publish_logs

# new version of CRC?
[ ${#newcrcVersionAvail} -gt 0 ] && echo "\n!! NEWER CRC Available !! $newcrcVersionAvail"
