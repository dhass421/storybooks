PROJECT_ID=storybooks-devops-314100
ZONE=us-central1-a

run-local:
	docker-compose up

###

create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform

###

define get-secret
$(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID))
endef

###

ENV=staging

terraform-create-workspace:
	cd terraform && terraform workspace new $(ENV)

terraform-init:
	cd terraform && terraform workspace select $(ENV) && terraform init

TF_ACTION?=plan
terraform-action:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform $(TF_ACTION) \
	-var-file="./enviornments/common.tfvars" \
	-var-file="./enviornments/$(ENV)/config.tfvars" \
	-var="mongodbatlas_private_key=$(call get-secret,atlas_private_key)" \
	-var="atlas_user_password=$(call get-secret,atlas_user_password_$(ENV))" \
	-var="cloudflare_api_token=$(call get-secret,cloudflare_api_token)"

###

SSH_STRING=dhass421@storybooks-vm-$(ENV)

GITHUB_SHA?=latest
LOCAL_TAG=storybooks-app:$(GITHUB_SHA)
REMOTE_TAG=gcr.io/$(PROJECT_ID)/$(LOCAL_TAG)
CONTAINER_NAME=storybooks-api

ssh:
	@gcloud compute ssh $(SSH_STRING) \
	--project=$(PROJECT_ID) \
	--zone=$(ZONE)

ssh-cmd:
	gcloud compute ssh $(SSH_STRING) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE)
		--command="$(CMD)"

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

deploy:
	$(MAKE) ssh-cmd CMD='docker-credential-gcr configure-docker'
	@echo "Pulling new container image..."
	$(MAKE) ssh-cmd CMD='docker pull $(REMOTE_TAG)'
	@echo "Removing old container..."
	-$(MAKE) ssh-cmd CMD='docker container stop $(CONTAINER_NAME)'
	-$(MAKE) ssh-cmd CMD='docker container rm $(CONTAINER_NAME)'
	@echo "Starting new container..."
	@$(MAKE) ssh-cmd='\
	docker run -d --name=$(CONTAINER_NAME) \
		--restart=unless-stopped \
		-p 80:3000 \
		-e PORT=3000 \
		-e \"MONGO_URI=mongodb+srv://storybooks-user-$(ENV):$(call get-secret,atlas_user_password_$(ENV))@storybooks-$(ENV).x9znb.mongodb.net/$(DB_NAME)?retryWrites=true&w=majority\" \
		-e GOOGLE_CLIENT_ID=229898095119-dkgloehr89nn84q5cktrotg3fv7qf95d.apps.googleusercontent.com \
		-e GOOGLE_CLIENT_SECRET=$(call get-secret,google_oauth_client_secret) \
		$(REMOTE_TAG) \
		'
