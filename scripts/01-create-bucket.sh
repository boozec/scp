#!/bin/sh

read -p "Enter 'order_products.csv' path: " path

gcloud storage buckets create gs://$BUCKET_NAME --location=eu
gcloud storage buckets add-iam-policy-binding gs://${BUCKET_NAME} \
    --member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.objectCreator"
gcloud storage cp $path gs://$BUCKET_NAME/input/
