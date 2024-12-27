#!/bin/sh

gcloud compute networks subnets update default \
  --region $REGION \
  --enable-private-ip-google-access

