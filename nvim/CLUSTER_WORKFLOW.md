# Complete Cluster Workflow in Neovim

This guide shows how to use nvim as your complete cluster environment - no need to exit to shell for most tasks.

## Philosophy

**Stay in nvim, minimize context switching.** With this setup, you can:
- Edit code with LSP intelligence
- Run commands in integrated terminals
- Browse and manage files visually
- Submit and monitor SLURM jobs
- Search across your entire codebase
- Manage git from within nvim

## Essential Workflows

### 1. File Management

#### Visual File Browser
```
<leader>e           Toggle nvim-tree file explorer
  j/k               Navigate files
  <CR>              Open file
  a                 Create new file
  d                 Delete file
  r                 Rename file
  x                 Cut file
  c                 Copy file
  p                 Paste file
  R                 Refresh tree
  H                 Toggle hidden files
  I                 Toggle git ignored files
```

#### Fuzzy Finding
```
<leader>ff          Find files by name
<leader>fg          Search content in files (grep)
<leader>fb          Browse open buffers
<leader>fr          Recent files
<leader>fh          Help tags
```

#### Quick Navigation
```
gf                  Go to file under cursor
<C-o>               Jump back
<C-i>               Jump forward
:e path/to/file     Edit file
:cd %:h             Change to current file's directory
```

### 2. Terminal Integration

#### Toggle Terminal
```
<C-\>               Toggle horizontal terminal
<leader>tf          Float terminal (popup)
<leader>th          Horizontal terminal (bottom)
<leader>tv          Vertical terminal (side)
```

#### In Terminal Mode
```
<Esc>               Exit terminal mode to normal mode
<C-h/j/k/l>         Navigate to other windows
<C-\>               Toggle terminal off
```

#### Common Workflow
```vim
" Open terminal, run command, return to editing
<C-\>               " Open terminal
python script.py    " Run your code
<Esc>               " Back to normal mode
<C-\>               " Close terminal
```

### 3. Running Code & Jobs

#### Quick Execution
```vim
" Method 1: Terminal command
:TermExec cmd="python %"                    " Run current file
:TermExec cmd="sbatch script.sh"            " Submit SLURM job
:TermExec cmd="squeue -u $USER"             " Check job status

" Method 2: Toggle terminal
<C-\>                                       " Open terminal
python script.py                            " Run directly
exit                                        " Close when done
```

#### SLURM Job Management
```vim
" Submit job and monitor
:TermExec cmd="sbatch myjob.sh && squeue -u $USER"

" Check running jobs
:TermExec cmd="squeue -u $USER"

" Cancel job
:TermExec cmd="scancel JOBID"

" View job output
:e slurm-12345.out                          " Open output file
```

#### Multiple Terminal Windows
```vim
" Open multiple terminals for different tasks
1<C-\>              " Terminal 1 (id 1)
python -m http.server 8000

2<C-\>              " Terminal 2 (id 2)
watch -n 1 squeue -u $USER

3<C-\>              " Terminal 3 (id 3)
htop

" Toggle between them
1<C-\>              " Show terminal 1
2<C-\>              " Show terminal 2
```

### 4. Code Development

#### LSP-Powered Editing
```
gd                  Go to definition
K                   Show documentation
gi                  Go to implementation
gr                  Find all references
<leader>rn          Rename symbol across files
<leader>ca          Code actions (fix imports, etc)
<leader>d           Show diagnostic
[d / ]d             Navigate diagnostics
```

#### Smart Editing
```
gcc                 Comment line
gc (visual)         Comment selection
cs"'                Change surrounding " to '
ds"                 Delete surrounding "
ysiw"               Surround word with "
```

#### Search & Replace
```
<leader>fg          Search in files
/pattern            Search in current file
:%s/old/new/gc      Replace in file (with confirm)
:cfdo %s/old/new/g  Replace across all files in quickfix
```

### 5. Git Workflow

#### Visual Git Status
```
]c / [c             Next/previous git hunk
<leader>hp          Preview hunk
<leader>hs          Stage hunk
<leader>hr          Reset hunk
<leader>hb          Blame line
<leader>hd          Diff this file
```

#### Git Commands in Terminal
```vim
<C-\>
git status
git add .
git commit -m "message"
git push
git log --oneline
git diff
```

### 6. Working with Data Files

#### Quick File Preview
```vim
:e data.csv                                 " Open CSV
:set nowrap                                 " Disable wrap for wide files
<C-x> <C-v>                                 " Column-wise visual block

" View large files
:e huge.log
/ERROR                                      " Search for patterns
n                                           " Next occurrence
```

#### Comparing Files
```vim
:vsp file2.py                               " Split vertically
:diffthis                                   " Enable diff mode
" In other window
:diffthis
" Navigate differences
]c / [c                                     " Next/previous diff
:diffoff                                    " Disable diff
```

### 7. Project Organization

#### Project Structure
```
cluster_project/
├── scripts/           # Your code
│   ├── train.py
│   └── analyze.py
├── jobs/             # SLURM scripts
│   ├── train.sh
│   └── process.sh
├── data/             # Data files
├── results/          # Output
└── logs/             # SLURM logs
```

