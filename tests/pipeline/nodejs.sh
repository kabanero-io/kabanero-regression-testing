#!/bin/bash

set -Eeuox pipefail

COLLECTION="nodejs" \
APP="sample-nodejs" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.com/kabanero-io/${APP}/" \
APP_REV="c1b098272f0123a9076b3c6a7ae1d44a8c818210" \
PIPELINE="build-push-deploy-pipeline" \
NO_APP_CHECK="TRUE" \
$(dirname "$0")/pipelinerun.sh
