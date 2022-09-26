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

=== "Rancher makefile options"

    * RANCHER_NODE_COUNT: number of nodes in the rancher cluster (default 1)
    * DOWNSTREAM_COUNT: number of single node downstream clusters to create (default 0)
    * RANCHER_SUBDOMAIN: the subdomain for the rancher instance
    * SQL_PASSWORD: the password for the sql backend

=== "Terraform variables"

    These are the underlying variables some of which can be modified by passing through the makefile.

    * aws_access_key_id = "AKIAXDJAMJALCJEHG7GF"
    * aws_secret_access_key = "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"
    * prefix = "mak3r"
    * ssh_key_file_name = "~/.ssh/id_rsa"
    * aws_region = "us-east-1"
    * db_instance_type = "db.m5.large"
    * db_password = "r4nch3r!"
    * downstream_count = 3

### Install elemental operator
1. Insure your kubeconfig points to the newly created rancher cluster 
    * There are several make targets to assist with that
    * `make backup_kubeconfig` backup your existing kubeconfig that lives at ~/.kube/config to ~/.kube/kubeconfig.elemental_test
    * `make install_kubeconfig` install the rancher clusters kubeconfig into ~/.kube/config
    * `make restore_kubeconfig` restore the kubeconfig that was backed up at ~/.kube/kubeconfig.elemental_test to ~/.kube/config
1. `make elemental_operator`


### Build the ISO for the Registered Cluster
NOTE: this has only been tested for x86_64 architecture

1. `make inventory`
1. `make iso`


### Build Downstream Clusters (optional)
If you do need downstream clusters in AWS that are not using elemental, set DOWNSTREAM_COUNT to a number > 0 and use the following command with an API token generated from Rancher to install k3s on those downstream clusters.
1. `make DOWNSTREAM_COUNT=3 infrastructure`
1. `make API_TOKEN="ab39g:4ioooooEXAMPLEoooTOKENoooookj98z" downstream`
1. Register each cluster in Rancher as needed.

