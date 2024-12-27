#!/bin/sh

gcloud dataproc clusters create ${CLUSTER} \
    --project=${PROJECT} \
    --region=${REGION} \
    --service-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com \
    --master-boot-disk-size 240 \
    --worker-boot-disk-size 240 \
    --num-workers 1 \
    --single-node
