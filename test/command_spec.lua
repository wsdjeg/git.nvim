-- test/command_spec.lua
-- Tests for all git.command.* modules: loading, run(), and complete()

local lu = require('luaunit')

TestCommand = {}

function TestCommand:setUp()
  self.job = require('job')
  self.notify = require('notify')
  self.job.reset()
  self.notify.reset()
end

function TestCommand:tearDown()
  vim.cmd('silent! only')
end

-- ======================
-- Module loading tests
-- ======================

function TestCommand:test_all_modules_load()
  local commands = {
    'add', 'blame', 'branch', 'checkout', 'cherry-pick', 'clean',
    'commit', 'config', 'diff', 'fetch', 'grep', 'log', 'merge',
    'mv', 'pull', 'push', 'rebase', 'reflog', 'remote', 'reset',
    'rm', 'shortlog', 'show', 'stash', 'status', 'tag', 'update-index',
  }
  for _, cmd in ipairs(commands) do
    local ok, mod = pcall(require, 'git.command.' .. cmd)
    lu.assertTrue(ok, 'Failed to load git.command.' .. cmd)
    lu.assertIsFunction(mod.run, 'git.command.' .. cmd .. '.run is not a function')
  end
end

function TestCommand:test_complete_functions_exist()
  local with_complete = {
    'add', 'branch', 'checkout', 'fetch', 'log',
    'merge', 'push', 'rebase', 'reset', 'rm', 'stash', 'tag',
  }
  for _, cmd in ipairs(with_complete) do
    local mod = require('git.command.' .. cmd)
    lu.assertIsFunction(mod.complete,
      'git.command.' .. cmd .. '.complete is not a function')
  end
end

-- =========================
-- Command building: add
-- =========================

function TestCommand:test_add_run()
  local add = require('git.command.add')
  add.run({ 'file.txt' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'add', 'file.txt' })
end

function TestCommand:test_add_run_multiple_files()
  local add = require('git.command.add')
  add.run({ 'file1.txt', 'file2.txt' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'add', 'file1.txt', 'file2.txt' })
end

function TestCommand:test_add_run_no_args()
  local add = require('git.command.add')
  add.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'add' })
end

-- =========================
-- Command building: clean
-- =========================

function TestCommand:test_clean_run()
  local clean = require('git.command.clean')
  clean.run({ '-fd' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'clean', '-fd' })
end

-- =========================
-- Command building: fetch
-- =========================

function TestCommand:test_fetch_run()
  local fetch = require('git.command.fetch')
  fetch.run({ 'origin' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'fetch', 'origin' })
end

function TestCommand:test_fetch_run_no_args()
  local fetch = require('git.command.fetch')
  fetch.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'fetch' })
end

-- =========================
-- Command building: diff
-- =========================

function TestCommand:test_diff_run()
  local diff = require('git.command.diff')
  diff.run({ 'HEAD' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'diff', 'HEAD' })
end

function TestCommand:test_diff_run_percent()
  local diff = require('git.command.diff')
  diff.run({ '%' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'diff')
  lu.assertNotEquals(last.cmd[3], '%')
end

-- =========================
-- Command building: show
-- =========================

function TestCommand:test_show_run()
  local show = require('git.command.show')
  show.run({ 'HEAD' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'show', 'HEAD' })
end

-- =========================
-- Command building: blame
-- =========================

function TestCommand:test_blame_run()
  local blame = require('git.command.blame')
  blame.run({ 'file.txt' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd,
    { 'git', 'blame', '--line-porcelain', 'file.txt' })
end

function TestCommand:test_blame_run_no_args()
  local blame = require('git.command.blame')
  blame.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'blame')
  lu.assertEquals(last.cmd[3], '--line-porcelain')
  -- no args means it uses expand('%') for current file
  lu.assertEquals(#last.cmd, 4)
end

-- =========================
-- Command building: cherry-pick
-- =========================

function TestCommand:test_cherry_pick_no_args()
  local cp = require('git.command.cherry-pick')
  cp.run({})
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestCommand:test_cherry_pick_with_args()
  local cp = require('git.command.cherry-pick')
  cp.run({ 'abc123' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'cherry-pick', 'abc123' })
end

-- =========================
-- Command building: merge
-- =========================

function TestCommand:test_merge_no_args()
  local merge = require('git.command.merge')
  merge.run({})
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestCommand:test_merge_with_args()
  local merge = require('git.command.merge')
  merge.run({ 'feature' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'merge', 'feature' })
end

-- =========================
-- Command building: config
-- =========================

function TestCommand:test_config_no_args()
  local config = require('git.command.config')
  config.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'config', '--list' })
