# Elemental Testing
Build a rancher instance for testing and working with elemental instances.

## Dependencies

* terraform
* helm
* jq
* kubectl
* aws
* dns address for Rancher

## Quick Start
### Prep
* `cp terraform-setup/terraform.tfvars.template terraform-setup/terraform.tfvars`
    * Adjust the tfvars variables as desired
* Set your aws account id and key using the terraform variables
    * `aws_access_key_id`
    * `aws_secret_access_key`
* See `variables.tf` for other infrastructure configuration 
* Make sure you have a registered domain
    * Use terraform variable `domain` to set it
    * Use terraform variable `rancher_url` to set the subdomain
    * fqdn is <rancher_url>.<domain>

### Build the Rancher infrastructure
```
make infrastructure
make k3s-install
make rancher
```
The prior commands will create 2 infrastructure nodes for the rancher cluster and 0 nodes (using `DOWNSTREAM_COUNT` variable) for populating with virtual clusters. Currently we don't need the virtual clusters as we will be creating elemental clusters instead.

1. Login to Rancher at the URL output by the last make command

### Install elemental operator
1. Insure your kubeconfig points to the newly created rancher cluster 
    * There are several make targets to assist with that
    * `make backup_kubeconfig` backup your existing kubeconfig that lives at ~/.kube/config to ~/.kube/kubeconfig.elemental_test
    * `make install_kubeconfig` install the rancher clusters kubeconfig into ~/.kube/config
    * `make restore_kubeconfig` restore the kubeconfig that was backed up at ~/.kube/kubeconfig.elemental_test to ~/.kube/config
1. `make elemental_operator`


### Build Downstream Clusters (optional)
If you do need downstream clusters in AWS that are not using elemental, set DOWNSTREAM_COUNT to a number > 0 and use the following command with an API token generated from Rancher to install k3s on those downstream clusters.
1. `make DOWNSTREAM_COUNT=3 infrastructure`
1. `make API_TOKEN="ab39g:4ioooooEXAMPLEoooTOKENoooookj98z" downstream`
1. Register each cluster in Rancher as needed.

