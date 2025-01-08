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


# Handle single worker case
if [ "$NUM_WORKERS" -eq 1 ]; then
    if gcloud dataproc clusters describe "${CLUSTER}" --region="${REGION}" > /dev/null 2>&1; then
        echo ">>>> Cluster exists. Destroying it..."
        gcloud dataproc clusters delete "${CLUSTER}" --region="${REGION}" --quiet
    fi

    echo ">>>> Creating a new cluster with 1 worker..."
    eval "scripts/04-dataproc-create-cluster.sh 1 ${MASTER_MACHINE} ${WORKER_MACHINE}"
else
    if ! gcloud dataproc clusters update "${CLUSTER}" \
        --project="${PROJECT}" --region="${REGION}" \
        --num-workers="${NUM_WORKERS}" > /dev/null 2>&1; then
        echo ">>>> Cluster is a single node. Destroying it to update the number of workers..."
        gcloud dataproc clusters delete "${CLUSTER}" --region="${REGION}" --quiet

        echo ">>>> Creating a new cluster with ${NUM_WORKERS} workers..."
        eval "scripts/04-dataproc-create-cluster.sh ${NUM_WORKERS} ${MASTER_MACHINE} ${WORKER_MACHINE}"
    else
        echo ">>>> Successfully updated the cluster to ${NUM_WORKERS} workers."
    fi
fi

