.PHONY: all clean install build deploy deploy-dev deploy-production infra-ticket infra-ticket-entrywriter ticket-entrywriter ticket-udm ticket-admin ticket-organizer run-dev-admin run-dev-entrywriter run-dev-organizer dev-admin dev-entrywriter dev-udm dev-organizer test-admin test-entrywriter test-udm staging-admin staging-entrywriter staging-udm production-admin production-entrywriter production-udm lint

install: clean
	@echo "Installing dependencies"
	yarn install

build:
	echo "Building the application"
	yarn build

docs:
	@echo "Deploying $(APP)-portal with stage: $(ENV) to $(URL)"
	aws s3 sync ./dist/ s3://api-docs.junctionnet.cloud
