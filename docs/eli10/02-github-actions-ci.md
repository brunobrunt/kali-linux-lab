# ELI10 Guide 02 — GitHub Actions and CI/CD

**Project:** Kali Linux Lab
**Repository:** `brunobrunt/kali-linux-lab`
**Development branch:** `feature/kali-ai-lab`
**Pull request:** Draft PR #1
**Execution host:** `syrus`
**CI platform:** GitHub Actions
**Status:** Configuration in progress — CI execution not yet verified

---

## 1. CRAFT — Learning Objectives

### C — Context

Kali Linux Lab uses GitHub Actions to automatically check project files before they are merged into the `main` branch.

The goal is to identify configuration and documentation errors early while preserving our existing HavenBridge infrastructure.

### R — Role

Act as a senior Linux, Git, GitHub Actions, Terraform, Ansible, and cybersecurity mentor.

Explain the commands in ELI10 language, verify results, and document lessons learned.

### A — Action

Create a GitHub Actions workflow that initially validates basic documentation requirements and later checks Terraform and Ansible configurations.

### F — Format

Use YAML for the workflow, Markdown for explanations, and terminal commands for local verification.

Record actual results, troubleshooting steps, and outcomes.

### T — Tone

Explain concepts simply, introduce one practical activity at a time, and distinguish planned work from verified results.

---

## 2. What Is CI/CD?

**CI means Continuous Integration.**

ELI10: Imagine building a car. Before new parts are installed permanently, an inspector checks that they meet the required standards.

In software development, CI acts as that inspector.

When we push code to GitHub, automated checks can run to detect problems before the changes are merged.

**CD means Continuous Delivery or Continuous Deployment**, depending on the workflow.

Delivery prepares changes for release; deployment automatically releases them.

Our first Kali Linux Lab workflow focuses on **CI only**. It will not deploy virtual machines or configure infrastructure.

---

## 3. Our GitHub Development Workflow

```text
Developer: syrus
       |
       v
feature/kali-ai-lab
       |
       | git add / commit / push
       v
GitHub Repository
       |
       v
GitHub Actions
       |
       +-- Documentation checks
       |
       +-- Terraform checks (planned)
       |
       +-- Ansible checks (planned)
       |
       v
Draft Pull Request #1
       |
       v
Human review + required CI checks
       |
       v
Merge to main only when approved
```

The existing HavenBridge Kubernetes environment is outside the scope of this workflow.

---

## 4. Where Are GitHub Actions Workflows Stored?

GitHub recognizes YAML workflow files under:

`.github/workflows/`

Our planned workflow file is:

`.github/workflows/kali-lab-ci.yml`

To create the directory:

**HOST: `syrus`**

```bash
mkdir -p .github/workflows
```

**ELI10 flags:**

- `mkdir`: Make a directory.
- `-p`: Create missing parent directories and do not fail if the directory already exists.

**Verification:** Directory creation confirmed on `syrus` on November 3, 2026.

---

## 5. Understanding Our Workflow YAML

| YAML element | ELI10 explanation |
|---|---|
| `name` | The name shown in GitHub's Actions tab |
| `on` | Defines the events that start the workflow |
| `push` | Runs the workflow when code is pushed to selected branches |
| `pull_request` | Runs checks for pull requests targeting selected branches |
| `workflow_dispatch` | Allows a manual workflow run |
| `permissions` | Defines permissions for the automatic GitHub token |
| `contents: read` | Allows reading repository contents without write access |
| `jobs` | Defines groups of automated checks |
| `runs-on: ubuntu-24.04` | Uses a GitHub-hosted Ubuntu 24.04 runner |
| `steps` | Individual tasks executed inside a job |
| `actions/checkout@v4` | Makes the repository files available to the runner |
| `run` | Executes shell commands |
| `set -euo pipefail` | Enables stricter Bash error handling |
| `test -s README.md` | Checks that the README exists and is nonempty |
| `git diff --check` | Detects certain whitespace errors in changed files |

**Important:** A nonempty README check does not verify Markdown correctness. Whitespace checks also do not validate Terraform or Ansible syntax.

---

## 6. Understanding `set -euo pipefail`

This command makes Bash scripts more strict.

- `-e`: Exit when an unhandled command fails.
- `-u`: Treat references to unset variables as errors.
- `-o pipefail`: Treat a pipeline as failed when any command in the pipeline fails, not only the last command.

ELI10: Instead of ignoring warning signs, the script stops when an important check fails.

---

## 7. GitHub-Hosted Runner Versus `syrus`

| Component | Responsibility |
|---|---|
| `syrus` | Local development, Terraform provisioning, and Ansible configuration |
| GitHub-hosted runner | Automated repository validation |
| `eph-cp01` | Existing HavenBridge Kubernetes administration |
| `kali-ai` | Planned Kali Linux training VM |

A GitHub-hosted runner is a temporary machine that GitHub provides for workflow execution.

Our initial workflow must not contain SSH credentials, cloud deployment credentials, libvirt connection strings, or commands that modify HavenBridge.

---

## 8. Validation Plan

| Check | Status |
|---|---|
| Standalone Git repository created | PASS |
| Feature branch created | PASS |
| Draft PR #1 created | PASS |
| Workflow directory created | PASS |
| Workflow YAML created | NOT YET VERIFIED |
| README presence validation | NOT YET VERIFIED |
| GitHub Actions successful run | NOT YET VERIFIED |
| Terraform formatting and validation | PLANNED |
| Ansible syntax validation | PLANNED |
| Main branch protection | NOT YET VERIFIED |

Status values must be updated only after examining actual output or GitHub Actions results.

---

## 9. Troubleshooting

### Problem: Git does not display the workflow directory

