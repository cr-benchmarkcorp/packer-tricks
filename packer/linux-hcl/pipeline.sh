#!/bin/bash
packer build -only='buildcfg.file.basic-example' .
packer build -only='rhel.vsphere-iso.7' .