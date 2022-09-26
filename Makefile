SHELL := /bin/bash
K3S_TOKEN="mak3rVA87qPxet2SB8BDuLPWfU2xnPUSoETYF"
RANCHER_VERSION="2.6.6"
SERVER_NUM=-1
ADMIN_SECRET="6DfOqQMzaNFTg6VV"
K3S_CHANNEL=v1.23
K3S_UPGRADE_CHANNEL=v1.24
RANCHER_SUBDOMAIN=scale-test
SQL_PASSWORD="Kw309ii9mZpqD"
export KUBECONFIG=kubeconfig
BACKUP_NAME=kubeconfig.elemental_test
API_TOKEN="abcdef:EXAMPLEtokenGoesHere"
DOWNSTREAM_COUNT=0
RANCHER_NODE_COUNT=1

destroy:
	-rm kubeconfig
	cd terraform-setup && terraform destroy -auto-approve && rm terraform.tfstate terraform.tfstate.backup

sleep:
	sleep 60

rancher-quick: infrastructure k3s-install rancher

infrastructure:
	echo "Creating infrastructure"
	cd terraform-setup && terraform init && terraform apply -auto-approve -var rancher_url=$(RANCHER_SUBDOMAIN) -var db_password=$(SQL_PASSWORD) -var downstream_count=$(DOWNSTREAM_COUNT) -var rancher_node_count=$(RANCHER_NODE_COUNT)

k3s-install: 
	echo "Creating k3s cluster"
	source bin/get-env.sh && [[ ! -n "${IP1}" ]] && echo "Cluster will be single node" || "Cluster will be multi-node"
	source bin/get-env.sh && ssh -o StrictHostKeyChecking=no ec2-user@${IP0} "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) INSTALL_K3S_EXEC='server --tls-san ${IP0} ' K3S_DATASTORE_ENDPOINT='${RDS_PRE}$(SQL_PASSWORD)${RDS_POST}' K3S_TOKEN=$(K3S_TOKEN) K3S_KUBECONFIG_MODE=644 sh -"
	source bin/get-env.sh && [[ -z "${IP1}" ]] && echo "no additional servers to join cluster" || ssh -o StrictHostKeyChecking=no ec2-user@${IP1} "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) INSTALL_K3S_EXEC='server --tls-san ${IP0} --tls-san ${IP1}' K3S_DATASTORE_ENDPOINT='${RDS_PRE}$(SQL_PASSWORD)${RDS_POST}' K3S_TOKEN=$(K3S_TOKEN) K3S_KUBECONFIG_MODE=644 sh -"
	source bin/get-env.sh && scp -o StrictHostKeyChecking=no ec2-user@${IP0}:/etc/rancher/k3s/k3s.yaml kubeconfig
	source bin/get-env.sh && sed -i '' "s/127.0.0.1/${IP0}/g" kubeconfig

backup_kubeconfig:
	cp ~/.kube/config ~/.kube/$(BACKUP_NAME)

install_kubeconfig:
	cp ./kubeconfig ~/.kube/config

restore_kubeconfig:
	cp ~/.kube/$(BACKUP_NAME) ~/.kube/config

rancher: 
	echo "Installing cert-manager and Rancher"
	kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
	helm repo update
	helm upgrade --install \
		  cert-manager jetstack/cert-manager \
		  --namespace cert-manager \
		  --version v1.9.1 \
		  --create-namespace 
	kubectl rollout status deployment -n cert-manager cert-manager
	kubectl rollout status deployment -n cert-manager cert-manager-webhook
	source bin/get-env.sh && helm upgrade --install rancher rancher-stable/rancher \
	  --namespace cattle-system \
	  --version ${RANCHER_VERSION} \
	  --set hostname=$${URL} \
	  --set bootstrapPassword=${ADMIN_SECRET} \
	  --set replicas=2 \
	  --create-namespace 
	kubectl rollout status deployment -n cattle-system rancher
	kubectl -n cattle-system wait --for=condition=ready certificate/tls-rancher-ingress
	echo
	echo
	source bin/get-env.sh && echo https://$${URL}/dashboard/?setup=${ADMIN_SECRET}

elemental_operator:
	helm upgrade --create-namespace -n cattle-elemental-system --install elemental-operator oci://registry.opensuse.org/isv/rancher/elemental/charts/elemental/elemental-operator

inventory:
	kubectl apply -f e7l/cluster.yaml
	kubectl apply -f e7l/registration.yaml
	kubectl apply -f e7l/selector.yaml

