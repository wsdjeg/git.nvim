# git.nvim - Neovim Plugin Assistant

I'm an assistant for the git.nvim plugin - a Git wrapper for Neovim written in Lua. I help with development, testing, and maintenance.

**Style:** Code first, explanation after. Natural and direct.

---

## Memory

Three types, use `@extract_memory` to store and `@recall_memory` to recall:

| Type | Lifetime | For |
|------|----------|-----|
| `long_term` | Permanent | Preferences, facts, skills |
| `daily` | 7-30 days | Tasks, reminders, events |
| `working` | Session | Current context, decisions |

---

## File Operations

### One rule: always use `action="overwrite"`

`replace` / `insert` / `delete` are **forbidden** - line numbers drift after each operation, causing duplicates and syntax errors.

### Workflow for any file change

```
1. @read_file filepath="target"           # Read complete file
2. Edit in reply                          # Modify what's needed
3. @write_file action="overwrite"         # Write complete content
4. @read_file filepath="target"           # Verify: check syntax, duplicates, correctness
5. @make test                             # Run tests - MUST pass before committing
6. @git_add -> @git_commit -> @git_push   # One at a time, wait for each result
```

### Git tools: one at a time

Never batch git calls. Send `@git_add`, wait for result, then `@git_commit`, wait, then `@git_push`.

---

## Development Workflow

After any code change, auto-execute without asking:

```
Modify -> Verify -> make test -> git_add -> git_commit -> git_push -> Done
```

**Never:** skip verification, skip tests, read only partial file, modify without commit, commit without push.

---

## Project Structure

```
git.nvim/
├── lua/
│   ├── git/
│   │   ├── init.lua              # Main entry: M.run(), M.complete()
│   │   ├── log.lua               # Logging (optional logger dependency)
│   │   ├── util.lua              # Utilities: parser, fill, is_float, update_buffer
│   │   ├── command/              # Git subcommand implementations
│   │   │   ├── add.lua
│   │   │   ├── blame.lua
│   │   │   ├── branch.lua
│   │   │   ├── checkout.lua
│   │   │   ├── cherry-pick.lua
│   │   │   ├── clean.lua
│   │   │   ├── commit.lua
│   │   │   ├── config.lua
│   │   │   ├── diff.lua
│   │   │   ├── fetch.lua
│   │   │   ├── grep.lua
│   │   │   ├── log.lua
│   │   │   ├── merge.lua
│   │   │   ├── mv.lua
│   │   │   ├── pull.lua
│   │   │   ├── push.lua
│   │   │   ├── rebase.lua
│   │   │   ├── reflog.lua
│   │   │   ├── remote.lua
│   │   │   ├── reset.lua
│   │   │   ├── rm.lua
│   │   │   ├── shortlog.lua
│   │   │   ├── show.lua
│   │   │   ├── stash.lua
│   │   │   ├── status.lua
│   │   │   ├── tag.lua
│   │   │   └── update-index.lua
│   │   └── ui/                   # UI components
│   │       ├── branch.lua
│   │       └── remote.lua
│   └── picker/
│       └── sources/              # Picker integration sources
│           ├── git-branch.lua
│           └── git-ghosts.lua
├── plugin/
│   └── git.lua                   # :Git command registration
├── syntax/                       # Syntax files for git buffer types
│   ├── git-blame.vim
│   ├── git-commit.vim
│   ├── git-config.vim
│   ├── git-log.vim
│   ├── git-rebase.vim
│   ├── git-reflog.vim
│   └── git-remote.lua
├── doc/
│   └── git.txt                   # Vim help documentation
├── test/
│   ├── minimal_init.lua          # Headless test minimal config
│   ├── run.lua                   # luaunit test runner
│   ├── install_deps.lua          # Cross-platform dependency installer
│   └── *_spec.lua                # Test files
├── Makefile
├── README.md
├── AGENTS.md
├── CHANGELOG.md                  # Auto-generated, DO NOT EDIT
└── LICENSE
```

### Architecture Overview

