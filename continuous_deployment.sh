#!/usr/bin/env bash

if \
    [ "${CONTINUOUS_DEPLOYMENT_OPS}" == "1" ]
then
    cd /pwd
    RES=0
    ! ./cloudbuild.sh gcr.io/midbarrn/midburn-profiles-drupal:_ midbarrn midburn-profiles-drupal . && RES=1
    ! ./cloudbuild.sh gcr.io/midbarrn/midburn-profiles-drupal-db:_ midbarrn midburn-profiles-drupal-db db && RES=1
    exit $RES

elif [ "${DEPLOY_ENVIRONMENT}" != "" ] && [ "${TRAVIS_PULL_REQUEST}" == "false" ] &&\
   ([ "${TRAVIS_BRANCH}" == "${DEPLOY_BRANCH}" ] || ([ "${DEPLOY_TAGS}" == "true" ] && [ "${TRAVIS_TAG}" != "" ])) &&\
   ! echo "${TRAVIS_COMMIT_MESSAGE}" | grep -- --no-deploy
then
    openssl aes-256-cbc -K $encrypted_9e4a6751a6cc_key -iv $encrypted_9e4a6751a6cc_iv -in ./k8s-ops-secret.json.enc -out ./secret-k8s-ops.json -d
    OPS_REPO_SLUG="Midburn/midburn-k8s"
    OPS_REPO_BRANCH="${OPS_REPO_BRANCH:-master}"
    wget https://raw.githubusercontent.com/OriHoch/sk8s-ops/master/run_docker_ops.sh
    chmod +x run_docker_ops.sh bin/continuous_deployment.sh
    ! ./run_docker_ops.sh "${DEPLOY_ENVIRONMENT}" "/pwd/continuous_deployment.sh" \
                          "orihoch/sk8s-ops" "${OPS_REPO_SLUG}" "${OPS_REPO_BRANCH}" "" "
                            -v `pwd`:/pwd
                            -e OPS_REPO_SLUG=${OPS_REPO_SLUG}
                            -e OPS_REPO_BRANCH=${OPS_REPO_BRANCH}
                            -e CONTINUOUS_DEPLOYMENT_OPS=1
                          " \
        && echo 'failed to run docker ops' && exit 1
fi

exit 0
