# HOST: syrus
# Kali Linux AI Lab — Terraform-managed virtual disk.
#
# ELI10: Import a copy of the verified official Kali image
# into our dedicated storage pool.

resource "libvirt_volume" "kali_ai_disk" {
  name = "kali-ai.qcow2"
  pool = libvirt_pool.kali_ai.name

  # ELI10: Tell libvirt that this is a QCOW2 virtual disk.
  target = {
    format = {
      type = "qcow2"
    }
  }

  # ELI10: Import image contents from a local file on syrus.
  create = {
    content = {
      url = "/data_all/kali-downloads/extracted/kali-linux-2026.3-qemu-amd64.qcow2"
    }
  }
}
