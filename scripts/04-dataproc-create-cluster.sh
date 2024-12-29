#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: 'sh ${PWD}/$0 <num-workers>'"
    exit 1
fi


NUM_WORKERS="$1"
if [ "$NUM_WORKERS" -lt 1 ] || [ "$NUM_WORKERS" -gt 4 ]; then
    echo "<num-workers> must be 1, 2, 3, or 4"
    exit 1
fi

read -p "Enter worker-machine-type: " worker_machine

if [ -z "$worker_machine" ]; then
    echo "Error: Worker machine type cannot be empty."
    exit 1
fi

read -p "Enter master-machine-type: " master_machine

if [ -z "$master_machine" ]; then
    echo "Error: Master machine type cannot be empty."
    exit 1
fi

COMMON_PARAMS="\
    --project=${PROJECT} \
    --region=${REGION} \
    --service-account=${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com \
    --master-boot-disk-size=240 \
    --worker-boot-disk-size=240 \
    --worker-machine-type=${worker_machine} \
    --master-machine-type=${master_machine}"


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
