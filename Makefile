SHELL := /bin/bash
REGISTRATION_NAME := rpi-demo
# REPO can be one of dev|staging|stable
REPO := stable



elemental_operator:
	helm repo add elemental https://rancher.github.io/elemental-operator/stable
	helm repo update
	helm upgrade --create-namespace -n cattle-elemental-system --install --set image.imagePullPolicy=Always elemental-operator-crds elemental/elemental-operator-crds  
	helm upgrade --create-namespace -n cattle-elemental-system --install --set image.imagePullPolicy=Always elemental-operator elemental/elemental-operator 

registration:
	kubectl apply -f e7l/registration.yaml

cluster:
	kubectl apply -f e7l/suse.yaml

pull-registration:
	curl -k $(shell kubectl get machineregistration -n fleet-default $(REGISTRATION_NAME) -o jsonpath="{.status.registrationURL}") -o build/$(REGISTRATION_NAME)-registration.yaml


iso: clean 
	[[ ! -d build ]] && mkdir build || echo "build/ exists, continuing .."
	curl -k $(shell kubectl get machineregistration -n fleet-default $(REGISTRATION_NAME) -o jsonpath="{.status.registrationURL}") -o build/initial-registration.yaml
	cd build && wget -q https://raw.githubusercontent.com/rancher/elemental/main/.github/elemental-iso-add-registration && chmod +x elemental-iso-add-registration
	cd build && REPO=$(REPO) ./elemental-iso-add-registration initial-registration.yaml

clean:
	rm -rf build/*

rpi-raw:
	pushd build && \
	wget -q https://download.opensuse.org/repositories/isv:/Rancher:/Elemental:/Stable/containers/rpi.raw && \
	popd

.PHONY: rpi-raw-validate
rpi-raw-validate: rpi-raw
	pushd build && \
	wget -q https://download.opensuse.org/repositories/isv:/Rancher:/Elemental:/Stable/containers/rpi.raw.sha256 && \
	sha256sum -c rpi.raw.sha256 && \
	popd

.PHONY: rpi-seed
# copy the registration file into the current rpi.raw image
rpi-seed: pull-registration
	$(eval REGISTRATION_NAME := rpi-demo)
	pushd build && \
	../bin/copy_registration.sh ${REGISTRATION_NAME} && \
	popd

.PHONY: rpi-fresh-seed
# get a new raw image before copying in the registration
rpi-fresh-seed: clean rpi-raw-validate rpi-seed
