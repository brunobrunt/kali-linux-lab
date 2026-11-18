
# Kali Linux Lab — Infrastructure Automation and Cybersecurity

> Independent repository: `brunobrunt/kali-linux-lab`
> Status: Standalone Git repository initialized; Phase 1 host/network assessment documented
> Environment: On-premises KVM/libvirt homelab

## 1. Project Overview

Kali Linux Lab is an independent security learning environment built using
Terraform, KVM/libvirt, Ansible, Linux, and selected security tools.

The purpose is to learn infrastructure automation, reconnaissance,
authorized penetration testing, vulnerability assessment, security
hardening, and eventually AI-assisted incident analysis.

The lab will be kept separate from the HavenBridge Kubernetes infrastructure.
Network isolation is planned but not yet verified.

## 2. Learning Objectives

- Provision Kali Linux using Terraform and libvirt.
- Understand VM images, storage, networking, and cloud-init.
- Configure Linux systems consistently using Ansible.
- Learn basic Linux security and networking commands.
- Practice authorized reconnaissance and vulnerability assessment.
- Document evidence, findings, remediation, and lessons learned.
- Explore read-only AI-assisted security reporting.

## 3. CRAFT Documentation Method

| Element | Meaning | Application |
|---|---|---|
| C — Context | What and why | Explain the goal of each activity |
| R — Role | Mentor expertise | Senior Linux, KVM/libvirt, Terraform, Ansible and cybersecurity mentor |
| A — Action | What we do | Show exact commands and configurations |
| F — Format | How we document | ELI10 explanations, outputs, diagrams, screenshots |
| T — Tone | How we explain | Clear, beginner-friendly, technically accurate |

Every completed phase will include:
1. Objective
2. Architecture or workflow
3. Prerequisites
4. Host-labelled commands and flag explanations
5. Expected and actual results
6. Screenshot evidence where useful
7. Troubleshooting and lessons learned
8. Git commit and PR reference

## 4. Planned Architecture

```text
syrus (Ubuntu 24.04 LTS)
│
├── KVM / libvirt
│   │
│   └── Dedicated Kali-AI lab network
│       │
│       ├── kali-ai VM
│       │   ├── Kali Linux
│       │   ├── Security tools
│       │   └── Ansible-managed configuration
│       │
│       └── Authorized training targets (future)
│
├── Terraform
│   └── VM, network, and storage provisioning
│
└── Ansible
    └── System configuration and validation
```

Network ranges, VM resources, disk paths, and image details will
be finalized after inspecting the current libvirt environment.

## 5. Safety and Scope

Security testing is restricted to personally owned systems,
deliberately provisioned training targets, or systems for which
explicit authorization has been granted.

The lab must not disrupt HavenBridge workloads.

Initial reconnaissance will use lab targets only.

## 6. Phase Roadmap

| Phase | Description | Status |
|---|---|---|
| 0 | Establish standalone repository and migrate README | In progress |
| 1 | Inspect host and download verified Kali image | Planned |
| 2 | Provision network, storage, and VM using Terraform | Planned |
| 3 | Configure Kali using Ansible | Planned |
| 4 | Validate isolation and security baseline | Planned |
| 5 | Learn reconnaissance and network discovery | Planned |
| 6 | Practice authorized vulnerability assessment | Planned |
| 7 | Build AI-assisted reporting workflow | Planned |

## 7. Phase 0 — Standalone Repository Foundation

### C — Context

The Kali lab began as a Git worktree of the HavenBridge repository. It is now
being migrated to its own repository so cybersecurity learning, infrastructure
code, and CI can evolve independently. HavenBridge remains out of scope for
unauthorized security testing.

### R — Role

Act as a senior Linux, KVM/libvirt, Terraform, Ansible, and cybersecurity mentor.
The lab engineer executes and verifies the steps. Commands explicitly identify
the host: Terraform, Ansible, and libvirt run on `syrus`; `kubectl` for the
separate HavenBridge Kubernetes cluster runs on `eph-cp01`, not `syrus`.

