#!/bin/bash

set -Eeox pipefail

# require jq. kubectl can not handle multiple filter jsonpath
if ! which jq; then
  "jq is required, please install jq in your PATH."
  exit 1
fi

if ! oc whoami; then
  "Not logged in. Please login as a cluster-admin."
  exit 1
fi

# if the user is not kube:admin, or the user is not a cluster-admin, exit
USER="$(oc whoami)"
if [ "$USER" != "kube:admin" ]; then
  if [ "$USER" != "$(oc get clusterrolebinding -o json | jq -r '.items[] | select(.roleRef.name=="cluster-admin") | select(.subjects[].name=="'$USER'") | .subjects[0].name')" ]; then
    echo "$USER does not have a clusterrolebinding of cluster-admin. Please login as a cluster-admin."
    exit 1
  fi
fi

HOST=$( oc cluster-info | grep "is running" | awk -F/ '{print $3}' | awk -F: '{print $1}')

if [ ! -d /etc/docker/certs.d/${HOST} ] ; then
 sudo mkdir -p /etc/docker/certs.d/${HOST} || true openssl s_client -connect ${HOST}:443 -servername ${HOST} 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFIC$'
fi

if [ "$USER" == "kube:admin" ]; then
  USER=kubeadmin
fi

docker login -u $USER -p $(oc whoami -t) ${HOST}

