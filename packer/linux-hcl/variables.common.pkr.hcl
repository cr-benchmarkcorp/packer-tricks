variable "vm-cpu-num" {
  type    = string
  default = "2"
}

variable "vm-mem-size" {
  type    = string
  default = "4096"
}

variable "vm-disk-size" {
  type    = string
  default = "86016"
}

variable "vsphere-server" {
  type    = string
  default = "192.168.2.10"
}

variable "vsphere-user" {
  type      = string
  default   = "Administrator@vsphere.local"
  sensitive = true
}

variable "vsphere-cluster" {
  type    = string
  default = "Flexpod"
}

variable "vsphere-folder" {
  type    = string
  default = "SAIT VMs/Templates"
}

variable "vsphere-network" {
  type    = string
  default = "VM Network"
}

variable "vsphere-password" {
  type      = string
  default   = "Sammut99*"
  sensitive = true
}

variable "ssh-password" {
  type      = string
  default   = "Sammut99*!"
  sensitive = true
}

variable "ssh-username" {
  type      = string
  default   = "root"
  sensitive = true
}

variable "vsphere-datastore" {
  type    = string
  default = "datastore1"
}

variable "user-password" {
  type      = string
  default   = "RedHat121!"
}

variable "user-username" {
  type      = string
  default   = "chadwickdevops@gmail.com"
}