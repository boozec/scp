#!/bin/sh

path=$(find . -name 'order_products.csv' -print -quit)

if [ -z "$path" ]; then
    read -p "Enter 'order_products.csv' path: " path
    if [ -z "$path" ] || [ ! -e "$path" ]; then
        echo ">>>> Path not found..."
        exit 1
    fi
fi

gcloud storage buckets create gs://$BUCKET_NAME --location=eu
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.objectCreator"
gcloud storage cp $path gs://$BUCKET_NAME/input/
