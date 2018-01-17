#FROM ubuntu:trusty
#
#RUN apt-get update && apt-get install -y curl &&\
#    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" &&\
#    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
#    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - &&\
#    apt-get update && apt-get install -y google-cloud-sdk
#
#COPY secret-k8s-ops.json .
#
#RUN gcloud auth activate-service-account --key-file=secret-k8s-ops.json;\
#    gcloud config set project midbarrn;\
#    addgroup --system --gid 1000 bitnami;\
#    adduser --system --uid 1000 --gid 1000 bitnami;\
#    mkdir -p /opt/bitnami;\
#    gsutil -qm cp -cUPR gs://midburn-k8s-backups/profiles-production-2018-01-16/etc /;\
#    gsutil -qm cp -cUPR gs://midburn-k8s-backups/profiles-production-2018-01-16/home/bitnami /home/;\
#    gsutil -qm cp -cUPR gs://midburn-k8s-backups/profiles-production-2018-01-16/opt/bitnami /opt/;\
#    rm -f secret-k8s-ops.json
FROM gcr.io/midbarrn/midburn-profiles-drupal-latest@sha256:2e7b073da40bfca3205c0fd7a2f1f378644eeb6da683f267b8fd4f7ab91bb168

COPY drupal_site_default_settings.php /opt/bitnami/apps/drupal/htdocs/sites/default/settings.php
COPY htaccess.conf /opt/bitnami/apps/drupal/conf/
COPY htdocs/robots.txt /opt/bitnami/apps/drupal/htdocs/

RUN chown bitnami:daemon /opt/bitnami/apps/drupal/htdocs/sites/default/settings.php \
                         /opt/bitnami/apps/drupal/conf/htaccess.conf

RUN python -c "import random; s='abcdefghijklmnopqrstuvwxyz01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ'; print(''.join(random.sample(s,40)))" > /drupalsalt

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
