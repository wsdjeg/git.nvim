# git.nvim

> _git.nvim_ is a plugin to use _git_ command in neovim.

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Usage](#usage)
* [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Installation

Use your preferred Neovim plugin manager to install git.nvim.

with [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
  {
    'wsdjeg/git.nvim',
    depends = {
      { 'wsdjeg/job.nvim' },
      { 'wsdjeg/notify.nvim' },
      { 'wsdjeg/logger.nvim' },
    },
  },
})
```

Then use `:PlugInstall git.nvim` to install this plugin.

## Usage

- `:Git add %`: stage current file.
- `:Git add .`: stage all files
- `:Git commit`: edit commit message
- `:Git push`: push to remote
- `:Git pull`: pull updates from remote
- `:Git fetch`: fetch remotes
- `:Git checkout`: checkout branches
- `:Git log %`: view git log of current file
- `:Git config`: list all git config
- `:Git reflog`: manage reflog information
- `:Git branch`: list, create, or delete branches
- `:Git rebase`: rebase git commit
- `:Git diff`: view git-diff info

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/git.nvim/issues)
