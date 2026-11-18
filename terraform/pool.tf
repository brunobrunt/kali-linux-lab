# HOST: syrus
# Kali AI Lab — dedicated libvirt storage pool.
# ELI10: Store Kali virtual disks separately from HavenBridge.

resource "libvirt_pool" "kali_ai" {
  name = "kali-ai-pool"
  type = "dir"

  target = {
    path = "/data_all/libvirt/kali-ai"

    permissions = {
      mode  = "0770"
      owner = "64055"
      group = "109"
    }
  }

  # ELI10: Prepare, activate, and automatically start the pool.
  create = {
    build     = true
    start     = true
    autostart = true
  }

  # ELI10: Do not automatically delete the pool's backing storage
  # when removing its libvirt definition.
  destroy = {
    delete = false
  }
}
