SHELL := /bin/bash


elemental_operator:
	helm upgrade --create-namespace -n cattle-elemental-system --install elemental-operator oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator
	sleep 20
	kubectl apply -f e7l/registration.yaml

register_cluster:
	kubectl apply -f e7l/suse-cluster.yaml
	kubectl apply -f e7l/suse-selector.yaml

iso: clean
	[[ ! -d build ]] && mkdir build || echo "build/ exists, continuing .."
	curl -k $(shell kubectl get machineregistration -n fleet-default kubecon-demo -o jsonpath="{.status.registrationURL}") -o build/initial-registration.yaml
	cd build && curl -sLO https://raw.githubusercontent.com/rancher/elemental/main/.github/elemental-iso-build && chmod +x elemental-iso-build
	cd build && ./elemental-iso-build initial-registration.yaml

clean:
	rm -rf build/*iso*