# ELI10 Guide 03 — GitHub CLI (`gh`) Command Reference

**Project:** Kali Linux Lab
**Repository:** `brunobrunt/kali-linux-lab`
**Development branch:** `feature/kali-ai-lab`
**Pull request:** Draft PR #1
**Host:** `syrus`
**Last evidence recorded:** November 4, 2026

> This is a living reference. Add commands as they are actually introduced, distinguishing executed commands from optional examples. Commands in this guide inspect GitHub unless explicitly identified as an action that changes something.

## 1. CRAFT learning framework

- **Context:** Use GitHub CLI to manage and inspect GitHub repositories, workflows, runs, and pull requests from the Linux terminal.
- **Role:** Senior Linux, Git, GitHub Actions, and infrastructure mentor.
- **Action:** Learn a command, run it on a named host, inspect actual output, then document its purpose.
- **Format:** Terminal command alongside the GitHub website equivalent, flags, observations, and troubleshooting.
- **Tone:** ELI10; one practical action at a time, do not claim success without verification.

## 2. ELI10: `git` versus `gh`

- **`git`** manages local commits, branches, and pushes/pulls of Git data.
- **`gh`** talks to GitHub's service for workflows, run logs, pull requests, and repository information.
- `gh` normally detects the GitHub repository from the **current working directory**. Use `--repo OWNER/REPO` (or `-R OWNER/REPO`) to inspect another repository **without switching directories, branches, or worktrees**.
- `gh` authenticates separately from Git over SSH; your `git push` can work even if `gh` needs login.

## 3. Commands we have used

All terminal examples in this section run on **HOST: `syrus`**. Commands listed below reflect those executed or explicitly tried during our lab; numeric IDs identify real workflow runs/jobs reported in this project.

| Terminal command | ELI10 explanation | GitHub web equivalent |
|---|---|---|
| `gh auth login` | Start the guided GitHub CLI authentication. Choose GitHub.com, SSH protocol, and browser login; skip uploading an existing SSH key if it is already registered. | Browser opens `github.com/login/device` for authorization |
| `gh auth status` | Check which GitHub account is connected and how it authenticates. **Never publish unmasked tokens.** | GitHub profile/settings (not a direct CLI-auth-status equivalent) |
| `gh workflow list` | List workflows in the repository detected from the current directory. | Repository → **Actions** → left sidebar |
| `gh workflow list --repo brunobrunt/havenbridge-ha-service-platform --limit 20` | List up to 20 HavenBridge workflows from any directory. | HavenBridge repository → **Actions** |
| `gh workflow view "HavenBridge CI" --repo brunobrunt/havenbridge-ha-service-platform --yaml` | Read the actual HavenBridge CI YAML; does not edit the workflow. | HavenBridge → Actions → HavenBridge CI → Workflow file |
| `gh run list --workflow kali-lab-ci.yml --branch feature/kali-ai-lab --limit 5` | Show up to five Kali CI runs on our feature branch. | Kali repository → Actions → Kali Lab CI → runs |
| `gh run list --limit 20` | Show up to 20 recent runs across workflows in the current repository. | Repository → Actions → All workflows |
| `gh run list --repo brunobrunt/havenbridge-ha-service-platform --limit 20` | View up to 20 HavenBridge runs without changing Git directories. | HavenBridge → Actions → All workflows |
| `gh run list --repo brunobrunt/havenbridge-ha-service-platform --branch main --limit 10` | Show up to ten recent HavenBridge runs associated with `main`. | HavenBridge → Actions → filter branch to main |
| `gh run view 41677329683` | Read the summary of the Kali CI run after the checkout upgrade. | Kali → Actions → run `41677329683` |
| `gh run view 41677329683 --repo brunobrunt/kali-linux-lab --json conclusion,headSha,jobs` | Get structured JSON showing overall result, tested commit, jobs, and their steps. | Kali → Actions → selected run → Documentation Validation |
| `gh api repos/brunobrunt/kali-linux-lab/check-runs/126061363381/annotations` | Retrieve raw JSON of annotations for the checkout-upgrade job; observed result: `[]`. | Run → Documentation Validation → Annotations (if any) |
| `gh api repos/brunobrunt/kali-linux-lab/check-runs/126061363381/annotations --jq '.[] \| {level: .annotation_level, message: .message, path: .path}'` | Print only each annotation's level, message, and path. With no annotations, produces no lines. The `\|` here is a Markdown table escape; in the shell use the unescaped `|` inside the quoted `--jq` expression. | Same job annotations section |

