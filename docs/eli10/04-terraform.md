# ELI10 Guide 04 — Terraform and KVM/libvirt

**Project:** Kali Linux Lab
**Host:** `syrus`
**Repository:** `brunobrunt/kali-linux-lab`
**Branch:** `feature/kali-ai-lab`
**Status:** Network provisioning verified — November 5, 2026

---

## 1. Learning Objective

Learn how Terraform manages infrastructure on a native KVM/libvirt hypervisor.

Our first exercise creates a dedicated virtual network for authorized Kali Linux cybersecurity training without modifying the existing HavenBridge infrastructure.

## 2. CRAFT Learning Framework

### C — Context

The host `syrus` already runs HavenBridge Kubernetes virtual machines and a separate Crafty Linux Performance Lab.

The Kali Linux Lab therefore requires its own Terraform configuration, state, network, and eventually dedicated VM storage.

### R — Role

Act as a senior Linux, KVM/libvirt, Terraform, Ansible, and cybersecurity mentor.

### A — Action

Initialize Terraform, validate the configuration, inspect the proposed changes, provision an isolated-mode libvirt network, and verify the results.

### F — Format and Evidence

Record exact host-labelled commands, actual outputs, configuration values, troubleshooting, and lessons learned.

### T — Tone

Use ELI10 explanations and proceed one verified step at a time.

---

## 3. What Is Terraform?

Terraform is an Infrastructure as Code (IaC) tool.

**ELI10:** Instead of manually creating each virtual network and VM, we write a blueprint describing the desired infrastructure.

Terraform compares that blueprint with its state and the infrastructure provider, then proposes the necessary changes.

The libvirt provider lets Terraform communicate with KVM/libvirt on `syrus`.

## 4. Terraform Project Files

| File | Purpose |
|---|---|
| `versions.tf` | Terraform requirements and provider configuration |
| `main.tf` | Resources Terraform should manage |
| `.terraform.lock.hcl` | Selected provider version and checksums |
| `terraform.tfstate` | Local Terraform state; never commit |
| `kali-network.tfplan` | Saved plan; never commit |

Provider: `dmacvicar/libvirt` version `0.9.8`.

Libvirt connection: `qemu:///system`.

## 5. Terraform Commands and Flags

All commands were executed on **HOST: `syrus`**.

| Command | ELI10 explanation |
|---|---|
| `terraform version` | Display installed Terraform version |
| `terraform fmt -check terraform/` | Check formatting without rewriting files |
| `terraform -chdir=terraform init -backend=false` | Initialize provider dependencies |
| `terraform -chdir=terraform validate` | Check Terraform configuration validity |
| `terraform -chdir=terraform plan -out=kali-network.tfplan` | Preview and save proposed infrastructure changes |
| `terraform -chdir=terraform apply kali-network.tfplan` | Apply the previously reviewed plan |
| `terraform -chdir=terraform state list` | List infrastructure managed in Terraform state |

### Important flags

- `-chdir=terraform`: Run as though the working directory is `terraform/`.
- `-check`: Verify formatting without modifying files.
- `-backend=false`: Skip backend initialization.
- `-out`: Save the calculated execution plan.
- `-c qemu:///system`: Tell `virsh` to connect to system-level libvirt.
- `--all`: Include inactive resources in a `virsh` listing.

## 6. Network Configuration

Terraform resource: `libvirt_network.kali_lab`.

| Property | Verified value |
|---|---|
| Network name | `kali-ai-net` |
| Subnet | `192.168.88.0/24` |
| Gateway | `192.168.88.1` |
| Bridge | `virbr88` |
| DHCP range | `192.168.88.100–192.168.88.199` |
| Autostart | Enabled |
| Persistent | Yes |
| Libvirt forwarding | No `<forward>` element |

The Terraform configuration omits the `forward` block.

This creates an isolated-mode libvirt network rather than a NAT network. Actual traffic isolation still requires testing.

## 7. Verified Implementation Results

### Terraform initialization

Terraform installed the pinned `dmacvicar/libvirt v0.9.8` provider and generated `.terraform.lock.hcl`.

Result: **PASS**.

### Configuration validation

`terraform validate` reported that the configuration is valid.

Result: **PASS**.

### Terraform plan

Terraform proposed:

`Plan: 1 to add, 0 to change, 0 to destroy.`

Resource: `libvirt_network.kali_lab`.

Result: **PASS**.

### Terraform apply

Terraform reported:

`Apply complete! Resources: 1 added, 0 changed, 0 destroyed.`

Created resource UUID:

`b52f5cc0-dd64-4e97-a1b4-7636e8e9b027`

Result: **PASS**.

### Libvirt verification

`virsh net-info kali-ai-net` confirmed:

- Active: Yes
- Persistent: Yes
- Autostart: Yes
- Bridge: `virbr88`

The libvirt XML confirmed the gateway and DHCP range with no forwarding element.

Result: **PASS**.

### Bridge verification

The bridge had `192.168.88.1/24` assigned.

The interface reported `NO-CARRIER` and operational `state DOWN`, while administratively `UP`.

This can occur when no guest interfaces are connected. Guest connectivity has not yet been tested.

## 8. Terraform State and Git Safety

Verified Terraform state:

`libvirt_network.kali_lab`

Git correctly ignores:

- `terraform.tfstate`
- `*.tfplan`
- `.terraform/`

Git detects these project files for version control:

- `terraform/main.tf`
- `terraform/versions.tf`
- `terraform/.terraform.lock.hcl`

**Important:** Terraform state can contain sensitive data and must not be committed to GitHub.

## 9. Current Limitations

- No Kali VM has been provisioned.
- No guest-to-guest network tests have been performed.
- No host firewall isolation testing has been performed.
- Terraform CI checks have not yet been added to GitHub Actions.
- Network isolation is not yet fully verified.

## 10. Lessons Learned

1. Terraform configuration describes desired infrastructure.
2. `terraform init` prepares providers.
3. `terraform validate` checks the configuration.
4. `terraform plan` previews changes.
5. `terraform apply` provisions the reviewed resources.
6. Terraform state tracks managed infrastructure.
7. A dedicated subnet does not prove security isolation.
8. The existing HavenBridge infrastructure must remain outside Kali's Terraform state.

## 11. Next Activity

Add Terraform validation to Kali Lab CI.

Then verify the GitHub Actions results before beginning Kali VM provisioning.

Continue documenting actual outcomes in this guide and the root `README.md`.
