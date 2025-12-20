# git.nvim

git.nvim is an asynchronous git command wrapper plugin, using `:Git` command instead of `:!git`.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/git.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/git.nvim)](https://github.com/wsdjeg/git.nvim/releases)

<!-- vim-markdown-toc GFM -->

- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [⚙️ Basic Usage](#-basic-usage)
    - [git-add](#git-add)
    - [git-branch](#git-branch)
- [🎨 Statusline](#-statusline)
- [🔍 Picker source](#-picker-source)
- [📣 Self-Promotion](#-self-promotion)
- [💬 Feedback](#-feedback)

<!-- vim-markdown-toc -->

## ✨ Features

- **Asynchronous Git commands** — Run Git commands via `:Git` without blocking Neovim UI.
- **Full Git coverage** — Status, add, commit, push/pull, fetch, diff, branch, log, reflog, rebase, and more.
- **Branch Manager UI** — Interactive branch list with key mappings for checkout, delete, log, and diff.
- **Picker.nvim sources** — Includes fuzzy finder sources like `git-branch` for quick branch switching.
- **Statusline integration** — Easily display current branch in your statusline via Lua API.

## 📦 Installation

Use your preferred Neovim plugin manager to install git.nvim.

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
    {
        'wsdjeg/git.nvim',
        depends = {
            { 'wsdjeg/job.nvim' },
            { 'wsdjeg/notify.nvim' },
        },
    },
})
```

Then use `:PlugInstall git.nvim` to install this plugin.

Using [luarocks](https://luarocks.org/)

```
luarocks install --server=https://luarocks.org/manifests/wsdjeg git.nvim
```

## ⚙️ Basic Usage

Use `:Git` to execute `git` commands directly inside Neovim,
with behavior identical to the git command-line tool.
It supports command and argument completion,
runs git commands asynchronously without blocking the UI,
and opens commit messages and rebase messages in split windows
for a native, in-editor editing experience.

The plugin does not provide default key binding, here is an example:

```lua
vim.keymap.set('n', '<leader>gs', '<cmd>Git status<cr>', { silent = true })
vim.keymap.set('n', '<leader>gA', '<cmd>Git add .<cr>', { silent = true })
vim.keymap.set('n', '<leader>gc', '<cmd>Git commit<cr>', { silent = true })
vim.keymap.set('n', '<leader>gv', '<cmd>Git log<cr>', { silent = true })
vim.keymap.set('n', '<leader>gV', '<cmd>Git log %<cr>', { silent = true })
vim.keymap.set('n', '<leader>gp', '<cmd>Git push<cr>', { silent = true })
vim.keymap.set('n', '<leader>gd', '<cmd>Git diff<cr>', { silent = true })
```

### git-add

just same as `git add <path>`, `%` will be replaced as current file.

### git-branch

`:Git branch` without argument will open branch manager, within the branch manager these key bindings are available:

| key binding | description                                                  |
| ----------- | ------------------------------------------------------------ |
| `dd`        | delete branch under cursor                                   |
| `<Enter>`   | checkout branch under cursor                                 |
| `v`         | view git log of branch under cursor                          |
| `f`         | view git diff between current branch and branch under cursor |

## 🎨 Statusline

If you want to display branch info on statusline, you can use `v:lua.require("git.command.branch").current()`, for example:

using [statusline.nvim](https://github.com/wsdjeg/statusline.nvim):

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

To display unicode spinners on statusline. You need to use git.nvim together with [utils.nvim](https://github.com/wsdjeg/utils.nvim): 

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
    dev = true,
}
```

![Image](https://github.com/user-attachments/assets/3ae8bc49-1e0a-40fb-b3f9-25cbd9fd956c)

## 🔍 Picker source

This plugin also provides sources for [picker.nvim](https://github.com/wsdjeg/picker.nvim)

- `git-branch`: fuzzy find git branch to checkout
- `git-ghosts`: fuzzy find deleted files

## 📣 Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg)

## 💬 Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/git.nvim/issues)