### A — Action

Observed steps so far:

1. Created and pushed `feature/kali-ai-lab` in the HavenBridge repository.
2. Documented initial Kali lab plans and host/network assessment.
3. Created independent GitHub repository `brunobrunt/kali-linux-lab`.
4. Copied the lab README to `/home/alabi/projects/kali-linux-lab/README.md`.
5. Verified the source and destination README SHA256 checksums matched.
6. Initialized the new local repository with `git init -b main`.

The independent repository has not yet received its initial commit or push.
The original HavenBridge Kali worktree and draft PR #2 remain in place until
migration and verification are complete.

### F — Format and Evidence

Record the exact commands, host names, outputs, verification results,
architecture diagrams, screenshots where useful, and Git commit/PR links.
Distinguish completed checks from proposed configurations.

Verified migration checkpoint: both README files had checksum
`b7885805c18f62fcae44f0b177966165c078065297c83bd2a891ea07cc76c63f`
when first copied, before standalone edits.

### T — Tone and ELI10

Use clear, beginner-friendly explanations without overstating outcomes.
A Git worktree is another working folder linked to the same repository;
a standalone repository owns its own Git history and remote.


### GitHub Branch Protection — Verified November 4, 2026

The standalone Kali Linux Lab repository protects `main` using GitHub ruleset `26572578` (`Protect main — Kali Linux Lab`).

Verified requirements:

- Pull request required before merging.
- Required CI checks: `Documentation Validation` and `Terraform Validation`.
- Branch must be up to date before merging.
- Review conversations must be resolved.
- Force pushes and branch deletion are restricted.
- Required approving reviews: 0 (solo learning repository).

**Verification:** GitHub CLI inspection confirmed that the ruleset targets `refs/heads/main` and has `enforcement: active`.

**Scope:** This protects the repository workflow. It does not validate Terraform, Ansible, or network isolation; those checks are still planned.


## 8. Phase 1 — Infrastructure and Network Assessment

### C — Context

Before provisioning Kali Linux, inspect the KVM host and existing networks.

The objective is to prevent resource conflicts and protect HavenBridge workloads.

### R — Role

- Host: `syrus`
- Hypervisor: native KVM/libvirt
- Infrastructure provisioning: Terraform
- System configuration: Ansible
- Kubernetes administration: `eph-cp01`, not `syrus`

### A — Action

Inspect and verify host resources, routes, libvirt networks, and storage
before provisioning any Kali resources.

### F — Format and Evidence

Maintain host-labelled commands, observed results, planned choices, and
verification status in this README.

### T — Tone and ELI10 Explanation

Explain each flag and concept in simple language; a separate subnet is not
by itself proof of network isolation.

### Verified host resources

| Resource | Observed result |
|---|---|
| Logical CPUs | 12 |
| Total memory | 125 GiB |
| Available memory | 84 GiB |
| Available disk space on `/data_all` | 1.5 TB |
| Libvirt version | 10.0.0 |
| Terraform version | 1.16.1 |
| Running virtual machines | 7 |

### Existing network assessment

| Network | IPv4 subnet | Status |
|---|---|---|
| Home network | 10.0.0.0/24 | Active |
| HavenBridge | 172.16.10.0/24 | Active |
| Crafty performance lab | 192.168.77.0/24 | Active |
| Docker | 172.17.0.0/16 | Link down |
| Existing br0 bridge | 192.168.1.0/24 | Link down |

### Kali-AI network design

Proposed network:

- Name: `kali-ai-net`
- Subnet: `192.168.88.0/24`
- Gateway: `192.168.88.1`
- Bridge: `virbr88`
- DHCP range: `192.168.88.100–192.168.88.199`
- Forwarding: none initially (isolated network)

No overlapping network was found in the displayed host routes or
existing libvirt networks.

Network isolation and host firewall behavior have not yet been tested.

### Proposed Kali VM resources

| Resource | Planned value |
|---|---|
| VM name | kali-ai |
| vCPU | 2 |
| Memory | 4 GiB |
| Disk | 60 GiB |
| Network | kali-ai-net |
| Provisioning | Terraform |
| Configuration | Ansible |

