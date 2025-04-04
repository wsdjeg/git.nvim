# git.nvim

git.nvim is a plugin to use git command in Neovim.

<!-- vim-markdown-toc GFM -->

* [Installation](#installation)
* [Usage](#usage)
* [Self-Promotion](#self-promotion)
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
      { 'wsdjeg/logger.nvim' }, -- not strictly required
      { 'wsdjeg/rooter.nvim' }, -- not strictly required
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

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg) and
[Twitter](http://twitter.com/wsdtty).

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/git.nvim/issues)
If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/git.nvim/issues)
