REPO_BASE=
YOUR_APP_NAME=blacktail
IMAGE_NAME=beanstream/$(YOUR_APP_NAME)
VERSION=1.0.0

APP_NAME=blacktail
EB_BUCKET=eb-docker-deploy
EB_APP_ENV_NAME=$(APP_NAME)
ZIP=$(EB_APP_ENV_NAME).zip

all:

build:
	sed -i'.orig' -e "s/VERSION/$(VERSION)/g" Dockerrun.aws.json
	sed -i'.orig' -e "s/<VERSION>/$(VERSION)/g" app/server.py
	sed -i'.tmp' -e "s/YOUR_APP_NAME/$(YOUR_APP_NAME)/g" Dockerrun.aws.json
	docker build -t $(IMAGE_NAME):$(VERSION) --rm .
	rm -f Dockerrun.aws.json.tmp
	mv Dockerrun.aws.json.orig Dockerrun.aws.json
	mv app/server.py.orig app/server.py

build_no_cache:
	docker build --no-cache -t $(IMAGE_NAME):$(VERSION) --rm .

tag:
	docker tag $(IMAGE_NAME):$(VERSION) $(REPO_BASE)/$(IMAGE_NAME):$(VERSION)

tag_latest:
	docker tag $(IMAGE_NAME):$(VERSION) $(REPO_BASE)/$(IMAGE_NAME):latest

login:
	$(shell aws ecr get-login --region us-east-1)

push: login
	docker push $(REPO_BASE)/$(IMAGE_NAME):$(VERSION)

push_latest: login
	docker push $(REPO_BASE)/$(IMAGE_NAME):latest

shell:
	docker run -it $(IMAGE_NAME):$(VERSION) /bin/ash

shell_latest:
	docker run -it $(IMAGE_NAME):$(VERSION) /bin/ash

run:
	docker run -d -p 80:8080 -e "WEB_CONCURRENCY=3" $(IMAGE_NAME):$(VERSION)

run_latest:
	docker run -d -p 80:8080 -e "WEB_CONCURRENCY=3" $(REPO_BASE)/$(IMAGE_NAME):latest

test:
	mkdir -p coverage
	docker run -v $(shell pwd)/coverage:/deploy/coverage $(IMAGE_NAME):$(VERSION) /bin/ash /deploy/testrunner.sh

deploy: login
    # Set version string
	sed -i'.orig' -e "s/VERSION/$(VERSION)/g" Dockerrun.aws.json
	sed -i'.tmp' -e "s/YOUR_APP_NAME/$(YOUR_APP_NAME)/g" Dockerrun.aws.json
	rm -f Dockerrun.aws.json.tmp

	# Upload zipped Dockerrun file to S3
	zip -r $(ZIP) Dockerrun.aws.json
	mv Dockerrun.aws.json.orig Dockerrun.aws.json
	aws s3 cp $(ZIP) s3://$(EB_BUCKET)/$(ZIP)
	rm $(ZIP)

	# Create new app version with zipped Dockerrun file
	aws elasticbeanstalk create-application-version --application-name $(APP_NAME) \
	--version-label $(VERSION) \
	--source-bundle S3Bucket=$(EB_BUCKET),S3Key=$(ZIP) \
	--region us-east-1

	# Update the environment to use the new app version
	aws elasticbeanstalk update-environment --application-name $(APP_NAME) \
	--environment-name $(EB_APP_ENV_NAME) \
	--version-label $(VERSION) \
	--region us-east-1
