# git.nvim

git.nvim is an asynchronous git command wrapper plugin for Neovim, using `:Git` command instead of blocking `:!git`.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/git.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/git.nvim)](https://luarocks.org/modules/wsdjeg/git.nvim)

<!-- vim-markdown-toc GFM -->

- [✨ Features](#-features)
- [📦 Installation](#-installation)
    - [Prerequisites](#prerequisites)
    - [Using nvim-plug](#using-nvim-plug)
    - [Using lazy.nvim](#using-lazynvim)
    - [Using luarocks](#using-luarocks)
- [⚙️ Basic Usage](#-basic-usage)
    - [Git Commands](#git-commands)
    - [git-add](#git-add)
    - [git-blame](#git-blame)
    - [git-branch](#git-branch)
    - [git-rm](#git-rm)
    - [git-remote](#git-remote)
    - [git-status](#git-status)
    - [git-log](#git-log)
    - [git-diff](#git-diff)
    - [git-push/pull](#git-pushpull)
- [🎨 Statusline Integration](#-statusline-integration)
- [🔍 Picker Integration](#-picker-integration)
    - [Available Sources](#available-sources)
    - [Usage Example](#usage-example)
- [❓ FAQ](#-faq)
    - [How is this different from other Git plugins?](#how-is-this-different-from-other-git-plugins)
    - [Does it support all Git commands?](#does-it-support-all-git-commands)
    - [Can I use partial Git command flags?](#can-i-use-partial-git-command-flags)
    - [How do I view git diff for current file?](#how-do-i-view-git-diff-for-current-file)
    - [How does conflict detection work?](#how-does-conflict-detection-work)
    - [Can I use this with other Git plugins?](#can-i-use-this-with-other-git-plugins)
    - [Where are commit messages edited?](#where-are-commit-messages-edited)
- [📣 Self-Promotion](#-self-promotion)
- [💬 Feedback](#-feedback)
- [📄 License](#-license)

<!-- vim-markdown-toc -->

## ✨ Features

- **Asynchronous Git Commands** — Run Git commands via `:Git` without blocking Neovim UI, powered by `job.nvim`
- **Full Git Coverage** — Support for 26+ Git commands including status, add, commit, push/pull, fetch, diff, branch, log, reflog, rebase, stash, tag, cherry-pick, and more
- **Interactive Branch Manager** — Visual branch list with key mappings for checkout, delete, view log, and diff operations
- **Remote Repository Browser** — Side panel to browse remote repositories and their branches with fetch support
- **Git Blame Integration** — Line-by-line blame view with history navigation (view previous versions)
- **Git Log Viewer** — Commit history with graph visualization and commit details preview
- **Picker.nvim Integration** — Fuzzy finder sources for branch switching (`git-branch`) and finding deleted files (`git-ghosts`)
- **Statusline Integration** — Easy branch display with optional push/pull status indicators
- **Command Completion** — Intelligent completion for Git commands, branches, remotes, and file paths
- **Conflict Detection** — Automatic quickfix list for merge conflicts during pull
- **Split Window Editing** — Commit messages, rebase todos, and merge messages open in split windows
- **No Default Key Bindings** — Full control over your workflow without imposed mappings

## 📦 Installation

### Prerequisites

1. **System Dependencies**:
   - **Git** (required): Version 2.0 or higher
   - **Neovim**: Version 0.9.0 or higher

   Install Git with your package manager:

   ```bash
   # Ubuntu/Debian
   sudo apt install git

   # macOS
   brew install git

   # Arch Linux
   sudo pacman -S git
   ```

2. **Neovim Plugin Dependencies**:
   - [`job.nvim`](https://github.com/wsdjeg/job.nvim): **Required** for asynchronous operations
   - [`notify.nvim`](https://github.com/wsdjeg/notify.nvim): **Recommended** for notifications
   - [`picker.nvim`](https://github.com/wsdjeg/picker.nvim): **Optional** for fuzzy finder integration
   - [`utils.nvim`](https://github.com/wsdjeg/utils.nvim): **Optional** for statusline spinners

### Using [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
    {
        'wsdjeg/git.nvim',
        depends = {
            { 'wsdjeg/job.nvim' },      -- Required
            { 'wsdjeg/notify.nvim' },   -- Recommended
        },
    },
})
```

Then use `:PlugInstall git.nvim` to install this plugin.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'wsdjeg/git.nvim',
    dependencies = {
        'wsdjeg/job.nvim',       -- Required
        'wsdjeg/notify.nvim',    -- Recommended
    },
    config = function()
        -- Optional configuration
    end,
}
```

### Using [luarocks](https://luarocks.org/)

```bash
luarocks install --server=https://luarocks.org/manifests/wsdjeg git.nvim
```

## ⚙️ Basic Usage

Use `:Git` to execute git commands directly inside Neovim. The behavior is identical to the git command-line tool with these enhancements:

- **Asynchronous execution** — No UI blocking
- **Command completion** — Tab completion for commands and arguments
- **Split window editing** — Commit messages and rebase todos open in splits
- **Visual interfaces** — Branch manager, remote browser, log viewer, blame view
- **No default key bindings** — Full control over your workflow

### Git Commands

git.nvim supports the following Git commands:

| Command         | Description                                    | Features                                      |
| --------------- | ---------------------------------------------- | --------------------------------------------- |
| `:Git add`      | Add file contents to the index                 | File path completion, `%` for current file    |
| `:Git blame`    | Show what revision and author modified lines   | Interactive history navigation                |
| `:Git branch`   | List, create, or delete branches               | Branch manager UI with key bindings           |
| `:Git checkout` | Switch branches or restore working tree files  | Branch completion                             |
| `:Git cherry-pick` | Apply changes from existing commits          | Commit hash completion                        |
| `:Git clean`    | Remove untracked files from working tree       | Preview support                               |
| `:Git commit`   | Record changes to the repository               | Split window for commit message editing       |
| `:Git config`   | Get and set repository or global options       | Configuration completion                      |
| `:Git diff`     | Show changes between commits, working tree, etc| Split window with syntax highlighting         |
| `:Git fetch`    | Download objects and refs from remote          | Remote completion                             |
| `:Git log`      | Show commit logs                               | Graph view, commit details preview            |
| `:Git merge`    | Join two or more development histories         | Branch completion, conflict detection         |
| `:Git mv`       | Move or rename a file, directory, or symlink   | File path completion                          |
| `:Git pull`     | Fetch from and integrate with remote branch    | Conflict detection, quickfix list             |
| `:Git push`     | Update remote refs along with objects          | Remote and branch completion                  |
| `:Git rebase`   | Reapply commits on top of another base tip     | Split window for rebase todo editing          |
| `:Git reflog`   | Manage reflog information                      | View reference logs                           |
| `:Git remote`   | Manage set of tracked repositories             | Remote browser UI with branch list            |
| `:Git reset`    | Reset current HEAD to the specified state      | Commit hash completion                        |
| `:Git rm`       | Remove files from working tree and index       | File path completion                          |
| `:Git shortlog` | Summarize 'git log' output                     | Summary of commit activity                     |
| `:Git show`     | Show various types of objects                  | Commit, tag, tree, blob viewer                |
| `:Git stash`    | Stash changes in a dirty working directory     | Stash list management                         |
| `:Git status`   | Show the working tree status                   | Top split window with status                  |
| `:Git tag`      | Create, list, delete or verify a tag object    | Tag completion                                |
| `:Git grep`     | Print lines matching a pattern                 | Search in repository                          |
| `:Git update-index` | Register file contents to the index         | Index management                              |

**Example Key Bindings:**

```lua
vim.keymap.set('n', '<leader>gs', '<cmd>Git status<cr>', { silent = true })
vim.keymap.set('n', '<leader>gA', '<cmd>Git add .<cr>', { silent = true })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>', { silent = true })
vim.keymap.set('n', '<leader>gv', '<cmd>Git log<cr>', { silent = true })
vim.keymap.set('n', '<leader>gV', '<cmd>Git log %<cr>', { silent = true })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<cr>', { silent = true })
vim.keymap.set('n', '<leader>gP', '<cmd>Git pull<cr>', { silent = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Git diff<cr>', { silent = true })
vim.keymap.set('n', '<leader>gS', '<cmd>Git stash<cr>', { silent = true })
vim.keymap.set('n', '<leader>gB', '<cmd>Git blame<cr>', { silent = true })
vim.keymap.set('n', '<leader>gR', '<cmd>Git remote<cr>', { silent = true })
```

### git-add

Add file contents to the index. Same as `git add <path>`, with `%` being replaced by the current file.

**Examples:**

```vim
:Git add .          " Add all changes
:Git add %          " Add current file
:Git add src/       " Add all changes in src/ directory
:Git add -p         " Add interactively
```

### git-blame

Show the revision and author that last modified each line of a file, displayed in a tab with split windows for easy inspection.

**Features:**

- Line-by-line blame information in left panel
- Original file content in right panel
- Navigate through file history
- Compare different versions

**Key Bindings in Blame Window:**

| Key Binding | Description                              |
| ----------- | ---------------------------------------- |
| `<Enter>`   | Open previous version of current line    |
| `<BS>`      | Switch back to newer version (go back)   |
| `q`         | Close blame window                       |

**Usage:**

```vim
:Git blame           " Blame current file
:Git blame README.md " Blame specific file
:Git blame HEAD~5    " Blame at specific commit
```

### git-branch

List, create, or delete branches. Running `:Git branch` without arguments opens the branch manager in a left split window.

**Branch Manager Features:**

- Visual branch list in split window
- Shows current branch with `*` marker
- Local branches listed under "local" section
- Remote branches grouped by remote name
- Interactive operations with key bindings

**Branch Manager Key Bindings:**

| Key Binding | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `dd`        | Delete branch under cursor                                   |
| `<Enter>`   | Checkout branch under cursor                                 |
| `v`         | View git log of branch under cursor                          |
| `f`         | View git diff between current branch and branch under cursor |

**Examples:**

```vim
:Git branch              " Open branch manager
:Git branch feature-x    " Create new branch
:Git branch -d feature-x " Delete branch
:Git branch -a           " List all branches (including remote)
```

### git-rm

Remove files from the working tree and from the index. Supports file name completion after `:Git rm ` command.

**Examples:**

```vim
:Git rm filename.txt     " Remove file
:Git rm -r directory/    " Remove directory
:Git rm --cached file    " Remove from index only
:Git rm %                " Remove current file
```

### git-remote

Manage set of tracked repositories. Running `:Git remote` without arguments opens a remote browser sidebar.

**Remote Browser Features:**

- Visual remote repository list
- Browse remote branches for each remote
- Fetch remote updates
- View remote branch logs
- Auto-update branch list with spinner indicator

**Remote Browser Key Bindings:**

| Key Binding | Description                              |
| ----------- | ---------------------------------------- |
| `q`         | Close remote window                      |
| `<Enter>`   | View git log of selected remote branch   |
| `f`         | Fetch remote under cursor                |
| `o`         | Toggle remote branch list (expand/collapse) |
| `?`         | Toggle help information                  |

![git-remote-ui](https://github.com/user-attachments/assets/68b683e8-e496-420f-80af-a22551de1613)

**Examples:**

```vim
:Git remote                    " Open remote browser
:Git remote add origin <url>   " Add remote
:Git remote -v                 " List remotes verbose
:Git remote remove origin      " Remove remote
```

### git-status

Show the working tree status in a top split window. The status window provides a clear view of changes in your repository.

**Features:**

- Opens in top split window (height: 10 lines)
- Shows staged, unstaged, and untracked files
- Read-only buffer with easy navigation
- Press `q` to close

**Examples:**

```vim
:Git status        " Show repository status
:Git status -s     " Short format
```

### git-log

Show commit logs with enhanced visualization. Opens in a new buffer with commit graph.

**Features:**

- Commit graph with branch visualization
- Color-coded output (red commit hash, green author/date)
- Press `<Enter>` to view commit details in split window
- Relative dates for better readability
- Support for file-specific history

**Key Bindings in Log Window:**

| Key Binding | Description                              |
| ----------- | ---------------------------------------- |
| `<Enter>`   | Show commit details in right split       |
| `q`         | Close log window                         |

**Examples:**

```vim
:Git log           " Show all commits with graph
:Git log %         " Show commits for current file
:Git log --oneline " Compact one-line format
:Git log -10       " Show last 10 commits
:Git log --decorate " Show with branch tags
:Git log branch-name " Show commits for specific branch
```

### git-diff

Show changes between commits, commit and working tree, etc. Opens in a split window with syntax highlighting.

**Features:**

- Split window with diff syntax highlighting
- Support for comparing specific files
- Press `q` to close

**Examples:**

```vim
:Git diff           " Show all unstaged changes
:Git diff %         " Show changes for current file
:Git diff --cached  " Show staged changes
:Git diff HEAD~5    " Compare with specific commit
:Git diff branch1 branch2 " Compare branches
```

### git-push/pull

Push to or pull from remote repositories with progress indication.

**Features:**

- Asynchronous execution with progress indicator (requires utils.nvim)
- Pull conflict detection with quickfix list
- Remote and branch completion
- Statusline spinner integration

**Examples:**

```vim
:Git push                    " Push to default remote
:Git push origin main        " Push to specific remote/branch
:Git push -u origin feature  " Push and set upstream
:Git pull                    " Pull from default remote
:Git pull origin main        " Pull from specific remote/branch
```

**Conflict Handling:**

When pulling results in merge conflicts, git.nvim automatically:
1. Detects conflict files
2. Opens quickfix list with conflict file locations
3. Shows notification about merge conflicts

## 🎨 Statusline Integration

Display current branch information in your statusline using the Lua API.

**Basic Example:**

```lua
-- Get current branch name
local branch = require('git.command.branch').current()
```

**Using with [statusline.nvim](https://github.com/wsdjeg/statusline.nvim):**

```lua
require('plug').add({
  {
    'wsdjeg/statusline.nvim',
    events = { 'VimEnter' },
    config = function()
      require('statusline').register_sections('vcs', function()
        return '%{ v:lua.require("git.command.branch").current() }'
      end)
      require('statusline').setup({
        left_sections = { 'winnr', 'filename', 'vcs' },
      })
    end,
  },
})
```

**Advanced Example with Push/Pull Status:**

To display unicode spinners on statusline during push/pull operations, use git.nvim together with [utils.nvim](https://github.com/wsdjeg/utils.nvim):

```lua
return {
    'wsdjeg/statusline.nvim',
    events = { 'VimEnter' },
    config = function()
        require('statusline').register_sections('vcs', function()
            return '%{ v:lua.require("git.command.branch").current() .. v:lua.require("git.command.pull").status() .. v:lua.require("git.command.push").status() }'
        end)
        require('statusline').setup({
            left_sections = { 'winnr', 'filename', 'major mode', 'syntax checking', 'vcs' },
            right_sections = { 'fileformat', 'fileencoding', 'cursorpos' },
        })
    end,
    type = 'rocks',
    desc = 'module statusline',
}
```

**API Functions:**

- `require('git.command.branch').current()` — Returns current branch name with optional prefix
- `require('git.command.branch').detect()` — Force update branch name
- `require('git.command.push').status()` — Returns push spinner status (requires utils.nvim)
- `require('git.command.pull').status()` — Returns pull spinner status (requires utils.nvim)

![Statusline Example](https://github.com/user-attachments/assets/3ae8bc49-1e0a-40fb-b3f9-25cbd9fd956c)

## 🔍 Picker Integration

git.nvim provides built-in picker sources for [picker.nvim](https://github.com/wsdjeg/picker.nvim) integration:

### Available Sources

1. **`git-branch`** — Fuzzy find and checkout git branches

   - Quick branch switching
   - Preview branch information
   - Delete branches from picker

   ```vim
   :Picker git-branch
   ```

2. **`git-ghosts`** — Fuzzy find deleted files in repository history

   - Find files that were deleted
   - Useful for recovering lost work
   - View commit that deleted the file

   ```vim
   :Picker git-ghosts
   ```

### Usage Example

```lua
-- Add key bindings for picker sources
vim.keymap.set('n', '<leader>gb', '<cmd>Picker git-branch<cr>', { silent = true })
vim.keymap.set('n', '<leader>gG', '<cmd>Picker git-ghosts<cr>', { silent = true })
```

## ❓ FAQ

### How is this different from other Git plugins?

git.nvim focuses on being a **thin asynchronous wrapper** around Git commands, providing:

- **Native Git command syntax** — No need to learn new commands, use standard Git commands
- **Asynchronous execution** — Non-blocking UI powered by job.nvim
- **Visual interfaces** — Branch manager, remote browser, log viewer, blame view
- **Command completion** — Intelligent tab completion for commands, branches, remotes, and files
- **Zero default key bindings** — You're in control of your workflow
- **Lightweight** — Minimal dependencies and overhead

### Does it support all Git commands?

Yes! git.nvim supports 26+ Git commands including:
- **Basic**: `add`, `commit`, `push`, `pull`, `fetch`, `status`, `diff`
- **Branching**: `branch`, `checkout`, `merge`, `rebase`, `cherry-pick`
- **History**: `log`, `blame`, `show`, `reflog`, `shortlog`
- **Staging**: `reset`, `rm`, `mv`, `clean`, `update-index`, `stash`
- **Remote**: `remote`, `tag`, `grep`, `config`

### Can I use partial Git command flags?

Yes! git.nvim passes all arguments directly to Git, so any Git flag or option is supported:

```vim
:Git log --oneline --graph --all
:Git commit --amend --no-edit
:Git push -f origin main
:Git diff HEAD~5 HEAD --stat
```

### How do I view git diff for current file?

```vim
:Git diff %        " Diff current file against index
:Git diff --cached " Diff staged changes
:Git diff HEAD     " Diff against HEAD commit
```

### How does conflict detection work?

When running `:Git pull`, git.nvim automatically:
1. Monitors for merge conflict messages
2. Detects files with conflict markers
3. Opens quickfix list with conflict file locations
4. Shows notification about conflicts

### Can I use this with other Git plugins?

Absolutely! git.nvim is designed to complement other Git plugins without conflicts. It focuses on command execution while other plugins may provide additional features like git signs, blame virtual text, etc.

### Where are commit messages edited?

Commit messages, rebase todos, and merge messages open in split windows within Neovim, providing a native editing experience without leaving the editor.

## 📣 Self-Promotion

Like this plugin? Star the repository on [GitHub](https://github.com/wsdjeg/git.nvim).

Love this plugin? Follow [me](https://wsdjeg.net/) on [GitHub](https://github.com/wsdjeg).

## 💬 Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/git.nvim/issues).

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.