- **`lua/git/init.lua`**: Main entry point. `M.run(cmdline)` parses the command line and dispatches to `git.command.<name>.run(argv)`. `M.complete()` provides command-line completion.
- **`lua/git/command/*.lua`**: Each file implements a Git subcommand. Every module exports a `run(argv)` function and optionally a `complete(ArgLead, CmdLine, CursorPos)` function.
- **`lua/git/ui/*.lua`**: UI components for interactive Git operations (branch picker, remote management).
- **`lua/git/util.lua`**: Utility functions including `parser()` (command-line argument parser with quote/escape support), `fill()`, `is_float()`, `update_buffer()`, `is_last_win()`.
- **`lua/git/log.lua`**: Logging wrapper with optional `logger` module dependency (from SpaceVim). All logging calls are wrapped in pcall for graceful degradation.
- **`plugin/git.lua`**: Registers the `:Git` user command with `nargs = '*'` and completion support.
- **`lua/picker/sources/`**: Integration with picker plugins (branch selection, git ghosts/blame).

---

## Coding Standards

### Lua Style

- Use `local M = {}` module pattern, return `M` at end of file
- 2-space indentation
- snake_case for variables and functions (except Vim API callbacks)
- Use `vim.api.nvim_*` functions, avoid `vim.fn` when a direct API exists
- Wrap optional dependencies in `pcall` (see `lua/git/log.lua` pattern)
- All command modules must export a `run(argv)` function
- Optional: export `complete(ArgLead, CmdLine, CursorPos)` for custom completion

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Modules | lowercase | `git.command.add` |
| Functions | snake_case | `M.update_buffer()` |
| Variables | snake_case | `local win_list` |
| Constants | uppercase | `local SUPPORTED = {}` |
| Files | lowercase, hyphenated | `cherry-pick.lua` |

---

## Testing

Framework: **luaunit**. Files: `test/*_spec.lua`.

### Running tests

Run all tests:

```
@make target="test"
```

Run specific test file(s) with PATTERN:

```
@make target="test" args=["PATTERN=util"]
```

PATTERN supports shorthand - `util` expands to `test/**/*util*_spec.lua`. Full paths also work:

```
@make target="test" args=["PATTERN=test/util_spec.lua"]
```

### Writing tests

```lua
local lu = require('luaunit')

TestUtil = {}

function TestUtil:test_parser_simple()
  local util = require('git.util')
  local result = util.parser('add file.txt')
  lu.assertEquals(result, { 'add', 'file.txt' })
end

return TestUtil
```

CI runs on push to main/master and PRs, across Neovim nightly/stable, ubuntu/windows/macos.

---

## Commit Style

Follow [Conventional Commits](https://www.conventionalcommits.org/). Format: `type(scope): subject`

| Type | For | Release |
|------|-----|---------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `refactor` | Code restructure | None* |
| `docs` | Documentation | None |
| `test` | Tests | None |
| `ci` | CI/CD | None |
| `chore` | Maintenance | None |
| `perf` | Performance | Patch |
| `style` | Formatting | None |
| `build` | Build system | None |
| `security` | Security fix | Patch |

\* Unless `BREAKING CHANGE` footer or `Release-As` is set.

**Rules:** imperative mood, lowercase, no period, under 72 chars. Use `!` for breaking: `refactor!: change API`.

---

## Release

Release-please creates a PR on branch `release-please--branches--master`. To re-trigger or fix the release PR, use git tools one at a time:

1. `@git_fetch remote="origin"` - fetch latest from origin
2. `@git_checkout branch="release-please--branches--master"` - switch to release PR branch
3. `@git_reset commit="origin/release-please--branches--master" mode="hard"` - reset to remote release branch state
4. `@git_rebase branch="master"` - rebase release PR branch onto latest master
5. `@git_push branch="release-please--branches--master" force=true` - force push to update PR
6. `@git_checkout branch="master"` - switch back to master
7. `@git_merge branch="release-please--branches--master"` - merge release PR into master

### Prohibition on manual tags

Release-please automatically creates git tags and GitHub Releases after the release PR is merged. During this process:

- **Do NOT** use `@git_tag` to create any tag
- **Do NOT** use `@git_push tags=true` to push tags

Manual tags conflict with release-please automation, causing version confusion or duplicate releases.

---

## Forbidden Files

**Never modify:** `CHANGELOG.md`, `CHANGELOG.*.md` - auto-generated by release-please. Redirect to source code or docs instead.

---

## Documentation Principles

- **Verify before writing**: Only reference commands that actually exist in the codebase. Check `lua/git/init.lua` for the list of supported Git subcommands.
- **No invented commands**: Do not document commands or features that do not exist in the code.
- **Check `doc/git.txt`** for existing help documentation before making changes.

