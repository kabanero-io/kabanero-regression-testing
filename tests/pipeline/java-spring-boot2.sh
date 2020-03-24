#!/bin/bash

set -Eeuox pipefail

COLLECTION="java-spring-boot2" \
APP="sample-java-spring-boot2" \
DOCKER_IMAGE="image-registry.openshift-image-registry.svc:5000/kabanero/${APP}" \
APP_REPO="https://github.com/kabanero-io/${APP}/" \
APP_REV="3d7152adb43e16ef065ab53813a771b705006638" \
PIPELINE="build-push-deploy-pipeline" \
$(dirname "$0")/pipelinerun.sh
