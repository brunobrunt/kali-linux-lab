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

Then inspect the file, validate the workflow, commit it to `feature/kali-ai-lab`, and observe the actual results on Draft PR #1.

Update this guide with the verified outcome and any troubleshooting evidence.