Git tracks files, not empty directories.

**Solution:** Create the workflow YAML file inside `.github/workflows/`, then check Git status.

### Problem: GitHub Actions does not run

Investigate whether:

- The workflow is committed and pushed.
- The workflow triggers match the branch or pull request.
- GitHub Actions is enabled for the repository.
- The workflow YAML is valid.
- GitHub has reported a skipped, queued, or failed run.

Do not assume a workflow succeeded simply because it appears in the Actions tab.

### Problem: CI fails

Open the failed job in GitHub Actions and inspect the relevant step logs.

Fix the underlying issue, commit the correction, and push again.

---

## 10. Lessons Learned

1. GitHub Actions automates repository checks.
2. YAML defines when jobs execute and what they do.
3. GitHub-hosted runners are separate from the local KVM hypervisor.
4. Minimal workflow permissions reduce unnecessary access.
5. Passing documentation checks does not prove infrastructure correctness.
6. Automated checks and human review complement each other.

---

## 11. Next Practical Activity

Create `.github/workflows/kali-lab-ci.yml` on `syrus`.

---

## 12. Troubleshooting — GitHub Actions Node.js Deprecation Warning

**Date:** November 3, 2026

### Problem

Our first Kali Lab CI workflow completed successfully, but GitHub reported a warning.

**Observed warning:**

`Node.js 20 is deprecated. The following actions target Node.js 20 but are being forced to run on Node.js 24: actions/checkout@v4.`

### Root Cause

The workflow used `actions/checkout@v4`, which targeted Node.js 20.

GitHub's runner environment is transitioning away from Node.js 20.

### Corrective Action

Updated the GitHub Actions workflow:

```yaml
# Before
uses: actions/checkout@v4

# After
uses: actions/checkout@v6
```

### ELI10 Explanation

GitHub Actions uses reusable components called *actions*.

`actions/checkout` is responsible for making repository files available to the temporary GitHub runner.

The older action version used an outdated Node.js runtime.

Upgrading the action allows us to use a version designed for newer runner environments.

We did not need to install or upgrade Node.js on `syrus`, because this workflow runs on GitHub-hosted infrastructure.

### Local Verification

- Confirmed `actions/checkout@v6` appears in the workflow.
- Ran `git diff --check` without whitespace errors.
- Reviewed the Git diff and confirmed the intended version change.


### CI Verification

**Status: PASS — November 3, 2026**

- Workflow: Kali Lab CI
- Commit: `0b52236`
- Run ID: `41677329683`
- Job: Documentation Validation
- Result: SUCCESS
- GitHub API annotations: `[]` (none returned)
- Node.js 20 deprecation warning: No longer reported for the inspected job

**Verification commands (HOST: `syrus`):**

```bash
gh run view 41677329683 \
  --repo brunobrunt/kali-linux-lab \
  --json conclusion,headSha,jobs

gh api \
  repos/brunobrunt/kali-linux-lab/check-runs/126061363381/annotations
```

**Outcome:** Upgrading `actions/checkout@v4` to `actions/checkout@v6` resolved the observed warning. The workflow completed successfully without reported annotations.

After committing and pushing the workflow change, inspect the new GitHub Actions run.

Confirm that Documentation Validation passes and the Node.js deprecation warning is absent.

### Lesson Learned

A successful CI workflow can still contain warnings. Always inspect annotations and job logs, investigate deprecated dependencies, and verify corrective actions through a new CI execution.


---

## 13. Terraform Validation in GitHub Actions

**Date:** November 5, 2026

**Status:** Locally validated — GitHub CI execution pending.

### Purpose

Extend Kali Lab CI with a dedicated Terraform Validation job.

This job inspects Terraform configuration files without creating or modifying infrastructure.

### Workflow configuration

File: `.github/workflows/kali-lab-ci.yml`

The workflow now defines two jobs:

| Job | Responsibility |
|---|---|
| Documentation Validation | Check required documentation and Git whitespace |
| Terraform Validation | Check Terraform formatting and configuration validity |

### Terraform Validation steps

1. **Check out repository:** Make the source files available on GitHub's runner.
2. **Set up Terraform:** Install Terraform 1.16.1.
3. **Check Terraform formatting:** Run `terraform fmt -check -recursive terraform/`.
4. **Initialize Terraform:** Run `terraform -chdir=terraform init -backend=false -lockfile=readonly`.
5. **Validate Terraform:** Run `terraform -chdir=terraform validate -no-color`.

### ELI10 command explanations

| Command or flag | Meaning |
|---|---|
| `hashicorp/setup-terraform@v3` | Prepare Terraform on the GitHub runner |
| `terraform_version` | Select the required Terraform version |
| `fmt -check` | Verify formatting without modifying configuration |
| `-recursive` | Include Terraform files in nested directories |
| `-chdir=terraform` | Run the command inside the Terraform directory |
| `init -backend=false` | Initialize providers without backend initialization |
| `-lockfile=readonly` | Prevent changes to the committed provider lock file |
| `validate -no-color` | Validate configuration without terminal colour codes |

### Local verification

On `syrus`, the following checks passed:

- `git diff --check`
- Python YAML parsing with PyYAML
- Detection of the `documentation` and `terraform` jobs
- Verification that both jobs contain runner and step definitions
- Visual inspection of YAML indentation

### GitHub CI verification

**Status: PENDING**

After committing and pushing, confirm that both Documentation Validation and Terraform Validation finish successfully.

Record the GitHub Actions run IDs and any warnings or failures.

### Security

This workflow does not execute `terraform apply`, connect to `syrus`, or provision infrastructure.

The existing `kali-ai-net` network remains managed by local Terraform state on `syrus`.
