#!/bin/sh

if [ ${DEBUG:+1} ]; then
    set -exo pipefail
fi

gcloud iam service-accounts create ${SERVICE_ACCOUNT} \
    --description="Spark access account to Google Cloud Buckets" \
    --display-name="Spark to Bucket"

gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/dataproc.worker"

gcloud iam service-accounts keys create ./google-service-account-key.json \
    --iam-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com
