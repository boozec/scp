#!/bin/sh

set -eu

if [ ${DEBUG:+1} ]; then
    set -xo pipefail
fi

INPUT_PATH="gs://${BUCKET_NAME}/input/"
OUTPUT_PATH="gs://${BUCKET_NAME}/output"

if [ -z "${BUCKET_NAME}" ] || [ -z "${CLUSTER}" ] || [ -z "${REGION}" ]; then
    echo "Error: BUCKET_NAME, CLUSTER, and REGION environment variables must be set."
    exit 1
fi

if gsutil ls "${OUTPUT_PATH}" > /dev/null 2>&1; then
    echo ">>>> Output folder already exists. Renaming..."
    UUID=$(cat /proc/sys/kernel/random/uuid)
    NEW_OUTPUT_PATH="${OUTPUT_PATH}-${UUID}"

    echo ">>>> Copying existing output folder to ${NEW_OUTPUT_PATH}..."
    if gsutil -m cp -r "${OUTPUT_PATH}/" "${NEW_OUTPUT_PATH}/"; then
        echo ">>>> Deleting original output folder..."
        if gsutil -m rm -r "${OUTPUT_PATH}"; then
            echo ">>>> Original output folder successfully renamed to ${NEW_OUTPUT_PATH}"
        else
            echo "Error: Failed to delete the original output folder after copying."
            exit 1
        fi
    else
        echo "Error: Failed to copy the output folder to ${NEW_OUTPUT_PATH}."
        exit 1
    fi
fi

gcloud dataproc jobs submit spark \
    --cluster="${CLUSTER}" \
    --jar="gs://${BUCKET_NAME}/scala/co-purchase-analysis_2.12-1.0.jar" \
    --region="${REGION}" \
    --properties="spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem" \
    -- "${INPUT_PATH}" "${OUTPUT_PATH}"
