#!/bin/sh

path="$1"

if [ -z "$path" ] || [ ! -e "$path" ]; then
    path=$(find . -name 'order_products.csv' -print -quit)

    if [ -z "$path" ]; then
        echo ">>>> Path not found..."
        exit 1
    fi
fi

gcloud storage buckets create gs://${BUCKET_NAME} --location=eu
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.objectCreator"
gcloud storage cp $path gs://${BUCKET_NAME}/input/
