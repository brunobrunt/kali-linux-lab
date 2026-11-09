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

## 7. Next steps

- Select the official Kali Linux QEMU/KVM image.
- Verify the image checksum and provenance.
- Provision the Kali VM and its disk with Terraform.
- Configure the guest using Ansible.
- Verify guest networking and test isolation from HavenBridge.
- Capture screenshots, troubleshooting evidence, and lessons learned.

**Status:** Storage pool provisioning verified; Kali VM provisioning pending.
