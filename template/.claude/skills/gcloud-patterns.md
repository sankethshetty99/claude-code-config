---
name: gcloud-patterns
description: Google Cloud Platform operations, deployment, Cloud Run, Cloud Functions, App Engine, Cloud SQL, GKE, IAM, logging, monitoring, builds, storage, secrets. Use when deploying, managing infrastructure, or troubleshooting GCP services.
---

# Google Cloud Platform Patterns

## Prerequisites

Before any GCP operation:
```bash
# Verify active project
gcloud config get-value project

# Verify authenticated account
gcloud auth list

# Check enabled APIs
gcloud services list --enabled
```

## Deployment Patterns

### Cloud Run (preferred for containerized web services)

```bash
# Deploy from source (auto-builds with Cloud Build)
gcloud run deploy SERVICE_NAME \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars "KEY=value"

# Deploy from container image
gcloud run deploy SERVICE_NAME \
  --image gcr.io/PROJECT_ID/IMAGE:TAG \
  --region us-central1 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10

# View service URL and status
gcloud run services describe SERVICE_NAME --region us-central1

# View recent logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME" --limit 50 --format json
```

### Cloud Functions (preferred for event-driven/lightweight)

```bash
# Deploy HTTP function (Gen 2)
gcloud functions deploy FUNCTION_NAME \
  --gen2 \
  --runtime nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --region us-central1 \
  --entry-point functionName \
  --set-env-vars "KEY=value"

# Deploy event-triggered function
gcloud functions deploy FUNCTION_NAME \
  --gen2 \
  --runtime nodejs20 \
  --trigger-event-filters="type=google.cloud.firestore.document.v1.written" \
  --trigger-event-filters="database=(default)" \
  --trigger-event-filters-path-pattern="document=users/{userId}" \
  --region us-central1

# View function logs
gcloud functions logs read FUNCTION_NAME --region us-central1 --limit 50
```

### App Engine

```bash
# Deploy (uses app.yaml in project root)
gcloud app deploy

# View logs
gcloud app logs tail -s default
```

## Database Patterns

### Cloud SQL

```bash
# List instances
gcloud sql instances list

# Connect via proxy (for local development)
gcloud sql connect INSTANCE_NAME --user=USER --database=DATABASE

# Export database
gcloud sql export sql INSTANCE_NAME gs://BUCKET/dump.sql --database=DATABASE
```

### Firestore

Managed via Firebase Admin SDK in code or Firebase console. No direct gcloud CLI for document operations.

## Secret Management

```bash
# Create a secret
echo -n "secret-value" | gcloud secrets create SECRET_NAME --data-file=-

# Access a secret
gcloud secrets versions access latest --secret=SECRET_NAME

# Grant access to a service account
gcloud secrets add-iam-policy-binding SECRET_NAME \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/secretmanager.secretAccessor"
```

**In application code** (Node.js):
```typescript
import { SecretManagerServiceClient } from "@google-cloud/secret-manager";

const client = new SecretManagerServiceClient();
const [version] = await client.accessSecretVersion({
  name: `projects/PROJECT_ID/secrets/SECRET_NAME/versions/latest`,
});
const secret = version.payload?.data?.toString();
```

## Cloud Storage

```bash
# Upload file
gcloud storage cp local-file.txt gs://BUCKET_NAME/

# Download file
gcloud storage cp gs://BUCKET_NAME/file.txt ./local-file.txt

# List bucket contents
gcloud storage ls gs://BUCKET_NAME/

# Make object public
gcloud storage objects update gs://BUCKET_NAME/file.txt --add-acl-grant=entity=allUsers,role=READER
```

## Cloud Build

```bash
# Submit a build
gcloud builds submit --tag gcr.io/PROJECT_ID/IMAGE_NAME

# View recent builds
gcloud builds list --limit 10

# View build logs
gcloud builds log BUILD_ID
```

## IAM

```bash
# List service accounts
gcloud iam service-accounts list

# Create service account
gcloud iam service-accounts create SA_NAME \
  --display-name="Description"

# Grant role to service account
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/ROLE_NAME"
```

## Logging & Monitoring

```bash
# Read recent logs (all services)
gcloud logging read --limit 50 --format json

# Filter by severity
gcloud logging read "severity>=ERROR" --limit 20

# Filter by resource type
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Filter by time range
gcloud logging read 'timestamp>="2024-01-01T00:00:00Z"' --limit 50
```

## Environment Variables

### Setting env vars on Cloud Run
```bash
gcloud run services update SERVICE_NAME \
  --region us-central1 \
  --set-env-vars "KEY1=val1,KEY2=val2"

# Or reference secrets
gcloud run services update SERVICE_NAME \
  --region us-central1 \
  --set-secrets "ENV_VAR=SECRET_NAME:latest"
```

### Setting env vars on Cloud Functions
```bash
gcloud functions deploy FUNCTION_NAME \
  --set-env-vars "KEY1=val1,KEY2=val2" \
  --set-secrets "ENV_VAR=SECRET_NAME:latest"
```

## When to Use Each Service

| Use Case | Service | Why |
|----------|---------|-----|
| Web app / API | Cloud Run | Containers, auto-scaling, custom runtime |
| Lightweight webhook | Cloud Functions | Simple, event-driven, pay-per-invocation |
| Static site + API | App Engine | Integrated, simple config |
| Background jobs | Cloud Tasks + Cloud Run | Async processing with retries |
| Scheduled tasks | Cloud Scheduler + Cloud Functions | Cron-like scheduling |
| File storage | Cloud Storage | Object storage, CDN-ready |
| Relational DB | Cloud SQL | Managed PostgreSQL/MySQL |
| Document DB | Firestore | NoSQL, real-time sync |
| Secrets | Secret Manager | Encrypted, versioned, IAM-controlled |

## Anti-Patterns

- Never hardcode project IDs — use `gcloud config get-value project` or env vars
- Never commit service account key files — use workload identity or application default credentials
- Never use `--allow-unauthenticated` in production without understanding the security implications
- Never skip `--region` flag — it defaults unpredictably
- Always enable only the APIs you need — use `gcloud services enable SERVICE_NAME`
