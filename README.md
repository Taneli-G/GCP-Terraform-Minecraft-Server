# Terraform GCP Minecraft Server

A work-in-progress terraform project which setups a fully functional dockerized Minecraft server on GCP Compute Engine.

Remember to enable required GCP APIs before running Terraform commands. Enabled APIs listed below.

NAME |                             TITLE
|----------|------:|
artifactregistry.googleapis.com   |Artifact Registry API
bigquery.googleapis.com           |BigQuery API
bigquerymigration.googleapis.com  |BigQuery Migration API
bigquerystorage.googleapis.com    |BigQuery Storage API
cloudapis.googleapis.com          |Google Cloud APIs
cloudbuild.googleapis.com         |Cloud Build API
cloudfunctions.googleapis.com     |Cloud Functions API
cloudtrace.googleapis.com         |Cloud Trace API
compute.googleapis.com            |Compute Engine API
containerregistry.googleapis.com  |Container Registry API
datastore.googleapis.com          |Cloud Datastore API
logging.googleapis.com            |Cloud Logging API
monitoring.googleapis.com         |Cloud Monitoring API
osconfig.googleapis.com           |OS Config API
oslogin.googleapis.com            |Cloud OS Login API
pubsub.googleapis.com             |Cloud Pub/Sub API
run.googleapis.com                |Cloud Run Admin API
servicemanagement.googleapis.com  |Service Management API
serviceusage.googleapis.com       |Service Usage API
source.googleapis.com             |Legacy Cloud Source Repositories API
sql-component.googleapis.com      |Cloud SQL
storage-api.googleapis.com        |Google Cloud Storage JSON API
storage-component.googleapis.com  |Cloud Storage
storage.googleapis.com            |Cloud Storage API

You must also modify index.js file under gcp-functions folder to match your deployment zone and region if you wish to start/stop the server from cloud functions as Terraform cannot automate .js variables.
