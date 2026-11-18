# Kali Linux VM Provisioning — ELI10 Guide

## 1. Purpose

Provision a standalone Kali Linux AI and cybersecurity training environment on `syrus` using native KVM/libvirt.

Terraform manages infrastructure, while Ansible will configure the Kali guest.

The Kali lab must remain separate from the existing HavenBridge Kubernetes and Crafty Performance Lab environments.

## 2. Verified storage prerequisites

**Host:** `syrus`

- Physical storage mount: `/data_all`
- Libvirt storage parent: `/data_all/libvirt`
- QEMU user: `libvirt-qemu`
- QEMU UID: `64055`
- QEMU group: `kvm`
- KVM GID: `109`
- Existing VM storage permissions: `0770`

## 3. Terraform storage pool

**Terraform resource:** `libvirt_pool.kali_ai`

**Configuration file:** `terraform/pool.tf`

| Setting | Value |
|---|---|
| Pool name | `kali-ai-pool` |
| Pool type | `dir` |
| Target path | `/data_all/libvirt/kali-ai` |
| Permissions | `0770` |
| Owner UID | `64055` |
| Group GID | `109` |
| Autostart | Enabled |
| Persistent | Yes |

### ELI10 — What is a storage pool?

A storage pool is a libvirt-managed location where VM disk volumes are stored.

The Kali pool has its own directory, keeping its VM disks organized separately from HavenBridge.

A separate pool directory is not the same as a separate physical disk or a security isolation boundary.

## 4. Provisioning commands

### Inspect existing infrastructure

**HOST: `syrus`**

```bash
virsh -c qemu:///system pool-list --all
virsh -c qemu:///system pool-dumpxml eph-k8s
terraform -chdir=terraform state list
```

### Validate Terraform

**HOST: `syrus`**

```bash
terraform -chdir=terraform fmt
terraform -chdir=terraform validate
```

**Observed result:** Terraform reported that the configuration was valid.

### Generate a saved plan

**HOST: `syrus`**

```bash
terraform -chdir=terraform plan \
  -out=kali-storage.tfplan
```

**Observed result:**

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### Apply the reviewed plan

**HOST: `syrus`**

```bash
terraform -chdir=terraform apply kali-storage.tfplan
```

**Outcome:** The resulting storage pool was verified through libvirt and Terraform state.

The exact Terraform apply summary was not captured in this guide.

## 5. Post-provisioning verification

**HOST: `syrus`**

```bash
virsh -c qemu:///system pool-info kali-ai-pool

virsh -c qemu:///system pool-dumpxml kali-ai-pool

stat -c '%A %a %U:%G %n' \
  /data_all/libvirt/kali-ai

terraform -chdir=terraform state list
```

### Verified results

- Pool name: `kali-ai-pool`
- UUID: `b98af32b-be57-4f5d-8043-ebea380faf45`
- State: Running
- Persistent: Yes
- Autostart: Yes
- Directory: `/data_all/libvirt/kali-ai`
- Permissions: `770`
- Ownership: `libvirt-qemu:kvm`
- Available backing filesystem capacity: 1.58 TiB

Terraform state:

```text
libvirt_network.kali_lab
libvirt_pool.kali_ai
```

## 6. Troubleshooting and lessons learned

**Observation:** Before provisioning, `virsh pool-info kali-ai-pool` returned a storage-pool-not-found error.

**Explanation:** The pool had not been created yet. This was an expected discovery result, not a libvirt failure.

**Lesson:** Always inspect existing libvirt resources and Terraform state before provisioning.

**Lesson:** Review the Terraform plan before applying it. For this change, the plan proposed one new resource and no changes or deletions.

**Lesson:** A running, persistent storage pool with the correct filesystem permissions does not yet prove that a VM can boot from a volume stored inside it.

## 7. Kali Linux VM and Disk Provisioning

**HOST:** `syrus`
**Status:** Provisioned; graphical console and SSH access verified.

### 7.1 Purpose

Provision a dedicated Kali Linux security training VM using Terraform and native KVM/libvirt without modifying the existing HavenBridge Kubernetes or Crafty Performance Lab infrastructure.

Terraform manages the virtual machine, storage and network resources. Ansible will manage guest operating system configuration in a later phase.

### 7.2 Verified Terraform Resources

```text
libvirt_domain.kali_ai
libvirt_network.kali_lab
libvirt_pool.kali_ai
libvirt_volume.kali_ai_disk
```

**ELI10:**

- `libvirt_domain.kali_ai` represents the Kali virtual machine.
- `libvirt_network.kali_lab` represents the dedicated virtual network.
- `libvirt_pool.kali_ai` represents the virtual disk storage location.
- `libvirt_volume.kali_ai_disk` represents Kali's virtual disk.

All four resources were observed in Terraform state.

### 7.3 VM Configuration

| Setting | Configured value |
|---|---|
| VM name | `kali-ai` |
| Operating system | Kali Linux 2026.3 |
| Hypervisor | KVM/libvirt |
| CPU | 2 vCPUs |
| Memory | 6 GiB |
| Virtual motherboard | Q35 |
| Virtual disk | QCOW2, approximately 80.09 GiB |
| Disk path | `/data_all/libvirt/kali-ai/kali-ai.qcow2` |
| Disk interface | VirtIO (`vda`) |
| Network | `kali-ai-net` |
| Network subnet | `192.168.88.0/24` |
| Virtual network bridge | `virbr88` |
| Graphics | SPICE listening on `127.0.0.1` |
| Virtual video adapter | VirtIO |
| Terraform VM file | `terraform/vm.tf` |
| Terraform volume file | `terraform/volume.tf` |

