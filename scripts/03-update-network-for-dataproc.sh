#!/bin/sh

if [ ${DEBUG:+1} ]; then
    set -euxo pipefail
fi

gcloud compute networks subnets update default \
  --region=${REGION} \
  --enable-private-ip-google-access

