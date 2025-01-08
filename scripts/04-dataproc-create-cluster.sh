#!/bin/sh

set -eu

if [ "$#" -ne 3 ]; then
    echo "Usage: 'sh ${PWD}/$0 <num-workers> <master-machine> <worker-machine>'"
    exit 1
fi


NUM_WORKERS="$1"
MASTER_MACHINE="$2"
WORKER_MACHINE="$3"

if [ "$NUM_WORKERS" -lt 1 ] || [ "$NUM_WORKERS" -gt 4 ]; then
    echo "<num-workers> must be 1, 2, 3, or 4"
    exit 1
fi

if [ -z "$MASTER_MACHINE" ]; then
    echo "Error: Master machine type cannot be empty."
    exit 1
fi

if [ -z "$WORKER_MACHINE" ]; then
    echo "Error: Worker machine type cannot be empty."
    exit 1
fi

COMMON_PARAMS="\
    --project=${PROJECT} \
    --region=${REGION} \
    --service-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com \
    --master-boot-disk-size=240 \
    --worker-boot-disk-size=240 \
    --worker-machine-type=${WORKER_MACHINE} \
    --master-machine-type=${MASTER_MACHINE}"

if [ "$NUM_WORKERS" -eq 1 ]; then
    echo ">>>> Creating a single-node cluster..."
    gcloud dataproc clusters create "${CLUSTER}" \
        ${COMMON_PARAMS} \
        --single-node
else
    echo ">>>> Creating a cluster with ${NUM_WORKERS} workers..."
    gcloud dataproc clusters create "${CLUSTER}" \
        ${COMMON_PARAMS} \
        --num-workers="${NUM_WORKERS}"
fi
