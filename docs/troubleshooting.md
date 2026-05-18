# Troubleshooting Log — Docker Mastery Project
## George Awa — Real Issues Hit and How They Were Fixed

---

## Issue 1 — TaskFlow docker-compose.yml missing locally after branch switch

### What happened
After merging feature/module3-compose to main via GitHub PR,
the taskflow folder was missing docker-compose.yml locally.
Running docker compose up -d returned: no configuration file provided

### Root cause
The feature/module3-compose branch was merged directly to main on GitHub
but was never merged into develop. The local develop branch never received
the taskflow files. Git reported already up to date because develop
was up to date with origin/develop but origin/develop was missing
the taskflow files too.

### How it was diagnosed
git ls-tree origin/develop --name-only
taskflow was NOT listed

git ls-tree origin/main --name-only
taskflow WAS listed

### How it was fixed
git checkout develop
git merge origin/main
git push origin develop
git checkout feature/module6-security
git merge develop

### Lesson learned
Always merge feature branches to develop FIRST before they reach main.
The correct flow is: feature -> develop -> main
Never merge a feature branch directly to main while skipping develop.
This caused taskflow to exist on main but not develop, creating a split
that broke local development.

---

## Issue 2 — Git Bash path conversion breaking Docker volume mounts on Windows

### What happened
Running docker volume commands with /data paths on Windows Git Bash
caused Git Bash to convert the Unix path to a Windows path.

docker run --rm -v my-data-volume:/data alpine cat /data/test.txt
Result: cat: can't open 'C:/Program Files/Git/data/test.txt': No such file or directory

### Root cause
Git Bash on Windows automatically converts Unix-style paths starting with /
to Windows paths. It saw /data and converted it to C:/Program Files/Git/data
which does not exist inside the container.

### How it was fixed
export MSYS_NO_PATHCONV=1

This environment variable tells Git Bash to stop converting paths.
Set it once at the start of a session and all subsequent docker commands
with Unix paths work correctly.

Add to .bashrc to make it permanent:
echo 'export MSYS_NO_PATHCONV=1' >> ~/.bashrc

---

## Issue 3 — Heredoc corruption when pasting multi-line commands in Git Bash

### What happened
Pasting long heredoc commands containing backticks or special characters
into Git Bash caused the heredoc to break mid-way, producing a corrupted
file with partial content mixed with terminal output.

### Root cause
Git Bash terminal interprets some characters differently when pasting.
Backticks inside heredocs caused early termination of the heredoc block.

### How it was fixed
Open the file in VS Code instead of using heredoc:
code filename.md
Paste content directly in VS Code editor, save with Ctrl+S, then commit.

### Lesson learned
For any file with complex content, always use VS Code or another editor
instead of heredoc in Git Bash on Windows.

---

## Issue 4 — Trivy container scan failing in GitHub Actions pipeline

### What happened
The Trivy container scan stage kept failing with exit code 1 even after
switching to Alpine base image.

### Root cause
Two issues:
1. The CodeQL SARIF upload step lacked security-events: write permission
2. Trivy was failing on unfixable OS-level CVEs that had no patches

### How it was fixed
Added permissions block to pipeline.yml:
permissions:
  contents: read
  security-events: write
  actions: read

Added ignore-unfixed: true to Trivy action to only fail on patchable CVEs.

### Lesson learned
Trivy by default fails on ALL CVEs including ones with no fix available.
Use ignore-unfixed: true in CI to only fail on CVEs that can be patched.

---

## Issue 5 — Docker Compose missing secret files

### What happened
docker compose up failed because the secret files were in .gitignore
and not present locally after cloning.

### How it was fixed
mkdir -p secrets
echo "MySecureDBPass123" > secrets/db_password.txt
echo "MySecureRedisPass" > secrets/redis_password.txt

### Lesson learned
Secret files are never committed to the repo.
Always document the required secret files in the README so anyone
cloning the repo knows what to create before running docker compose up.