#!/bin/sh

gcloud dataproc jobs submit spark \
    --cluster=${CLUSTER} \
    --jar=gs://${BUCKET_NAME}/scala/co-purchase-analysis_2.12-1.0.jar \
    --region=${REGION} \
    --properties spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem \
    -- gs://${BUCKET_NAME}/input/ gs://${BUCKET_NAME}/output/

