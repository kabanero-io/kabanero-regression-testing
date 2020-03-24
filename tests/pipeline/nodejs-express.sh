#!/bin/bash

set -Eeuox pipefail

COLLECTION="nodejs-express" \
APP="sample-nodejs-express" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.com/kabanero-io/${APP}/" \
APP_REV="c649dbca5821706f4f22bf526a5a3cc4415d3c26" \
PIPELINE="build-push-deploy-pipeline" \
$(dirname "$0")/pipelinerun.sh
