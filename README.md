
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



### A — Action

Inspect and verify host resources, routes, libvirt networks, and storage
before provisioning any Kali resources.

### F — Format and Evidence

Maintain host-labelled commands, observed results, planned choices, and
verification status in this README.

### T — Tone and ELI10 Explanation

Explain each flag and concept in simple language; a separate subnet is not
by itself proof of network isolation.
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
