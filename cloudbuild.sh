#!/usr/bin/env bash

IMAGE_TAG="${1}"
CLOUDSDK_CORE_PROJECT="${2}"
PROJECT_NAME="${3}"
BUILD_PATH="${4:-.}"

([ -z "${IMAGE_TAG}" ] || [ -z "${CLOUDSDK_CORE_PROJECT}" ] || [ -z "${PROJECT_NAME}" ]) \
    && echo "usage:" && echo "./cloudbuild.sh <IMAGE_TAG> <CLOUDSDK_CORE_PROJECT> <PROJECT_NAME>" && exit 1

gcloud --project "${CLOUDSDK_CORE_PROJECT}" container builds submit --substitutions _IMAGE_TAG=${IMAGE_TAG},_CLOUDSDK_CORE_PROJECT=${CLOUDSDK_CORE_PROJECT},_PROJECT_NAME=${PROJECT_NAME} \
                                                                    --config cloudbuild-gcr-docker-cache.yaml \
                                                                    --machine-type n1-highcpu-32 \
                                                                    --timeout "24h0m0s" \
                                                                    "${BUILD_PATH}"
