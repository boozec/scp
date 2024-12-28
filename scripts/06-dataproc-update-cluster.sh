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


# Handle single worker case
if [ "$NUM_WORKERS" -eq 1 ]; then
    if gcloud dataproc clusters describe "${CLUSTER}" --region="${REGION}" > /dev/null 2>&1; then
        echo ">>>> Cluster exists. Destroying it..."
        gcloud dataproc clusters delete "${CLUSTER}" --region="${REGION}" --quiet
    fi

    echo ">>>> Creating a new cluster with 1 worker..."
    eval "scripts/04-dataproc-create-cluster.sh 1"
else
    if ! gcloud dataproc clusters update "${CLUSTER}" \
        --project="${PROJECT}" --region="${REGION}" \
        --num-workers="${NUM_WORKERS}" > /dev/null 2>&1; then
        echo ">>>> Cluster is a single node. Destroying it to update the number of workers..."
        gcloud dataproc clusters delete "${CLUSTER}" --region="${REGION}" --quiet

        echo ">>>> Creating a new cluster with ${NUM_WORKERS} workers..."
        eval "scripts/04-dataproc-create-cluster.sh ${NUM_WORKERS}"
    else
        echo ">>>> Successfully updated the cluster to ${NUM_WORKERS} workers."
    fi
fi

