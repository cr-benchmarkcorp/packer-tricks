source "file" "basic-example" {
  content =  templatefile("${path.root}/kickstart/ks7.pkrtpl.hcl", { rhelusername = var.user-username, rhelpassword = var.user-password } )
  target =  "${path.root}/kickstart/ks7.cfg"
}

source "vsphere-iso" "base-rhel" {
  CPUs                 = var.vm-cpu-num
  RAM                  = var.vm-mem-size
  RAM_reserve_all      = false
  disk_controller_type = ["pvscsi"]
  cluster              = var.vsphere-cluster
  datastore            = var.vsphere-datastore
  folder               = var.vsphere-folder
  convert_to_template  = true

  network_adapters {
    network      = var.vsphere-network
    network_card = "vmxnet3"
  }

  storage {
    disk_size             = var.vm-disk-size
    disk_thin_provisioned = true
  }

  ssh_password = var.ssh-password
  ssh_username = var.ssh-username
  notes        = "Build via Packer-${timeadd(timestamp(), "-7h")}"

  vcenter_server      = var.vsphere-server
  username            = var.vsphere-user
  password            = var.vsphere-password
  insecure_connection = "true"

}

