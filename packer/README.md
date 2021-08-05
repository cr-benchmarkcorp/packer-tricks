# Packer build for RHEL 7/8 on VMware
This build handles the creation and configuration of RHEL 7/8 based images in VMware.

The build handles the following components: 
- Creation of VMWare Template
- Hardening Based on CIS Framework
- OpenSCAP Results of Template

## Compatibility
Packer files are built with HCL2 and are meant for use with Packer 1.7 and above.

## Usage
Usage is as follows:  
Build File:

```hcl
build {
  name = "rhel"
  description = <<EOF
//This build creates RHEL images for the following versions :
* 7
* 8
For the following builders :
* vsphere-iso
EOF

  source "source.vsphere-iso.base-rhel" {
    name                 = "8"
    boot_command         = ["<tab><wait>", " inst.text inst.ks=cdrom:/dev/sr1:/ks8.cfg<enter>"]
    cd_files             = ["${path.root}/kickstart/ks8.cfg"]
    guest_os_type        = "rhel8_64Guest"
    iso_paths            = ["[${var.vsphere-datastore}] isos/${var.isoname-rhel8}"]
    vm_name              = var.rhel8-template-name
    export {
      force = true
      output_directory = "./output_vsphere"
    }
  }

  source "source.vsphere-iso.base-rhel" {
    name                 = "7"
    boot_command         = ["<tab><wait>", " inst.text inst.ks=cdrom:/dev/sr1:/ks7.cfg<enter>"]
    cd_files             = ["${path.root}/kickstart/ks7.cfg"]
    guest_os_type        = "rhel7_64Guest"
    iso_paths            = ["[${var.vsphere-datastore}] isos/${var.isoname-rhel7}"]
    vm_name              = var.rhel7-template-name
    export {
      force = true
      output_directory = "./output_vsphere"
    }
  }
  post-processors {
    
  post-processor "artifice" {
      files = ["output_vsphere/${var.rhel8-template-name}-disk-0.vmdk"]
      only = ["vsphere-iso.8"]
    }

  post-processor "shell-local" {
    command = "gcloud compute images import rhel8-${formatdate("DD-MM-YY-hh-mm", timeadd(timestamp(),"-7h"))} --os=rhel-8-byol --family=rhel-8-family --source-file=output_vsphere/${var.rhel8-template-name}-disk-0.vmdk"
    only = ["vsphere-iso.8"]
  }

  post-processor "artifice" {
      files = ["output_vsphere/${var.rhel7-template-name}-disk-0.vmdk"]
      only = ["vsphere-iso.7"]
    }

  post-processor "shell-local" {
    command = "gcloud compute images import rhel7-${formatdate("DD-MM-YY-hh-mm", timeadd(timestamp(),"-7h"))} --os=rhel-7-byol --family=rhel-7-family --source-file=output_vsphere/${var.rhel7-template-name}-disk-0.vmdk"
    only = ["vsphere-iso.7"]
  }

  }
}
```
Source File
```hcl
source "vsphere-iso" "base-rhel" {
  CPUs                 = var.vm-cpu-num
  RAM                  = var.vm-mem-size
  RAM_reserve_all      = false
  cluster              = var.vsphere-cluster
  convert_to_template  = true
  datastore            = var.vsphere-datastore
  disk_controller_type = ["pvscsi"]
  folder               = var.vsphere-folder
  insecure_connection  = "true"
  
  network_adapters {
    network      = var.vsphere-network
    network_card = "vmxnet3"
  }
  
  notes        = "Build via Packer"
  password     = var.vsphere-password
  ssh_password = var.ssh-password
  ssh_username = var.ssh-username
  
  storage {
    disk_size             = var.vm-disk-size
    disk_thin_provisioned = true
  }
  
  username       = var.vsphere-user
  vcenter_server = var.vsphere-server
}
```
<!-- Command Section -->
Then perform the following commands on the root folder:
- `packer validate .` to lint the template
- `packer build .` to start the template creation

<!-- BEGINNING OF Packer DOCS -->
## Common Inputs
| Name | Description | Type | Default | Sensitive |
|------|-------------|------|---------|:--------:|
| vm-cpu-num | Number of VCPU used to build the template.| `string` | `2` | no |
| vm-mem-size | The Amount of Memory to builf the template. | `string` | `4096` | no |
| vm-disk-size | The Default Disk size when building the template. | `string` | `32768` | no |
| vsphere-server |  The DNS or IP address of the VSphere Server. | `string` | `192.168.2.10` | no |
| vsphere-user | The user name to use to authenticate against the vCenter Server. | `string` | `""` | yes |
| vsphere-cluster | The VSphere Cluster to Launch the template on. | `string` | `Flexpod` | no |
| vsphere-folder | The Folder in VCenter to store the template in. | `string` | `SAIT/Templates` | no |
| vsphere-network | The VLAN Network to launch the VM on to create the template. | `string` | `VM Network` | no |
| vsphere-password | The Password for authenticating against VSphere. | `string` | `""` | yes |
| ssh-password | The Password used by the provisioner to connect to the VM. | `string` | `""`| yes |
| ssh-username | The Username used by SSH to connect to the VM. | `string` | `""` | yes |
| vsphere-datastore | The DataStore to store the VMware Template on. | `string` | `datastore1` | no |

