.PHONY: cloud_function

PROJECT_ID=la-sandbox-de-reda-fee9#Your GCP project id 
NOTIFICTION_TOPIC_NAME=datalake-bucket-notifications-a#The notification topic name if chosen
REGION=europe-west1 #Belgium
CF_SVC_ACCOUNT=quarentine-cf
ENTRY_POINT=main
CLOUD_FUNCTION_NAME=send_blob_to_quarentine_bucket

set_project_config:
	gcloud config set project $(PROJECT_ID)

set_cloud_function_svc_account:
	gcloud iam service-accounts create $(CF_SVC_ACCOUNT) --display-name="My Service Account" && \
	gcloud projects add-iam-policy-binding $(PROJECT_ID) --member=serviceAccount:$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/run.invoker
	gcloud projects add-iam-policy-binding $(PROJECT_ID) --member=serviceAccount:$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com --role=roles/storage.admin
deploy_cloud_function:
	@echo "enabling required APIs and deploying cloud function"
	@gcloud services enable cloudfunctions.googleapis.com && \
	gcloud services enable cloudbuild.googleapis.com && \
	gcloud services enable artifactregistry.googleapis.com && \
	gcloud services enable eventarc.googleapis.com && \
	gcloud services enable run.googleapis.com && \
	echo "deploying cloud function " && \
	gcloud functions deploy $(CLOUD_FUNCTION_NAME) --region=$(REGION) --runtime=python310 --gen2 --entry-point=main --service-account="$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com" --trigger-topic=$(NOTIFICTION_TOPIC_NAME)  --trigger-service-account="$(CF_SVC_ACCOUNT)@$(PROJECT_ID).iam.gserviceaccount.com"

local_deployment:
	@echo "set up dependencies"
	@echo "Installing JRE" && make install_jre && echo "Sucessfully installed JRE"
	@echo "Run PubSub emulator" && make run_pubsub_emulator && echo "Sucessfully run pub sub emulator"
	@echo "installing pack tool" && make install_pack_tool && echo "Sucessfully installed pack tool"
	@echo "Building docker image from the cloud function entrypoint" && make build_docker_image && echo "Succesfully built the cloud function docker image"
	@echo "Authenticating in GCP" && gcloud auth application-default login 
	@echo "Running the cloud function docker image" && docker run --rm -p 8080:8080 $(CLOUD_FUNCTION_NAME) echo "Succesfully run the cloud function docker image"

install_jre:
	brew install --cask adoptopenjdk/openjdk/adoptopenjdk8

run_pubsub_emulator:
	gcloud beta emulators pubsub start \
   		--project=abc \
    	--host-port='localhost:8043' &

install_pack_tool:
	brew install buildpacks/tap/pack

#DOES NOT WORK FOR MAC M1
build_docker_image:
	pack build \
		--builder gcr.io/buildpacks/builder:v1 \
		--env GOOGLE_FUNCTION_SIGNATURE_TYPE=event \
		--env GOOGLE_FUNCTION_TARGET=$(ENTRY_POINT) \
		$(CLOUD_FUNCTION_NAME) 