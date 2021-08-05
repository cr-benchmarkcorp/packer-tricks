build {
  name    = "buildcfg"
  sources = ["sources.file.basic-example"]
}

build {
  name        = "rhel"
  description = <<EOF
//This build creates images for the following versions :
* RHEL 7
* RHEL 8
For the following builders :
* vsphere-iso
EOF

  /*source "source.vsphere-iso.base-rhel" {
    name                 = "8"
    boot_command         = ["<tab><wait>", " inst.text inst.ks=cdrom:/dev/sr1:/ks8.cfg<enter>"]
    cd_files             = ["${path.root}/kickstart/ks8.cfg"]
    #cd_files             = ["kickstart/KickStart-RHEL8.cfg"]
    guest_os_type        = "rhel8_64Guest"
    iso_paths            = ["[${var.vsphere-datastore}] isos/${var.isoname-rhel8}"]
    vm_name              = var.rhel8-template-name
  }
  */


  source "source.vsphere-iso.base-rhel" {
    name          = "7"
    cd_files     =["${path.root}/kickstart/ks7.cfg"]
    boot_command  = ["<tab><wait>", " inst.text inst.ks=cdrom:/ks7.cfg<enter>"]
    guest_os_type = "rhel7_64Guest"
    iso_paths     = ["[${var.vsphere-datastore}] isos/${var.isoname-rhel7}"]
    vm_name       = var.rhel7-template-name
  }

}
