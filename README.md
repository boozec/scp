# Co-Purchase Analysis Project

This repository pertains to the project for the [Scalable and Cloud Programming](https://www.unibo.it/en/study/phd-professional-masters-specialisation-schools-and-other-programmes/course-unit-catalogue/course-unit/2023/479058) class, designed for A.A. 24/25 students.

## Setup

For local testing, we use Scala 2.13.12, which is not supported by Google Cloud. Instead, for Google Cloud testing, we use Scala 2.12.10. The version of Spark used is 3.5.3.

The following environment variables need to be set up:

- `PROJECT=`
- `BUCKET_NAME=`
- `CLUSTER=`
- `REGION=europe-west3`  # This is the only supported region.
- `SERVICE_ACCOUNT=`
- `GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/google-service-account-key.json`
- `JAVA_OPTS="--add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED"`
- `SCALA_VERSION=2.13.12`

### Google Cloud

To set up the project on Google Cloud, enable the following APIs for your project:

- Cloud Dataproc API
- Cloud Storage API

After enabling these APIs, you can perform all necessary actions using the scripts provided in the `scripts/` folder.

However, before proceeding, you need to install the [gcloud CLI](https://cloud.google.com/sdk/docs/install). This project uses Google Cloud Storage, not BigQuery, so the `bq` command-line tool is not required.

## Local Testing

In the `co-purchase-analysis/` folder, there is an `input/` folder containing a sample CSV file provided as a testing example.

To run the local test:

```bash
$ cd co-purchase-analysis
$ sbt
sbt:co-purchase-analysis> run input/ output/
```

The above commands will generate three files in the output/ folder that can be merged:

```bash
$ cat output/_SUCCESS output/part-00000 output/part-00001
8,14,2
12,16,1
14,16,1
12,14,3
8,16,1
8,12,2
```

## Google Cloud Testing

To test on Google Cloud, execute the following shell scripts in the given order:

- `scripts/00-create-service-account.sh`
- `scripts/01-create-bucket.sh`
- `scripts/02-dataproc-copy-jar.sh`
- `scripts/03-update-network-for-dataproc.sh`
- `scripts/04-dataproc-create-cluster.sh`
- `scripts/05-dataproc-submit.sh`
- `scripts/06-dataproc-update-cluster.sh`
- `scripts/07-cleanup.sh`

`04-dataproc-create-cluster.sh` and `06-dataproc-update-cluster.sh` accept one
argument: the workers number. It can be 1, 2, 3 or 4.
