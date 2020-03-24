#!/bin/bash

set -Eeo pipefail

### Configuration ###

SLEEP_LONG="${SLEEP_LONG:-15}"
SLEEP_SHORT="${SLEEP_SHORT:-2}"

# Resultant Appsody container image #
DOCKER_IMAGE="${DOCKER_IMAGE:-image-registry.openshift-image-registry.svc:5000/kabanero/java-microprofile}"

# Appsody project GitHub repository #
APP_REPO="${APP_REPO:-https://github.com/kabanero-io/sample-java-microprofile/}"
APP_REV="${APP_REV:-master}"

COLLECTION="${COLLECTION:-java-microprofile}"
APP="${APP:-sample-java-microprofile}"
PIPELINE="${PIPELINE:-build-push-deploy-pipeline}"
PIPELINE_RUN="${PIPELINE_RUN:-$COLLECTION-$PIPELINE-run}"
PIPELINE_REF="${PIPELINE_REF:-$COLLECTION-$PIPELINE}"
PIPELINE_TIMEOUT="${PIPELINE_TIMEOUT:-60m}"
DOCKER_IMAGE_REF="${DOCKER_IMAGE_REF:-$APP-docker-image}"
GITHUB_SOURCE_REF="${GITHUB_SOURCE_REF:-$APP-git-source}"


### Tekton Example ###
namespace=kabanero

# Cleanup
oc -n ${namespace} delete pipelinerun ${PIPELINE_RUN} --ignore-not-found
oc -n ${namespace} delete pipelineresource ${DOCKER_IMAGE_REF} ${GITHUB_SOURCE_REF} --ignore-not-found
oc -n ${namespace} delete appsodyapplication ${APP} --ignore-not-found

# Pipeline Resources: Source repo and destination container image
cat <<EOF | oc -n ${namespace} apply -f -
apiVersion: v1
items:
- apiVersion: tekton.dev/v1alpha1
  kind: PipelineResource
  metadata:
    name: ${DOCKER_IMAGE_REF}
  spec:
    params:
    - name: url
      value: ${DOCKER_IMAGE}
    type: image
- apiVersion: tekton.dev/v1alpha1
  kind: PipelineResource
  metadata:
    name: ${GITHUB_SOURCE_REF}
  spec:
    params:
    - name: revision
      value: ${APP_REV}
    - name: url
      value: ${APP_REPO}
    type: git
kind: List
EOF


# Manual Pipeline Run
cat <<EOF | oc -n ${namespace} apply -f -
apiVersion: tekton.dev/v1alpha1
kind: PipelineRun
metadata:
  name: ${PIPELINE_RUN}
  namespace: kabanero
spec:
  pipelineRef:
    name: ${PIPELINE_REF}
  resources:
  - name: git-source
    resourceRef:
      name: ${GITHUB_SOURCE_REF}
  - name: docker-image
    resourceRef:
      name: ${DOCKER_IMAGE_REF}
  serviceAccount: kabanero-operator
  timeout: ${PIPELINE_TIMEOUT}
EOF



# Run Completion
unset STATUS
unset TYPE
unset REASON
until [ "$STATUS" == "True" ] && [ "$TYPE" == "Succeeded" ] && [ "$REASON" == "Succeeded" ]
do
	echo "Waiting for PipelineRun ${PIPELINE_RUN} to Complete"
	STATUS=$(oc -n ${namespace} get pipelinerun ${PIPELINE_RUN} --output=jsonpath={.status.conditions[-1:].status})
	TYPE=$(oc -n ${namespace} get pipelinerun ${PIPELINE_RUN} --output=jsonpath={.status.conditions[-1:].type})
	REASON=$(oc -n ${namespace} get pipelinerun ${PIPELINE_RUN} --output=jsonpath={.status.conditions[-1:].reason})
	if [ "$STATUS" == "False" ] && [ "$TYPE" == "Succeeded" ] && [ "$REASON" == "Failed" ]; then
		echo "PipelineRun ${PIPELINE_RUN} Failed"
		exit 1
	fi
	if [ "$STATUS" == "False" ] && [ "$TYPE" == "Succeeded" ] && [ "$REASON" == "PipelineRunTimeout" ]; then
		echo "PipelineRun ${PIPELINE_RUN} timed out"
		exit 1
	fi
	sleep $SLEEP_LONG
done


# Some samples are not full apps
if [ -n "$NO_APP_CHECK" ]; then
	exit 0
fi

# Appsody check
unset STATUS
unset TYPE
until [ "$STATUS" == "True" ] && [ "$TYPE" == "Reconciled" ]
do
	echo "Waiting for AppsodyApplication ${APP} to Reconcile"
	STATUS=$(oc -n ${namespace} get appsodyapplication ${APP} --output=jsonpath={.status.conditions[-1:].status})
	TYPE=$(oc -n ${namespace} get appsodyapplication ${APP} --output=jsonpath={.status.conditions[-1:].type})
	REASON=$(oc -n ${namespace} get appsodyapplication ${APP} --output=jsonpath={.status.conditions[-1:].reason})
	if [ "$REASON" == "InternalError" ]; then
		echo "AppsodyApplication ${APP} failed to reconcile"
		exit 1
	fi
done

CREATE_KNATIVE=$(oc -n ${namespace} get appsodyapplication ${APP} --output=jsonpath={.spec.createKnativeService})

if [ "$CREATE_KNATIVE" = "true" ]; then
	# ksvc ready check
	unset STATUS
	unset REASON
	until [ "$STATUS" == "True" ] 
	do
		echo "Waiting for KnativeService ${APP} to become Ready"
		STATUS=$(oc -n ${namespace} get ksvc ${APP} --output=jsonpath='{.status.conditions[?(@.type == "Ready")].status}')
		REASON=$(oc -n ${namespace} get ksvc ${APP} --output=jsonpath='{.status.conditions[?(@.type == "ConfigurationsReady")].reason}')
		if [ "$REASON" == "RevisionFailed" ]; then
			echo "ksvc ${APP} failed with RevisionFailed"
			exit 1
		fi
	done
	URL=$(oc -n ${namespace} get ksvc ${APP} --output=jsonpath={.status.url})
else
	URL=$(oc -n ${namespace} get route ${APP} --output=jsonpath='http://{.status.ingress[*].host}')
fi

# Application endpoint test
echo "Testing application endpoint: $URL"
curl --retry 10 --silent --show-error --fail ${URL}
