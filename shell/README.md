

# Unified Shell Configuration

This directory contains a modular shell configuration designed to work cleanly
across:

- macOS (your laptop)
- Linux HPC clusters (Cholesky, Jean-Zay)
- CMAP servers
- any generic remote Linux VM

It ensures:

- **same dotfiles everywhere**
- **auto-detection of local vs cluster**
- **macOS-only sshfs stays on the Mac**
- **cluster-only SLURM config stays on clusters**
- **secrets isolated**

No duplication. No collisions. No junk in `$HOME`.

---

# Directory Layout

```
~/.config/shell/
│
├── bashrc               # main entry point; auto-router
├── bashrc_common        # loaded on ALL machines
├── bashrc_mac           # loaded ONLY on macOS
├── bashrc_cluster       # loaded ONLY on HPC clusters
└── local.sh             # secrets / overrides (gitignored)
```

---

# How the Router Works

The file `bashrc` is sourced by `~/.bashrc`.  
It applies:

```
bashrc_common
 + bashrc_mac        (if on macOS)
 + bashrc_cluster    (if on cluster hostname)
 + local.sh          (always if present)
```

### Detection rules

- macOS detection = `OSTYPE=darwin*`
- Linux cluster detection = `OSTYPE=linux*` AND hostname matches:

```
cholesky*
jeanzay*
jean-zay*
cmap*
```

Everything else = generic Linux → loads only `bashrc_common` + optional `local.sh`.

---

# 1. macOS Setup (local laptop)

`~/.bashrc`:

```bash
[ -f ~/.config/shell/bashrc ] && source ~/.config/shell/bashrc
```

`~/.bash_profile`:

```bash
[ -f ~/.bashrc ] && source ~/.bashrc
```

macOS automatically loads:

```
bashrc_common + bashrc_mac (+ local.sh)
```

---

# 2. Cluster / Remote Linux Setup (DETAILED)

These steps must be executed **directly on the cluster** (SSH session).

## STEP 1 — Clone your config repo into ~/.config

```bash
cd ~
git clone <YOUR_REPO_URL> .config
```

If `.config` already exists:

```bash
cd ~/.config
git pull
```

## STEP 2 — Install the standard bash “stubs”

`~/.bashrc`:

```bash
[ -f ~/.config/shell/bashrc ] && source ~/.config/shell/bashrc
```

`~/.bash_profile`:

```bash
[ -f ~/.bashrc ] && source ~/.bashrc
```

## STEP 3 — Verify hostname detection

```bash
hostname
```

Matches any of:

```
cholesky*
jeanzay*
jean-zay*
cmap*
```

→ router loads `bashrc_cluster`.

## STEP 4 — Create cluster-specific config

Create:

```bash
nano ~/.config/shell/bashrc_cluster
```

Paste:

```bash
# ==== Cluster-only configuration ====

module() { command module "$@"; } 2>/dev/null || true
module load python/3.11 2>/dev/null || true

alias sq='squeue -u $USER'
alias sqg='squeue --me -o "%.18i %.9P %.20j %.8u %.2t %.10M %.6D %.20R"'
alias sj='sacct -u $USER --format=JobID,State,Elapsed,CPUTime,NodeList%30'

alias wq='watch -n 1 "squeue -u $USER"'

alias du1='du -h -d 1'
alias dus='du -sh * 2>/dev/null'

alias h='cd ~'
alias proj='cd ~/proj'

cd ~
```

## STEP 5 — Local secrets (optional)

```bash
nano ~/.config/shell/local.sh
```

Examples:

```bash
export WANDB_API_KEY="..."
export HF_TOKEN="..."
```

`local.sh` is gitignored.

## STEP 6 — Reload & test

```bash
source ~/.bashrc
alias sq
alias gp
echo $OSTYPE
hostname
```

---

# 3. Behavior Summary

| Machine                | Config Loaded                                     |
|------------------------|---------------------------------------------------|
| macOS                 | common + mac + local                              |
| Cholesky              | common + cluster + local                          |
| Jean-Zay              | common + cluster + local                          |
| CMAP Linux            | common + cluster + local                          |
| other Linux           | common + local                                    |

---

# Git Ignore Rules

`~/.config/.gitignore`:

```
shell/local.sh
nvim/plugged/
nvim/.cache/
nvim/undo/
tmuxp/*-session.yaml
```

---

# Result

You now maintain:

- one dotfiles repo
- automatic machine-specific behavior
- safe secrets isolation
- clean home directory
- reproducible environments everywhere
