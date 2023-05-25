SHELL := /bin/bash
REGISTRATION_NAME := vtpm-demo
# REPO can be one of Dev|Staging|Stable
REPO := Staging
#OPERATOR := "oci://registry.opensuse.org/isv/rancher/elemental/dev/charts/rancher/elemental-operator-chart"
OPERATOR := "oci://registry.opensuse.org/isv/rancher/elemental/staging/charts/rancher/elemental-operator-chart"

elemental_operator:
	helm upgrade --create-namespace -n cattle-elemental-system --install --set image.imagePullPolicy=Always elemental-operator $(OPERATOR)

registration:
	kubectl apply -f e7l/registration.yaml

cluster:
	kubectl apply -f e7l/suse.yaml

iso: clean 
	[[ ! -d build ]] && mkdir build || echo "build/ exists, continuing .."
	curl -k $(shell kubectl get machineregistration -n fleet-default $(REGISTRATION_NAME) -o jsonpath="{.status.registrationURL}") -o build/initial-registration.yaml
	cd build && wget -q https://raw.githubusercontent.com/rancher/elemental/main/.github/elemental-iso-add-registration && chmod +x elemental-iso-add-registration
	cd build && REPO=$(REPO) ./elemental-iso-add-registration initial-registration.yaml

clean:
	rm -rf build/*iso*