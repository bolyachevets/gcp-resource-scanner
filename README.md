# GCP Canadian Resource Scanner

A tool to scan Google Cloud Platform resources across projects and verify if they are deployed in Canadian regions.

## Overview

This script scans GCP resources for data residency compliance, checking if databases, storage, backups, and network resources are located in Canadian regions (northamerica-northeast1, northamerica-northeast2, or the Canadian multi-region).

## Features

- Scans multiple projects and environments
- Checks databases (Cloud SQL, Firestore, Bigtable, Spanner, Redis, BigQuery)
- Verifies storage locations (Cloud Storage, including multi-regional buckets)
- Checks backups (Cloud SQL backups, disk snapshots, etc.)
- Examines compute resources (Cloud Run services and jobs)
- Examines network resources
- Checks Artifact Registry repositories
- Generates a summary report of compliant and non-compliant resources

## Usage

### Resource Scanning Mode (Default)

To scan resources for Canadian region compliance:

```bash
./run.sh
```

### IAM Permission Granting Mode

To grant the Viewer role to the service account defined in the script:

```bash
GRANT_VIEWER_ROLE=true ./run.sh
```

### Email Notifications

The script can send email notifications when non-Canadian resources are detected:

```bash
# Enable email notifications
SEND_EMAIL_NOTIFICATION=true ./run.sh
```

### Report Storage

The script can optionally save compliance reports to a Google Cloud Storage bucket:

```bash
# Enable GCS report storage
SAVE_TO_GCS=true REPORT_BUCKET=my-compliance-reports ./run.sh
```

You can create a `.env` file in the project root with these variables:

```
# Email notification settings
SEND_EMAIL_NOTIFICATION=false
NOTIFY_CLIENT=your-notify-client-id
NOTIFY_CLIENT_SECRET=your-notify-client-secret
KC_URL=https://keycloak.example.com/auth/realms/your-realm/protocol/openid-connect/token
NOTIFY_API_URL=https://notify-api.example.com
ERROR_EMAIL_RECIPIENTS=compliance-team@example.com,admin@example.com

# Test email without actual non-compliant resources
TEST_EMAIL=false

# GCS report storage
SAVE_TO_GCS=false
REPORT_BUCKET=my-compliance-reports-bucket

# Scan configuration (comma-separated lists)
SCAN_PROJECTS=a083gt,bcrbk9,c4hnrd
SCAN_ENVIRONMENTS=dev,test,prod

# IAM permission granting
GRANT_VIEWER_ROLE=false
```

Then source it before running the script:
```bash
set -a && source .env && set +a && ./run.sh
```


## Requirements

- Google Cloud SDK (`gcloud`)
- `gsutil` command line tool
- Appropriate permissions to scan resources and grant IAM roles

## Notes

- Multi-regional storage within Canada (CA region) is considered compliant
- The script uses the Cloud Asset Inventory API for efficient scanning

## Building and Deploying with Docker

### Configure GCP Artifact Registry

```bash
# Configure Docker to use GCP Artifact Registry
gcloud auth configure-docker northamerica-northeast1-docker.pkg.dev

# Build the image
docker build -t northamerica-northeast1-docker.pkg.dev/c4hnrd-dev/job-repo/compliance-checker:latest .

# Push to Artifact Registry
docker push northamerica-northeast1-docker.pkg.dev/c4hnrd-dev/job-repo/compliance-checker:latest
```
