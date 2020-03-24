#!/bin/bash

set -Eeuox pipefail

COLLECTION="java-microprofile" \
APP="sample-java-microprofile" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.com/kabanero-io/${APP}/" \
APP_REV="5423ba905d3413fa40725751f66fa6841acd9d82" \
PIPELINE="build-push-deploy-pipeline" \
$(dirname "$0")/pipelinerun.sh
