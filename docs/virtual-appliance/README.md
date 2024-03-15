# Elemental - it's not just for bare metal anymore

## How to create an OVA for the Elemental Stack.

* Elemental is a toolkit for creating full stack solutions that depend on cloud-native kubernetes infrastructure. Using elemental, we can create an IoT like device which runs kubernetes configurations but is simple enough to be deployed in an Operational Technology (OT) environment.

* Elemental was originally designed for use on bare metal but it's pretty easy to use the same technology and garner the same benefits (OT) by fabricating a VM appliance for a hypervisor.

* Open Virtualization Appliance (OVA) is a .tar archive containing the multiple components of an Open Virtualization Format (OVF) VM. The format is an open standard and is commonly used by a variety of hypervisors including vSphere, Virtual Box and XenServer. 

* From this point on, we're going to assume you know how to build an elemental system and this guide simply lays out the finer points to get it into the OVA format.

* We used ESXi to get the OVF contents and then vmware's ovftool to package it up.  I downloaded ovftool from [vmware's download site](https://developer.vmware.com/web/tool/4.4.0/ovf) and had to give up some personal information in order to get past their EULA. If you know of an open source tool to convert OVF to OVA, please file an issue and we'll update this doc. The proprietary nature of all these tools emboldened by the word "open" is quite unseemly.

* The main difference between bare metal deployments and virtual appliances is that we typically see that the virtual appliance needs to go through 1st and 2nd boot cycles on-site whereas the bare metal deployments usually go through 1st boot offsite (in a fullfilment supplier) and then get shipped to the site where it will go through second boot and site configuration process. Adjust your registration files accordingly if, for example, you always want the option to have a user involved in the 2nd boot process.

## OVF to OVA Steps

1. Create an elemental registration file that only goes into first boot and then shuts down. 

    `registration.yaml`
    ```
    apiVersion: elemental.cattle.io/v1beta1
    kind: MachineRegistration
    metadata:
      name: vtpm-demo
      namespace: fleet-default
    spec:
      config:
        elemental:
          install:
            poweroff: true
            device: /dev/sda
            debug: true
            eject-cd: true
          registration:
            emulate-tpm: true
            emulated-tpm-seed: -1
            no-smbios: true
      machineName: "${System Information/UUID}"
      machineInventoryLabels:
        location: "us"
        # manufacturer: "${System Information/Manufacturer}"
        # productName: "${System Information/Product Name}"
        # serialNumber: "${System Information/Serial Number}"
        # machineUUID: "${System Information/UUID}"
    ```

1. Build your ISO 

1. Manually create a VM with the ISO attached

1. Boot the VM and let it come up and shutdown

1. Export the OVF content

1. Update your registration file to automatically reboot

    `registration.yaml`
    ```
    apiVersion: elemental.cattle.io/v1beta1
    kind: MachineRegistration
    metadata:
      name: vtpm-demo
      namespace: fleet-default
    spec:
      config:
        elemental:
          install:
            reboot: true
            device: /dev/sda
            debug: true
            eject-cd: true
          registration:
            emulate-tpm: true
            emulated-tpm-seed: -1
            no-smbios: true
      machineName: "${System Information/UUID}"
      machineInventoryLabels:
        location: "us"
        # manufacturer: "${System Information/Manufacturer}"
        # productName: "${System Information/Product Name}"
        # serialNumber: "${System Information/Serial Number}"
        # machineUUID: "${System Information/UUID}"
    ```

1. Build a new ISO with this registration

## The turning point

* At this point, you have all the bits to crank out OVAs. We built the original OVF with a minimal system so it should be very lightweight and the VMDK is small. So now anytime you want a new system, you can use the same OVF and just replace the ISO and run ovftool to generate an OVA. Steps as folllows:

1. Swapout the ISO that was downloaded with the OVF for this new ISO. 

1. Run `ovftool <your-template.ovf> <your-desired-appliance.ova>`

You can now port this to any hypervisor that takes the OVA format.