## Version Specific
| Name | Description | Type | Default | Sensitive |
|------|-------------|------|---------|:--------:|
| isoname-rhel7 | OS Major Version of RHEL 7. | `string` | `rhel-server-7.9-x86_64-dvd.iso` | no |
| isoname-rhel8 | OS Major Version of RHEL 8. | `string` | `rhel-8.4-x86_64-dvd.iso` | no |

## Other considerations within the file

RHEL Images are reused in Google Cloud.  To achieve this, we leverage the post-processing capabilities of Packer.  The following occurs after a successful build.

Export VMDK file to a local directory (Export)

Isolate VMDK file for upload to Google Cloud (based on OS)

Import to Google Cloud (based on OS)
  Important Inclusions
    os (subscription requirement)
    family (provisioning requirement)
    source (location of the local vmdk)


## Requirements
Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Packer and mkisofs are [installed](#software-dependencies) on the machine where apcker is executed.

2. The Service Account you execute the build with has the right [permissions](#configure-a-service-account).
### Software Dependencies
#### mkisofs
- [mkisofs](../../README.md) 1.1.x
#### Packer
- [Packer](https://www.packer.io/downloads) 1.7.0
### VCenter Service Account Requirements 
In order to execute this build you must have a Service Account with the
following VCenter permissions:
#### VM folder (this object and children):
- Virtual machine -> Inventory
- Virtual machine -> Configuration
- Virtual machine -> Interaction
- Virtual machine -> Snapshot management
- Virtual machine -> Provisioning
- vApp -> Export
#### Resource pool, host, or cluster (this object):
- Resource -> Assign virtual machine to resource pool
#### Host in clusters without DRS (this object):
- Read-only
#### Datastore (this object):
- Datastore -> Allocate space
- Datastore -> Browse datastore
- Datastore -> Low level file operations
#### Network (this object):
- Network -> Assign network
#### Distributed switch (this object):
- Read-only
#### Datacenter (this object):
- Datastore -> Low level file operations
#### Host (this object):
Host -> Configuration -> System Management


## Leveraging the VSphere Image for Google Cloud Image
Red Hat Cloud Access allows you to move eligible Red Hat product subscriptions to a Red Hat Certified Cloud or Service Provider (CCSP) and keep all the support and benefits your subscription provides. The terms of your subscription with Red Hat, including pricing, remain the same. Here speficially, it allows for the use of custom RHEL images that were hardened for use in the Private VMWare Cloud.

Benefits are:

* Upload images of Red Hat products to which you are subscribed to a CCSP
* Access your images through the applicable web console
* Maintain your pricing and support services with Red Hat directly

Packer is being leveraged to export and isolate the vmdk file after which a gcloud images import is run against that vmdk.  During this import the vmdk file is uploaded to a Google Storage bucket and then turned into a useable Google Compute Image as a member of a specific OS family. The Google guest environment is injected into the image as it is being turned into a valid Google Compute Image.

This approach allows for automation consistency.  As new images are built for the Rogers Private Cloud they can be consumed immediately at Rogers.  In a little over an hour, these same images can be consumed within Google Cloud.  No changes to Terraform code are required to consume new images in either cloud.

#### Terraform Provisioning Blackout Windows
There is a 15 minute window in Rogers as the existing template is rebuilt.
There is no blackout window for Google. Newer images are added to an OS family and the old image can be used until the instant the new one is available.

## Google Cloud Import Considerations

* Clean up
* Bucket Location
* Image Location
* Image use in other projects (roles/compute.imageUser)
* Account used for Image Import
* Guest Environment - install automatically during import
* Must upload the file to a Cloud Storage bucket in the same project that will be used for the import process

## Google Cloud Additional Information

### 

### Cost 
For custom images, your storage cost is based on the image's archive size.

### Helpful Links

[Importing Virtual Disks](https://cloud.google.com/compute/docs/import/importing-virtual-disks)

[gcloud compute images import](https://cloud.google.com/sdk/gcloud/reference/compute/images/import)

[Guest Envrionment Prep](https://cloud.google.com/compute/docs/images/guest-environment)

[Installing the Guest Environment](https://cloud.google.com/compute/docs/images/install-guest-environment)

[Using Images from Other Projects](https://cloud.google.com/deployment-manager/docs/configuration/using-images-from-other-projects-for-vm-instances)

[Custom Image Storage Costs](https://cloud.google.com/compute/disks-image-pricing)
