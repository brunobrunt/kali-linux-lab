
# Kali Linux Lab — dedicated isolated training network.
# HOST: syrus
# ELI10: Keep Kali training VMs on a separate virtual network.
# main.tf — What infrastructure should Terraform create?


resource "libvirt_network" "kali_lab" {
  name      = "kali-ai-net"
  autostart = true

  # ELI10: Create a dedicated virtual switch for our Kali lab.
  bridge = {
    name = "virbr88"
  }

  # ELI10: No forward block means no libvirt NAT or routed
  # forwarding is requested for this network.
  # Actual isolation must still be tested.

  ips = [
    {
      address = "192.168.88.1"
      netmask = "255.255.255.0"

      # ELI10: Automatically assign addresses to lab VMs.
      dhcp = {
        ranges = [
          {
            start = "192.168.88.100"
            end   = "192.168.88.199"
          }
        ]
      }
    }
  ]
}
