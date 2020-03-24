#!/bin/bash

set -Eeuox pipefail

COLLECTION="java-websphere-traditional" \
APP="sample-twas" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.ibm.com/was-svt/${APP}/" \
APP_REV="7f5f1c93856e7492d93f0c31ef0269b37636eea0" \
PIPELINE="build-push-deploy-pipeline" \
$(dirname "$0")/pipelinerun.sh