**ELI10:** A VM is a software-defined computer. Terraform describes its virtual CPU, RAM, hard disk, network adapter and display. Libvirt manages that virtual hardware.

### 7.4 Kali Image and Storage

The official Kali Linux 2026.3 QEMU AMD64 image was downloaded and its integrity and authenticity were checked during provisioning.

The source image is located at:

```text
/data_all/kali-downloads/extracted/kali-linux-2026.3-qemu-amd64.qcow2
```

Terraform manages the destination volume:

```text
/data_all/libvirt/kali-ai/kali-ai.qcow2
```

**ELI10:** The downloaded image is the starting disk image. The destination QCOW2 file is the VM's managed virtual hard disk. QCOW2 supports virtual disk features such as copy-on-write storage.

Do not replace the running VM's disk with the original downloaded image.

### 7.5 Graphical Console Verification

The Kali guest was successfully booted into its graphical environment.

Verified observations:

- SPICE graphics configured with loopback-only listening on `127.0.0.1`.
- VirtIO virtual video device configured.
- Kali graphical login screen displayed through virt-manager.
- Kali XFCE desktop login succeeded.

**ELI10:** SPICE allows a graphical console application on `syrus` to display the VM's screen. The VirtIO video adapter provides the virtual graphics device.

### 7.6 SSH Configuration and Verification

A guest administrator account named `mino` was configured, and sudo access was tested.

A dedicated SSH key was created on `syrus`:

```text
~/.ssh/kali_ai
~/.ssh/kali_ai.pub
```

The public key was installed for the `mino` account on Kali.

The SSH configuration on `syrus` includes an alias for `kali-ai`, using the dedicated private key.

**HOST: `syrus`**

```bash
# PURPOSE: Verify Kali identity through the SSH alias.
# SAFETY: Read-only remote commands.

ssh \
  -o BatchMode=yes \
  -o ConnectTimeout=5 \
  kali-ai \
  'whoami && hostname'
```

**ELI10:**

- `ssh` opens a secure remote connection.
- `BatchMode=yes` prevents interactive password prompts.
- `ConnectTimeout=5` limits connection setup to five seconds.
- `kali-ai` is the alias in `~/.ssh/config`.
- `whoami` displays the authenticated account.
- `&&` runs the next command only if the previous command succeeds.
- `hostname` displays the destination computer's hostname.

**Verified output:**

```text
mino
kali-ai
```

The current Kali IP address is `192.168.88.185`, assigned using DHCP. A stable address or DHCP reservation remains pending.

### 7.7 Eight-Node SSH Alias Verification

The following aliases were tested successfully from `syrus`:

| SSH alias | IP address |
|---|---|
| `eph-cp01` | `172.16.10.31` |
| `eph-cp02` | `172.16.10.32` |
| `eph-cp03` | `172.16.10.33` |
| `eph-worker01` | `172.16.10.34` |
| `eph-worker02` | `172.16.10.35` |
| `havenbridge-runner01` | `172.16.10.37` |
| `crafty-perf-01` | `192.168.77.10` |
| `kali-ai` | `192.168.88.185` |

**Result:** PASS — All eight aliases returned `mino` and the expected remote hostname.

The existing GitHub SSH configuration was preserved. Private SSH keys remain outside the Git repository.

## 8. Troubleshooting and Lessons Learned

### 8.1 Kali Disk Boot Failure

**Symptom:** Kali initially failed to boot because QEMU could not access or correctly open its disk.

**Investigation:**

- Inspected filesystem ownership and permissions.
- Investigated AppArmor access restrictions.
- Added narrowly scoped AppArmor helper rules for the Kali disk directory and QCOW2 files.
- Examined the libvirt disk configuration and its storage source.
- Updated the VM definition to use an explicit file-based disk source and QCOW2 driver format.

**Verified outcome:** Kali subsequently booted successfully.

**Important limitation:** Several settings were investigated or adjusted during recovery. We cannot conclusively attribute the fix to one individual change.

**ELI10:** The VM needs permission to open its disk, and the hypervisor needs to know the correct disk format. A disk file existing on the host does not guarantee the VM can boot from it.

### 8.2 SPICE and VirtIO Graphics

**Symptom:** The initial VM configuration required additional graphics configuration to provide a usable graphical console.

**Correction:** Added a SPICE graphics device and VirtIO video adapter in the Terraform VM configuration.

**Verified outcome:** The Kali graphical login screen and XFCE desktop were accessible.

### 8.3 Terraform Desired Power State

The Terraform configuration currently contains:

```hcl
running   = false
autostart = false
```

The Kali VM was separately observed running through libvirt.

**ELI10:** Terraform configuration represents the desired state, while libvirt reports the actual VM state. A future Terraform plan may propose changes when these differ.

**Safety requirement:** Review the Terraform plan before applying changes. Do not assume a plan is harmless simply because the VM already exists.

### 8.4 Network Isolation Is Not Yet Fully Verified

Kali is connected to its dedicated `kali-ai-net` network, and the libvirt network has no configured forwarding mode.

However, complete isolation from the HavenBridge network, home network and other training environments has not yet been established through comprehensive tests.

**Security requirement:** Do not begin scanning or penetration-testing activities against other networks or systems until lab isolation and authorization are confirmed.

## 9. Remaining Work

- Review Kali's Terraform configuration against the live libvirt VM.
- Resolve the DHCP address stability requirement.
- Complete practical network isolation tests.
- Configure Kali with Ansible.
- Create deliberately vulnerable, isolated training targets.
- Document authorized security exercises, screenshots, outcomes and lessons learned.
- Validate Git and CI checks before merging the feature branch.

**Overall status:** Kali VM provisioning, graphical access and SSH access verified. Ansible configuration and complete network isolation testing remain pending.
