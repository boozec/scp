# Co-Purchase Analysis Project

This repository pertains to the project for the [Scalable and Cloud Programming](https://www.unibo.it/en/study/phd-professional-masters-specialisation-schools-and-other-programmes/course-unit-catalogue/course-unit/2023/479058) class, designed for A.A. 24/25 students.

## Setup

For local testing, we use Scala 2.13.12, which is not supported by Google Cloud. Instead, for Google Cloud testing, we use Scala 2.12.10. The version of Spark used is 3.5.3.

The following environment variables need to be set up:

- `PROJECT=`
- `BUCKET_NAME=`
- `CLUSTER=`
- `REGION=europe-west3`
- `ZONE=europe-west3-a`
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

The above commands will generate two files in the output/ folder that can be merged:

```bash
$ cat output/_SUCCESS output/part-00000
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
- `scripts/01-create-bucket.sh [order_products.csv path]`

    If not specified, the file will be searched in the current path.

- `scripts/02-dataproc-copy-jar.sh`
- `scripts/03-update-network-for-dataproc.sh`
- `scripts/04-dataproc-create-cluster.sh <num-workers> <master-machine> <worker-machine>`
- `scripts/05-dataproc-submit.sh <num-partitions>`
- `scripts/06-dataproc-update-cluster.sh <num-workers> <master-machine> <worker-machine>`
- `scripts/07-cleanup.sh`

Using `06-dataproc-update-cluster.sh` is not recommended if you want to test
with another master/worker machine types. Instead, is better to run:

```
$ gcloud dataproc clusters delete ${CLUSTER} --region=${REGION}
```

Then, run again `scripts/04-dataproc-create-cluster.sh` + `scripts/05-dataproc-submit.sh`.

## Full Example

```
$ export PROJECT=stately-mote-241200-d1
$ export BUCKET_NAME=scp-boozec-test1
$ export CLUSTER=scp1
$ export REGION=europe-west3
$ export ZONE=europe-west3-a
$ export SERVICE_ACCOUNT=spark-access-scp-boozec
$ export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/google-service-account-key.json
$ export JAVA_OPTS="--add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED"
$ export SCALA_VERSION=2.13.12

$ gcloud auth login
$ gcloud config set project $PROJECT
$ gcloud config set compute/region $REGION
$ gcloud config set compute/zone $ZONE

$ scripts/00-create-service-account.sh; \
    scripts/01-create-bucket.sh; \
    scripts/02-dataproc-copy-jar.sh; \
    scripts/03-update-network-for-dataproc.sh; \
    scripts/04-dataproc-create-cluster.sh 1 n1-standard-4 n1-standard-4; \
    scripts/05-dataproc-submit.sh; \
    scripts/06-dataproc-update-cluster.sh 2 n1-standard-4 n1-standard-4; \
    scripts/05-dataproc-submit.sh; \
    scripts/06-dataproc-update-cluster.sh 3 n1-standard-4 n1-standard-4; \
    scripts/05-dataproc-submit.sh; \
    scripts/06-dataproc-update-cluster.sh 4 n1-standard-4 n1-standard-4; \
    scripts/05-dataproc-submit.sh
```

After that, you can also check the created 4 jobs.

```
$ # If you pass --cluster="${CLUSTER}" you'll ignore jobs for deleted cluster,
$ # even if they have the same name of a current cluster.
$ # For instance, it won't work if you change from single node to multi worker.
$ gcloud dataproc jobs list --region="${REGION}" --format="table(
        reference.jobId:label=JOB_ID,
        status.state:label=STATUS,
        status.stateStartTime:label=START_TIME
    )"
JOB_ID                            STATUS  START_TIME
fa29602262b347aba29f5bda1beaf369  DONE    2025-01-07T09:12:10.080801Z
974e473c0bcb487295ce0cdd5fb3ea59  DONE    2025-01-07T09:01:57.211118Z
1791614d26074ba3b02b905dea0c90ac  DONE    2025-01-07T08:50:45.180903Z
515efdc823aa4977ac0557c63a9d16a2  DONE    2025-01-07T08:34:06.987101Z
```

Now, check the output on your local machine (you have the last one output folder).

```
$ gsutil -m cp -r "gs://${BUCKET_NAME}/output" .
```

After downloading the data, you can find the row with the highest counter.

```
$ grep -iR `cat part-000* | cut -d ',' -f 3 | awk '{if($1>max){max=$1}} END{print max}'`
```

Finally, clean up everything.

```
$ scripts/07-cleanup.sh
$ # In `07-cleanup.sh` you don't delete jobs list.
$ for JOB in `gcloud dataproc jobs list --region="${REGION}" --format="table(reference.jobId:label=JOB_ID)" | tail -n +2`; do \
    gcloud dataproc jobs delete --region="${REGION}" $JOB --quiet; \
  done
```

### Test weak scaling efficiency

We have a good parameter of testing increasing the input file by n-times. For
instance, for 2 nodes we can use a doubli-fication of exam's input file.

```
$ cat order_products.csv order_products.csv >> order_products_twice.csv
$ ls -l
.rw-r--r-- santo santo 417 MB Fri Nov 22 12:43:07 2024 📄 order_products.csv
.rw-r--r-- santo santo 834 MB Mon Jan 13 15:12:13 2025 📄 order_products_twice.csv
$ wc -l *.csv
  32434489 order_products.csv
  64868978 order_products_twice.csv
$ egrep -n "^2,33120" order_products_twice.csv
1:2,33120
32434490:2,33120
$ scripts/00-create-service-account.sh; \
    scripts/01-create-bucket.sh ./order_products_twice.csv; \
    scripts/02-dataproc-copy-jar.sh; \
    scripts/03-update-network-for-dataproc.sh; \
    scripts/04-dataproc-create-cluster.sh 2 n1-standard-4 n1-standard-4; \
    scripts/05-dataproc-submit.sh 200
```

The given output is what we obtain using 2 work-units for 2 nodes $W(2) =
\frac{T_1}{T_2}$.