### Flag cheat sheet

| Flag | Meaning |
|---|---|
| `--repo OWNER/REPO` or `-R OWNER/REPO` | Explicitly select the remote repository being inspected |
| `--workflow FILE_OR_NAME` | Select a particular GitHub Actions workflow |
| `--branch NAME` | Filter workflow runs by branch |
| `--limit N` | Maximum number of results returned |
| `--yaml` | Display a workflow's YAML definition |
| `--json FIELDS` | Return selected machine-readable fields |
| `--jq FILTER` | Format/filter JSON using a jq expression |
| `--log` | Show workflow run logs when used with `gh run view` |
| `--web` | Open a browser for commands that actually support this flag; **`gh run list --web` is not supported** |
| `\` at the end of a shell line | Continue the same shell command on the next line |

## 4. Helpful follow-up commands (reference — not all executed yet)

**HOST: `syrus`**

```bash
# Show a specific Kali run's logs (read-only)
gh run view 41677329683 --repo brunobrunt/kali-linux-lab --log

# View the standalone Kali lab PR (read-only)
gh pr view 1 --repo brunobrunt/kali-linux-lab

# List pull requests in HavenBridge (read-only)
gh pr list --repo brunobrunt/havenbridge-ha-service-platform

# See GitHub CLI options for workflow runs (read-only)
gh run list --help
```

**Web equivalents:** Kali/HavenBridge repository → Actions → choose a run → expand job steps; repository → Pull requests → select the PR.

## 5. Verified results — checkout Node.js warning investigation

**November 3–4, 2026:** The initial Kali Lab CI used `actions/checkout@v4` and reported a Node.js 20 deprecation warning, although CI succeeded. We updated to `actions/checkout@v6` in commit `0b52236`.

- **Run ID:** `41677329683` (push event; checkout-upgrade commit)
- **Job ID:** `126061363381` — Documentation Validation
- **Tested `headSha`:** `0b522366be5d388cafd004c288ff85a22374cbcb`
- **Workflow conclusion:** `success`
- **Steps reported:** checkout, README existence, ELI10 guide existence, and Git whitespace checks all succeeded.
- **Annotation API result:** `[]` (zero annotations returned for that job).
- **Conclusion:** Upgraded checkout run passed with no check-run annotations returned. This does **not** mean Terraform, Ansible, or libvirt isolation has been tested.

Source view: https://github.com/brunobrunt/kali-linux-lab/actions/runs/41677329683

## 6. Troubleshooting and safety

**`gh` says `gh auth login`:** Git SSH and GitHub CLI authentication are separate. Run `gh auth login`, then verify with `gh auth status`. Do not paste a one-time authorization code or unmasked token into chat, logs, or README.

**HavenBridge workflows are missing:** You may be in the Kali repository. Specify `--repo brunobrunt/havenbridge-ha-service-platform` rather than changing worktrees unnecessarily.

**No annotations shown:** An empty API array `[]` means no check-run annotations were returned. The absence of annotations is not a replacement for inspecting workflow conclusions and individual job steps.

**A successful push did not immediately show CI:** `git push` and GitHub-hosted CI are separate; CI may continue asynchronously after the push completes.

**Never mistake inspecting GitHub for administering Kubernetes:** `gh` queries do not require `kubectl` on `syrus`. HavenBridge Kubernetes operations belong on `eph-cp01`.

## 7. Keep this reference current

Whenever a new `gh` command is introduced:

1. Add the **exact host-labeled command** to this guide.
2. Explain all important flags in ELI10 language.
3. Provide the equivalent **GitHub web navigation** alongside it.
4. Record results only after terminal output or UI evidence verifies them.
5. Commit updates on `feature/kali-ai-lab`, push them to standalone Kali Draft PR #1, and verify CI before merge.

**Reminder:** Original HavenBridge Draft PR #2 remains independent and must not be merged as part of Kali migration.
