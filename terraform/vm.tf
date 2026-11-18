
# ============================================================
# Kali Linux AI Lab
# Managed by Terraform on syrus.
#
# ELI10:
# Define our Kali Linux virtual machine using:
# - 2 virtual CPUs
# - 6 GiB RAM
# - Our existing 80.09 GiB QCOW2 disk
# - The dedicated kali-ai-net network
# - A local-only SPICE graphical display
#
# Terraform describes the VM.
# Libvirt creates and manages the virtual hardware.
#
# IMPORTANT:
# Keep HavenBridge and Crafty infrastructure unchanged.
# ============================================================

resource "libvirt_domain" "kali_ai" {

  # ==========================================================
  # VM NAME AND HYPERVISOR
  # ==========================================================
  #
  # ELI10:
  # name identifies our virtual machine.
  # type = "kvm" uses hardware-assisted virtualization.

  name = "kali-ai"
  type = "kvm"

  # ==========================================================
  # CPU AND MEMORY
  # ==========================================================
  #
  # ELI10:
  # Give Kali 6 GiB of RAM and 2 virtual CPUs.
  # These resources support Kali's graphical desktop
  # and our future security training tools.

  memory      = 6
  memory_unit = "GiB"
  vcpu        = 2

  # ==========================================================
  # POWER MANAGEMENT
  # ==========================================================
  #
  # ELI10:
  # Keep autostart disabled while the lab is being tested.
  # running = false declares the VM's desired power state
  # as stopped after Terraform manages its configuration.
  #
  # We will start Kali manually after verifying the changes.

  running   = false
  autostart = false

  # ==========================================================
  # OPERATING SYSTEM AND BOOT
  # ==========================================================
  #
  # ELI10:
  # hvm means hardware-assisted virtualization.
  # x86_64 matches the Kali image architecture.
  # q35 provides a modern virtual motherboard.
  # hd tells the VM to boot from its virtual hard disk.

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"

    boot_devices = [
      {
        dev = "hd"
      }
    ]
  }

  # ==========================================================
  # VIRTUAL HARDWARE
  # ==========================================================
  #
  # ELI10:
  # This section defines the virtual devices connected
  # to Kali, similar to hardware inside a physical PC.

  devices = {

    # --------------------------------------------------------
    # VIRTUAL DISK
    # --------------------------------------------------------
    #
    # ELI10:
    # Attach the existing Kali QCOW2 image.
    # We are NOT creating a second disk.
    #
    # Explicitly specifying qcow2 prevents QEMU from
    # treating our disk as a raw-format image.
    #
    # VirtIO provides efficient virtual disk access.

    disks = [
      {
        device = "disk"

        driver = {
          name = "qemu"
          type = "qcow2"
        }

        source = {
          file = {
            file = "/data_all/libvirt/kali-ai/kali-ai.qcow2"
          }
        }

        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]

    # --------------------------------------------------------
    # VIRTUAL NETWORK
    # --------------------------------------------------------
    #
    # ELI10:
    # Connect Kali only to our dedicated lab network.
    #
    # Network: kali-ai-net
    # Subnet:  192.168.88.0/24
    # Bridge:  virbr88
    #
    # The network has no configured libvirt forwarding.
    # Actual isolation must still be tested.
    #
    # VirtIO provides an efficient virtual network adapter.

    interfaces = [
      {
        source = {
          network = {
            network = libvirt_network.kali_lab.name
          }
        }

        model = {
          type = "virtio"
        }
      }
    ]

    # --------------------------------------------------------
    # SPICE GRAPHICAL DISPLAY
    # --------------------------------------------------------
    #
    # ELI10:
    # SPICE acts like a virtual monitor connection.
    #
    # Without a graphics device, the VM can run but
    # we cannot see its graphical login screen.
    #
    # auto_port tells libvirt to select an available port.
    #
    # 127.0.0.1 means only local applications on syrus
    # can connect directly to the SPICE server.
    #
    # We can use virt-manager to open Kali's console.

    graphics = [
      {
        spice = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      }
    ]
    # --------------------------------------------------------
    # VIRTUAL VIDEO CARD
    # --------------------------------------------------------
    #
    # ELI10:
    # SPICE provides a way to view the display.
    # The virtual video card produces that display.
    #
    # type = "virtio" selects a virtual graphics adapter.
    # heads = 1 configures one virtual monitor.
    # primary = "yes" makes it the main display.
    #
    # We explicitly specify heads and primary to avoid
    # a known provider v0.9.8 state consistency issue.

    videos = [
      {
        model = {
          type    = "virtio"
          heads   = 1
          primary = "yes"
        }
      }
    ]
  }

  # ==========================================================
  # TERRAFORM DEPENDENCIES
  # ==========================================================
  #
  # ELI10:
  # This VM depends on our existing Kali disk volume.
  #
  # Terraform must manage the volume before the VM.
  #
  # This dependency does not create another disk.

  depends_on = [
    libvirt_volume.kali_ai_disk
  ]
}