end

function TestCommand:test_config_with_args()
  local config = require('git.command.config')
  config.run({ 'user.name' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'config', 'user.name' })
end

-- =========================
-- Command building: mv
-- =========================

function TestCommand:test_mv_run()
  local mv = require('git.command.mv')
  mv.run({ 'old.txt', 'new.txt' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'mv', 'old.txt', 'new.txt' })
end

-- =========================
-- Command building: pull
-- =========================

function TestCommand:test_pull_run()
  local pull = require('git.command.pull')
  pull.run({ 'origin' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'pull', 'origin' })
end

function TestCommand:test_pull_status_returns_string()
  local pull = require('git.command.pull')
  lu.assertIsString(pull.status())
end

-- =========================
-- Command building: push
-- =========================

function TestCommand:test_push_run()
  local push = require('git.command.push')
  push.run({ 'origin', 'main' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'push', 'origin', 'main' })
end

function TestCommand:test_push_status_returns_string()
  local push = require('git.command.push')
  lu.assertIsString(push.status())
end

-- =========================
-- Command building: rebase
-- =========================

function TestCommand:test_rebase_run()
  local rebase = require('git.command.rebase')
  rebase.run({ '-i', 'HEAD~3' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertTrue(vim.tbl_contains(last.cmd, 'rebase'))
  lu.assertTrue(vim.tbl_contains(last.cmd, '-i'))
  lu.assertTrue(vim.tbl_contains(last.cmd, 'HEAD~3'))
end

-- =========================
-- Command building: reflog
-- =========================

function TestCommand:test_reflog_run()
  local reflog = require('git.command.reflog')
  reflog.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'reflog' })
end

-- =========================
-- Command building: reset
-- =========================

function TestCommand:test_reset_run()
  local reset = require('git.command.reset')
  reset.run({ 'HEAD' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'reset', 'HEAD' })
end

