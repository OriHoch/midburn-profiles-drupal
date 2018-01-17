#!/usr/bin/env bash

if \
    [ "${CONTINUOUS_DEPLOYMENT_OPS}" == "1" ]
then
    RES=0
    cd /ops
    HELM_UPDATE_COMMIT_MESSAGE="update midburn profiles drupal images --no-deploy"
    ! ./helm_update_values.sh "${B64_UPDATE_VALUES}" "${HELM_UPDATE_COMMIT_MESSAGE}" "${K8S_OPS_GITHUB_REPO_TOKEN}" \
                              "${OPS_REPO_SLUG}" "${OPS_REPO_BRANCH}" && RES=1

    cd /pwd
    ls -lah
    echo "IMAGE_TAG=${IMAGE_TAG}"
    echo "DB_IMAGE_TAG=${DB_IMAGE_TAG}"
    ! ./cloudbuild.sh ${IMAGE_TAG} midbarrn midburn-profiles-drupal . && RES=1
    ! ./cloudbuild.sh ${DB_IMAGE_TAG} midbarrn midburn-profiles-drupal-db db && RES=1
    exit $RES

elif [ "${DEPLOY_ENVIRONMENT}" != "" ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ] &&\
   ([ "${TRAVIS_BRANCH}" == "${DEPLOY_BRANCH}" ] || ([ "${DEPLOY_TAGS}" == "true" ] && [ "${TRAVIS_TAG}" != "" ])) &&\
   ! echo "${TRAVIS_COMMIT_MESSAGE}" | grep -- --no-deploy
then
    openssl aes-256-cbc -K $encrypted_9e4a6751a6cc_key -iv $encrypted_9e4a6751a6cc_iv -in ./k8s-ops-secret.json.enc -out ./secret-k8s-ops.json -d
    OPS_REPO_SLUG="Midburn/midburn-k8s"
    OPS_REPO_BRANCH="${OPS_REPO_BRANCH:-master}"
    IMAGE_TAG="gcr.io/midbarrn/midburn-profiles-drupal:${TRAVIS_TAG:-$TRAVIS_COMMIT}"
    DB_IMAGE_TAG="gcr.io/midbarrn/midburn-profiles-drupal-db:${TRAVIS_TAG:-$TRAVIS_COMMIT}"
    echo "IMAGE_TAG=${IMAGE_TAG}"
    echo "DB_IMAGE_TAG=${DB_IMAGE_TAG}"
    B64_UPDATE_VALUES=`echo '{"profiles":{"image":"'${IMAGE_TAG}'", "dbImage":"'${DB_IMAGE_TAG}'"}}' | base64 -w0`
    wget https://raw.githubusercontent.com/OriHoch/sk8s-ops/master/run_docker_ops.sh
    chmod +x run_docker_ops.sh
    ! ./run_docker_ops.sh "${DEPLOY_ENVIRONMENT}" "/pwd/continuous_deployment.sh" \
                          "orihoch/sk8s-ops" "${OPS_REPO_SLUG}" "${OPS_REPO_BRANCH}" "" "
                            -v `pwd`:/pwd
                            -e B64_UPDATE_VALUES=${B64_UPDATE_VALUES}
                            -e K8S_OPS_GITHUB_REPO_TOKEN=${K8S_OPS_GITHUB_REPO_TOKEN}
                            -e OPS_REPO_SLUG=${OPS_REPO_SLUG}
                            -e OPS_REPO_BRANCH=${OPS_REPO_BRANCH}
                            -e CONTINUOUS_DEPLOYMENT_OPS=1
                            -e IMAGE_TAG=${IMAGE_TAG}
                            -e DB_IMAGE_TAG=${DB_IMAGE_TAG}
                          " \
        && echo 'failed to run docker ops' && exit 1
fi

exit 0
