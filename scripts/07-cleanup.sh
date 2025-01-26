#!/bin/sh

if [ ${DEBUG:+1} ]; then
    set -euxo pipefail
fi

gcloud storage rm -r gs://
gcloud dataproc clusters delete ${CLUSTER} --region=${REGION}
gcloud iam service-accounts delete ${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com