function TestCommand:test_reset_run_percent()
  local reset = require('git.command.reset')
  reset.run({ '%' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'reset')
  lu.assertEquals(last.cmd[3], 'HEAD')
  lu.assertNotEquals(last.cmd[4], '%')
end

-- =========================
-- Command building: rm
-- =========================

function TestCommand:test_rm_run()
  local rm = require('git.command.rm')
  rm.run({ 'file.txt' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'rm', 'file.txt' })
end

function TestCommand:test_rm_run_percent()
  local rm = require('git.command.rm')
  rm.run({ '%' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'rm')
  lu.assertNotEquals(last.cmd[3], '%')
end

-- =========================
-- Command building: stash
-- =========================

function TestCommand:test_stash_run()
  local stash = require('git.command.stash')
  stash.run({ 'list' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'stash', 'list' })
end

function TestCommand:test_stash_run_show()
  local stash = require('git.command.stash')
  stash.run({ 'show' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'stash', 'show' })
end

function TestCommand:test_stash_run_pop()
  local stash = require('git.command.stash')
  stash.run({ 'pop' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'stash', 'pop' })
end

-- =========================
-- Command building: tag
-- =========================

function TestCommand:test_tag_run()
  local tag = require('git.command.tag')
  tag.run({ '--list' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'tag', '--list' })
end

-- =========================
-- Command building: update-index
-- =========================

function TestCommand:test_update_index_run()
  local ui = require('git.command.update-index')
  ui.run({ '--refresh' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'update-index', '--refresh' })
end

-- =========================
-- Command building: grep
-- =========================

function TestCommand:test_grep_run()
  local grep = require('git.command.grep')
  grep.run({ 'TODO' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'grep', '-n', 'TODO' })
end

function TestCommand:test_grep_run_multiple_words()
  local grep = require('git.command.grep')
  grep.run({ 'hello', 'world' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'grep', '-n', 'hello world' })
end

-- =========================
-- Command building: shortlog
-- =========================

function TestCommand:test_shortlog_run_starts_two_jobs()
  local shortlog = require('git.command.shortlog')
  shortlog.run({})
  lu.assertEquals(self.job.get_call_count(), 2)
  local calls = self.job.get_calls()
  lu.assertEquals(calls[1].cmd[1], 'git')
  lu.assertEquals(calls[1].cmd[2], 'shortlog')
  lu.assertEquals(calls[2].cmd[1], 'git')
  lu.assertEquals(calls[2].cmd[2], 'log')
end

-- =========================
-- Command building: commit
-- =========================

function TestCommand:test_commit_run()
  local commit = require('git.command.commit')
  commit.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertTrue(vim.tbl_contains(last.cmd, 'commit'))
end

function TestCommand:test_commit_run_amend()
  local commit = require('git.command.commit')
  commit.run({ '--amend' })
  local last = self.job.get_last_call()
  lu.assertTrue(vim.tbl_contains(last.cmd, 'commit'))
  lu.assertTrue(vim.tbl_contains(last.cmd, '--amend'))
end

-- =========================
-- Command building: branch
-- =========================

function TestCommand:test_branch_run_with_args()
  local branch = require('git.command.branch')
  branch.run({ '-d', 'test-branch' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'branch')
  lu.assertTrue(vim.tbl_contains(last.cmd, '-d'))
  lu.assertTrue(vim.tbl_contains(last.cmd, 'test-branch'))
end

function TestCommand:test_branch_current_returns_string()
  local branch = require('git.command.branch')
  local result = branch.current()
  lu.assertIsString(result)
end

function TestCommand:test_branch_current_with_prefix()
  local branch = require('git.command.branch')
  local result = branch.current('on')
  lu.assertIsString(result)
end

function TestCommand:test_branch_detect()
  local branch = require('git.command.branch')
  branch.detect()
  lu.assertTrue(self.job.get_call_count() >= 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'rev-parse')
end

-- =========================
-- Command building: remote
-- =========================

function TestCommand:test_remote_run_with_args()
  local remote = require('git.command.remote')
  remote.run({ '-v' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'remote', '-v' })
end

-- =========================
-- Command building: checkout
-- =========================

function TestCommand:test_checkout_run()
  local checkout = require('git.command.checkout')
  checkout.run({ 'main' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'checkout', 'main' })
end

function TestCommand:test_checkout_run_no_args()
  local checkout = require('git.command.checkout')
  checkout.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'checkout' })
end

-- =========================
-- Command building: log
-- =========================

function TestCommand:test_log_run()
  local log = require('git.command.log')
  log.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'log')
  lu.assertTrue(vim.tbl_contains(last.cmd, '--graph'))
  lu.assertTrue(vim.tbl_contains(last.cmd, '--date=relative'))
end

function TestCommand:test_log_run_with_args()
  local log = require('git.command.log')
  log.run({ '--oneline' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'log')
  lu.assertTrue(vim.tbl_contains(last.cmd, '--oneline'))
end

-- =========================
-- Command building: status
-- =========================

function TestCommand:test_status_run()
  local status = require('git.command.status')
  status.run({})
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'status')
end

function TestCommand:test_status_run_with_args()
  local status = require('git.command.status')
  status.run({ '-s' })
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'status', '-s' })
end

-- =========================
-- Complete: fetch
-- =========================

function TestCommand:test_fetch_complete_options()
  local fetch = require('git.command.fetch')
  local result = fetch.complete('--p', 'Git fetch --p', 13)
  lu.assertTrue(vim.tbl_contains(result, '--prune'))
  lu.assertTrue(vim.tbl_contains(result, '--prune-tags'))
end

