# Kali Linux Lab — Terraform requirements.
# ELI10: Specify which Terraform and libvirt provider versions we use.
# versions.tf — Which Terraform tools and provider do we need?

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "= 0.9.8"
    }
  }
}

# ELI10: Connect to the system-wide KVM/libvirt service on syrus.
provider "libvirt" {
  uri = "qemu:///system"
}