#### Workflow Example
```vim
" 1. Open project
nvim ~/cluster_project

" 2. Browse files
<leader>e                                   " Open file tree
Navigate to scripts/train.py
<CR>                                        " Open it

" 3. Edit code with LSP
gd                                          " Jump to function definition
<leader>rn                                  " Rename variable

" 4. Run test
<C-\>                                       " Open terminal
python scripts/train.py --test              " Test run

" 5. Submit job
<Esc>                                       " Exit terminal
:e jobs/train.sh                            " Open job script
" Edit parameters
:w                                          " Save
<C-\>                                       " Terminal
sbatch jobs/train.sh                        " Submit
squeue -u $USER                             " Check status

" 6. Monitor
:e logs/slurm-12345.out                     " View output
G                                           " Jump to end
:set autoread                               " Auto-reload file
```

### 8. Session Persistence

#### Using tmux (Recommended)
```bash
# On cluster, use tmux for persistent sessions
tmux new -s work                            # Create session
nvim                                        # Start nvim
# Detach: Ctrl-b d
# Reattach later: tmux attach -t work
```

#### Built-in Session
```vim
" Save session
:mksession! ~/.nvim-session.vim

" Restore later
nvim -S ~/.nvim-session.vim
# or
:source ~/.nvim-session.vim
```

## Advanced Tips

### 1. Custom Commands for SLURM

Add to your `init.cluster.lua`:

```lua
-- Quick SLURM commands
vim.api.nvim_create_user_command("Squeue", function()
  vim.cmd("TermExec cmd='squeue -u $USER'")
end, {})

vim.api.nvim_create_user_command("Scancel", function(opts)
  vim.cmd(string.format("TermExec cmd='scancel %s'", opts.args))
end, { nargs = 1 })

vim.keymap.set("n", "<leader>sq", "<cmd>Squeue<cr>", { desc = "Check job queue" })
```

Then use: `:Squeue` or `<leader>sq`

### 2. Auto-reload Log Files

```vim
" For actively written log files
:set autoread
:au CursorHold * checktime                  " Check for changes

" Or manually
:e                                          " Reload file
```

### 3. Working Directory Management

```vim
:cd ~/project                               " Change working directory
:lcd ~/project                              " Local to current window
:pwd                                        " Show current directory
:cd %:h                                     " CD to current file's dir
```

### 4. Clipboard Integration

With `clipboard = "unnamedplus"` already set:

```vim
yy                  " Yank line (also copies to system clipboard)
p                   " Paste from clipboard

" In terminal mode
<C-\><C-n>"+p       " Paste from vim clipboard
```

### 5. Multiple Files Workflow

```vim
" Method 1: Buffers
:e file1.py         " Open file
:e file2.py         " Open another
:b file1            " Switch to file1
:b#                 " Toggle between last two
<leader>fb          " Buffer picker

" Method 2: Tabs
:tabnew file.py     " Open in new tab
gt                  " Next tab
gT                  " Previous tab

" Method 3: Splits
:vsp file.py        " Vertical split
:sp file.py         " Horizontal split
<C-w>w              " Cycle windows
```

## Recommended Workflow

### Starting Your Day
```bash
# SSH to cluster
ssh cluster

# Start or attach tmux
tmux attach -t work || tmux new -s work

# Navigate to project
cd ~/my_project

# Start nvim
nvim
```

### Typical Session
```vim
<leader>e           " Browse project files
<leader>ff          " Find file to edit
                    " Make changes (with LSP help)
:w                  " Save
<C-\>               " Open terminal
python test.py      " Quick test
sbatch job.sh       " Submit real job
exit
:Squeue             " Check queue
<leader>e           " Browse to logs
                    " Open log file
```

### Ending Your Day
```vim
:wa                 " Save all files
:mksession!         " Save session (optional)
:qa                 " Quit
# Detach tmux: Ctrl-b d
```

## Why This Works Well on Clusters

1. **Low bandwidth** - No need to transfer files back/forth
2. **Persistent** - With tmux, sessions survive disconnects
3. **Integrated** - Edit, test, submit jobs all in one place
4. **Fast** - No GUI overhead, works great over SSH
5. **Powerful** - Full LSP, fuzzy finding, git integration
6. **Minimal** - Just nvim + tmux, works on any cluster

## When to Use Shell Instead

Some tasks are still better in raw shell:
- Complex piping: `find | grep | xargs | sort`
- Interactive programs: `htop`, `ncdu`
- System administration
- Installing software

But you can run these from nvim's terminal!

## Troubleshooting

### Terminal doesn't work
```vim
:checkhealth toggleterm
" Check shell setting
:echo &shell
:set shell=/bin/bash
```

### Slow LSP
```vim
:LspStop            " Stop LSP
:set ft=           " Disable filetype detection for huge files
```

### Too many files open
```vim
:bufdo bd           " Close all buffers
:e!                 " Reload current file
```

## Next Steps

1. Try working exclusively in nvim for a day
2. Add custom commands for your common tasks
3. Learn tmux for session persistence
4. Customize keybindings for your workflow

Remember: The goal is efficiency, not purity. If something is easier in shell, use shell!