### Verification commands

```bash
# HOST: syrus
nproc
free -h
df -h /data_all
ip -4 route show
ip -br addr show
virsh -c qemu:///system net-list --all
virsh -c qemu:///system pool-list --all
virsh -c qemu:///system list --all
terraform version
```

### ELI10 lessons learned

- A subnet is a logical address range for devices.
- A virtual bridge connects virtual machines to a virtual network.
- NAT provides translated outbound connectivity; it does not guarantee isolation.
- A dedicated subnet helps organize the lab but must be combined with appropriate network controls.
- Terraform manages infrastructure resources, while Ansible configures operating systems.

### Validation status

- Host resource assessment: PASS
- Existing libvirt network inspection: PASS
- Proposed subnet overlap check: PASS for observed routes
- Kali network creation: NOT STARTED
- Firewall/isolation testing: NOT STARTED
- Kali image integrity verification: NOT STARTED

### Next activity

Select and download the official Kali Linux QEMU image, verify its
authenticity and integrity, and inspect its suitability for automated provisioning.


### Phase 2 — Terraform Network Provisioning

**Status:** Network created and libvirt configuration verified — November 5, 2026.

**Execution host:** `syrus`
**Provisioning:** Terraform v1.16.1 with `dmacvicar/libvirt` v0.9.8.

#### Verified network configuration

| Property | Value |
|---|---|
| Network | `kali-ai-net` |
| Subnet | `192.168.88.0/24` |
| Gateway | `192.168.88.1` |
| Bridge | `virbr88` |
| DHCP | `192.168.88.100–199` |
| Autostart | Enabled |
| Persistent | Yes |
| Libvirt forwarding | No forwarding element |

#### Implementation results

- `terraform init`: Successful.
- `terraform validate`: Successful.
- `terraform plan`: 1 to add, 0 to change, 0 to destroy.
- `terraform apply`: 1 added, 0 changed, 0 destroyed.
- `virsh net-info`: Network active, persistent and set to autostart.
- `virsh net-dumpxml`: Bridge, gateway and DHCP configuration verified.
- `terraform state list`: `libvirt_network.kali_lab`.
- Git state and saved plan exclusions: Verified.

**Security limitation:** Guest isolation and host firewall behaviour have not yet been tested. Network creation does not establish that security testing is safe.

**ELI10 documentation:** [Guide 04 — Terraform and KVM/libvirt](docs/eli10/04-terraform.md).

## 9. Evidence

Screenshots and diagrams will be stored under:

- `assets/screenshots/`
- `assets/diagrams/`

Only verified evidence will be labelled as completed.

## 10. Git Workflow

After the initial standalone `main` commit and push, create a task feature
branch, open a draft pull request, and require passing relevant CI checks
before merging into protected `main`. Do not push ongoing development
directly to `main`. Branch protection and Kali-specific CI remain to be configured.

## Phase 3 — Kali Linux VM and Storage Provisioning

**Status:** In progress

### Objective

Provision a dedicated Kali Linux virtual machine using Terraform and native KVM/libvirt on `syrus`, while preserving the existing HavenBridge Kubernetes and Crafty Performance Lab environments.

### Completed — Storage provisioning

- Created Terraform-managed storage pool: `kali-ai-pool`.
- Storage directory: `/data_all/libvirt/kali-ai`.
- Pool type: directory (`dir`).
- Ownership: `libvirt-qemu:kvm`.
- Permissions: `0770`.
- Pool is running, persistent, and configured for autostart.
- Verified the pool using `virsh`, filesystem permissions, and Terraform state.

**Storage clarification:** The reported 1.58 TiB available is shared free capacity on `/data_all`. It is not reserved exclusively for Kali.

### Planned — Kali virtual machine

- VM name: `kali-ai`.
- CPU: 2 vCPUs.
- Memory: 4 GiB RAM.
- Virtual disk: 60 GiB (not yet created).
- Network: `kali-ai-net` (`192.168.88.0/24`).
- Provisioning: Terraform.
- Guest configuration: Ansible.

