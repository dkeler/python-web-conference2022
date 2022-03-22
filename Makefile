SHELL := /bin/bash

.DEFAULT_GOAL = help

export PROJECT_DIR ?= $(CURDIR)
export OUTPUT_DIR ?= $(PROJECT_DIR)/out
export KUBECONFIG ?= $(HOME)/.kube/config
### Provide your credentials for JFrog Platform
export PRIV_REG ?= localhost
export int_artifactory_url ?= https://$(PRIV_REG)/artifactory
export int_artifactory_user ?= admin
export int_artifactory_apikey ?= strongpassword
### Provide your credentials for JFrog Platform
export PY_REPO ?= python
export POD_BUILD_PATH ?= $(CURDIR)/pod/Containerfile
export RELEASE_NAME ?= py-web-conf
export POD_APP_NAME ?= $(RELEASE_NAME)-app
export POD_APP_IMAGE ?= $(POD_APP_NAME)
export POD_APP_TAG ?= latest
export POD_APP_PORT ?= 3000
export TS := $(shell /bin/date "+%Y-%m-%d-%H-%M-%S")

help:	## Show this help
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "target" "help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
		IFS=$$':' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf '\033[36m'; \
		printf "%-30s %s" $$help_command ; \
		printf '\033[0m'; \
		printf "%s\n" $$help_info; \
	done

build-app:
	poetry config http-basic.artifactory $(int_artifactory_user) $(int_artifactory_apikey)
	poetry config repositories.artifactory '$(int_artifactory_url)/api/pypi/$(PY_REPO)'
	cd app; poetry install

test-app1:
	poetry config http-basic.artifactory $(int_artifactory_user) $(int_artifactory_apikey)
	poetry config repositories.artifactory '$(int_artifactory_url)/api/pypi/$(PY_REPO)'
	cd app; poetry install
	cd app; pytest -m test1 --no-header --junitxml=tests1/tests_report.xml -v

test-app2:
	poetry config http-basic.artifactory $(int_artifactory_user) $(int_artifactory_apikey)
	poetry config repositories.artifactory '$(int_artifactory_url)/api/pypi/$(PY_REPO)'
	cd app; poetry install
	cd app; pytest -m test2 --no-header --junitxml=tests2/tests_report.xml -v

test-app3:
	poetry config http-basic.artifactory $(int_artifactory_user) $(int_artifactory_apikey)
	poetry config repositories.artifactory '$(int_artifactory_url)/api/pypi/$(PY_REPO)'
	cd app; poetry install
	cd app; pytest -m test3 --no-header --junitxml=tests3/tests_report.xml -v

publish-app:
	poetry config http-basic.artifactory $(int_artifactory_user) $(int_artifactory_apikey)
	poetry config repositories.artifactory '$(int_artifactory_url)/api/pypi/$(PY_REPO)'
	cd app; poetry publish --build -r artifactory


deploy-k8s-app:
	$(Deploy app to k8s with Helm)
	export KUBECONFIG=$(KUBECONFIG); helm upgrade --install $(RELEASE_NAME) ./chart

delete-k8s-app:
	$(Delete app from k8s)
	-export KUBECONFIG=$(KUBECONFIG); helm delete $(RELEASE_NAME); sleep 10