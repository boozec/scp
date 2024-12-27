#!/bin/sh

gcloud dataproc clusters create ${CLUSTER} \
    --project=${PROJECT} \
    --region=${REGION} \
    --service-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com \
    --num-workers 2 \
    --master-boot-disk-size 240 \
    --worker-boot-disk-size 240 \
    --worker-machine-type n1-standard-2 \
    --master-machine-type n1-standard-2
