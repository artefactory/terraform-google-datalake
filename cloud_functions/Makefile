.PHONY: cloud_function

PROJECT_ID=la-sandbox-de-reda-fee9#Your GCP project id 
NOTIFICTION_TOPIC_NAME=datalake-bucket-notifications-a#The notification topic name if chosen
REGION=europe-west1 #Belgium
CF_SVC_ACCOUNT=quarentine-cf

set_project_config:
	gcloud config set project $(PROJECT_ID)

set_cloud_function_svc_account:
	gcloud iam service-accounts create $(CF_SVC_ACCOUNT) --display-name="My Service Account" && \
	gcloud projects add-iam-policy-binding $(PROJECT_ID)  --member=serviceAccount:$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/run.invoker
	gcloud projects add-iam-policy-binding $(PROJECT_ID) --member=serviceAccount:$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/storage.admin
deploy_cloud_function:
	@echo "enabling required APIs and deploying cloud function"
	@gcloud services enable cloudfunctions.googleapis.com && \
	gcloud services enable cloudbuild.googleapis.com && \
	gcloud services enable artifactregistry.googleapis.com && \
	gcloud services enable eventarc.googleapis.com && \
	gcloud services enable run.googleapis.com && \
	echo "deploying cloud function " && \
	gcloud functions deploy send_blob_to_quarentine_bucket --region=$(REGION) --runtime=python310 --gen2 --entry-point=main --service-account="$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com" --trigger-topic=$(NOTIFICTION_TOPIC_NAME)  --trigger-service-account="$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com"