function TestCommand:test_fetch_complete_all_options()
  local fetch = require('git.command.fetch')
  local result = fetch.complete('--', 'Git fetch --', 11)
  lu.assertTrue(#result > 0)
  lu.assertTrue(vim.tbl_contains(result, '--prune'))
  lu.assertTrue(vim.tbl_contains(result, '--all'))
end

-- =========================
-- Complete: checkout
-- =========================

function TestCommand:test_checkout_complete_dash()
  local checkout = require('git.command.checkout')
  local result = checkout.complete('-', 'Git checkout -', 13)
  lu.assertEquals(result, '-b\n-m')
end

-- =========================
-- Complete: branch
-- =========================

function TestCommand:test_branch_complete_dash()
  local branch = require('git.command.branch')
  local result = branch.complete('-d', 'Git branch -d', 13)
  lu.assertEquals(result, '-d\n-D')
end

-- =========================
-- Complete: stash
-- =========================

function TestCommand:test_stash_complete_list()
  local stash = require('git.command.stash')
  local result = stash.complete('li', 'Git stash li', 12)
  lu.assertEquals(result, { 'list' })
end

function TestCommand:test_stash_complete_show()
  local stash = require('git.command.stash')
  local result = stash.complete('sh', 'Git stash sh', 12)
  lu.assertEquals(result, { 'show' })
end

function TestCommand:test_stash_complete_s_prefix()
  local stash = require('git.command.stash')
  local result = stash.complete('s', 'Git stash s', 11)
  lu.assertEquals(result, { 'show', 'save' })
end

function TestCommand:test_stash_complete_no_match()
  local stash = require('git.command.stash')
  local result = stash.complete('', 'Git stash ', 10)
  lu.assertEquals(result, {})
end

-- =========================
-- Complete: tag
-- =========================

function TestCommand:test_tag_complete_dash()
  local tag = require('git.command.tag')
  local result = tag.complete('-', 'Git tag -', 9)
  lu.assertEquals(result, { '--list', '-l', '-m', '-a', '-d' })
end

-- =========================
-- Complete: rebase
-- =========================

function TestCommand:test_rebase_complete()
  local rebase = require('git.command.rebase')
  local result = rebase.complete('-', 'Git rebase -', 12)
  lu.assertTrue(vim.tbl_contains(result, '-i'))
  lu.assertTrue(vim.tbl_contains(result, '--abort'))
end

function TestCommand:test_rebase_complete_partial()
  local rebase = require('git.command.rebase')
  local result = rebase.complete('--a', 'Git rebase --a', 14)
  lu.assertEquals(result, { '--abort' })
end

-- =========================
-- Complete: log
-- =========================

function TestCommand:test_log_complete_dash()
  local log = require('git.command.log')
  local result = log.complete('-', 'Git log -', 9)
  lu.assertEquals(result, { '--branches' })
end

-- =========================
-- Complete: push
-- =========================

function TestCommand:test_push_complete_options()
  local push = require('git.command.push')
  local result = push.complete('-', 'Git push -', 10)
  lu.assertTrue(#result > 0)
  lu.assertTrue(vim.tbl_contains(result, '-u'))
  lu.assertTrue(vim.tbl_contains(result, '--set-upstream'))
  lu.assertTrue(vim.tbl_contains(result, '-d'))
  lu.assertTrue(vim.tbl_contains(result, '--delete'))
end

-- =========================
-- Complete: add / reset / rm
-- =========================

function TestCommand:test_add_complete_includes_percent()
  local add = require('git.command.add')
  local result = add.complete('R', 'Git add R', 9)
  lu.assertNotNil(result)
  lu.assertTrue(vim.tbl_contains(result, '%'))
end

function TestCommand:test_reset_complete_returns_files()
  local reset = require('git.command.reset')
  local result = reset.complete('R', 'Git reset R', 11)
  lu.assertNotNil(result)
end

function TestCommand:test_rm_complete_returns_files()
  local rm = require('git.command.rm')
  local result = rm.complete('R')
  lu.assertNotNil(result)
end

return TestCommand

