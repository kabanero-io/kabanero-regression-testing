#!/bin/bash

set -Eeuox pipefail

COLLECTION="nodejs-loopback" \
APP="sample-nodejs-loopback" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.com/kabanero-io/${APP}/" \
APP_REV="7aa3cc06dc7da26e86000b567e3636e0bcf5dce6" \
PIPELINE="build-push-deploy-pipeline" \
PIPELINE_TIMEOUT="90m" \
$(dirname "$0")/pipelinerun.sh