### Documentation

See [Kali VM Provisioning — ELI10 Guide](docs/eli10/05-kali-vm-provisioning.md).

### Next steps

1. Download the official Kali Linux QEMU/KVM image.
2. Verify the image's SHA256 checksum.
3. Provision the Kali VM using Terraform.
4. Configure the guest using Ansible.
5. Test network isolation from HavenBridge before security exercises.

**Important:** The Kali VM has been provisioned using Terraform and successfully accessed through its graphical console and SSH. Complete network isolation has not yet been verified. Security testing against training targets must remain on hold until isolation checks pass.


## Kali-AI Lab — SSH Configuration and Verification

**Host:** `syrus`
**Configuration:** `/home/alabi/.ssh/config`
**Result:** PASS — 8 of 8 VM SSH aliases verified.

### Purpose

Configure SSH hostname aliases for the HavenBridge Kubernetes nodes, Crafty Performance Lab VM, and Kali-AI VM.

This allows administrators to connect using `ssh kali-ai` instead of remembering IP addresses, SSH usernames and private-key paths.

### Verified SSH Inventory

| VM | IP address | Username | Private key |
|---|---|---|---|
| eph-cp01 | 172.16.10.31 | mino | `~/.ssh/eph_k8s` |
| eph-cp02 | 172.16.10.32 | mino | `~/.ssh/eph_k8s` |
| eph-cp03 | 172.16.10.33 | mino | `~/.ssh/eph_k8s` |
| eph-worker01 | 172.16.10.34 | mino | `~/.ssh/eph_k8s` |
| eph-worker02 | 172.16.10.35 | mino | `~/.ssh/eph_k8s` |
| havenbridge-runner01 | 172.16.10.37 | mino | `~/.ssh/eph_k8s` |
| crafty-perf-01 | 192.168.77.10 | mino | `~/.ssh/eph_k8s` |
| kali-ai | 192.168.88.185 | mino | `~/.ssh/kali_ai` |

### Verification Procedure

**HOST: `syrus`**

```bash
# PURPOSE: Verify all eight SSH aliases.
# SAFETY: Read-only remote identity checks.

for vm in \
  eph-cp01 \
  eph-cp02 \
  eph-cp03 \
  eph-worker01 \
  eph-worker02 \
  havenbridge-runner01 \
  crafty-perf-01 \
  kali-ai
do
    echo "===== Testing $vm ====="

    ssh \
      -o BatchMode=yes \
      -o ConnectTimeout=5 \
      "$vm" \
      'whoami && hostname' \
      || echo "FAILED: $vm"

    echo
done
```

### ELI10 — Command Explanation

- `for vm in ...`: Repeats the check for each virtual machine.
- `ssh`: Opens a secure remote connection.
- `-o`: Supplies an SSH connection option.
- `BatchMode=yes`: Disables interactive authentication prompts.
- `ConnectTimeout=5`: Limits the initial connection wait to five seconds.
- `"$vm"`: Uses the hostname alias from the SSH configuration.
- `whoami`: Verifies the remote account.
- `&&`: Runs the next command only when the previous command succeeds.
- `hostname`: Verifies the remote computer's identity.
- `|| echo`: Reports an SSH failure.
- `done`: Ends the Bash loop.

### Verified Outcome

All eight SSH connections returned username `mino` and their expected VM hostnames.

No failures were reported.

### Security and Operational Notes

- Private SSH keys remain outside the Git repository.
- Existing GitHub SSH authentication settings were preserved.
- The Kali network remains separate from the HavenBridge and Crafty libvirt networks.
- Successful SSH authentication does not prove complete network isolation.
- Kali currently uses a DHCP-assigned IP address. A stable address or reservation is still required.
- SSH aliases simplify future Ansible inventory configuration.

**Lessons learned:** Verify SSH identities and connectivity before deploying configuration automation. Preserve existing SSH configuration and record actual results instead of assuming success.
