# Elemental Testing
Create an machine image and related rancher components for an elemental toolkit based cluster.

## Dependencies

* jq
* kubectl
* dns address for Rancher

## Quick Start
### Prep

* Get administrative access to a Rancher Management cluster.
* Update [registration.yaml](e7l/registration.yaml) to suit your needs

### Install elemental operator
1. Insure your kubeconfig points to the correct Rancher cluster 
1. `make elemental_operator`


### Build the ISO for the Registered Cluster
NOTE: this has only been tested for x86_64 architecture
 
1. `make iso`
1. [Burn the iso(s) to a usb stick](bin/iso_to_usb_stick.sh)
1. Boot the device(s) from the usb stick "install elemental"
1. Connect cluster to Rancher.
    * If the registration is set to `poweroff: true` then it will try to connect to the Rancher Management Server the next time it is rebooted.
    * If the registration is set to `reboot: true` then it will automatically reboot and attempt to connect.

### Create Clusters in Rancher
This can be 
1. `make register_cluster`

