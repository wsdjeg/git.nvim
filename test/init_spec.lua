-- test/init_spec.lua
-- Tests for git.init module (entry point)

local lu = require('luaunit')

TestInit = {}

function TestInit:setUp()
  self.git = require('git')
  self.job = require('job')
  self.job.reset()
end

function TestInit:tearDown()
  vim.cmd('silent! only')
end

-- ============
-- Module tests
-- ============

function TestInit:test_module_loads()
  lu.assertNotNil(self.git)
  lu.assertIsFunction(self.git.run)
  lu.assertIsFunction(self.git.complete)
end

-- ===========
-- run() tests
-- ===========

function TestInit:test_run_unsupported_command()
  self.git.run('unsupportedcmd')
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestInit:test_run_empty_command()
  self.git.run('')
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestInit:test_run_add_command()
  self.git.run('add file.txt')
  local last = self.job.get_last_call()
  lu.assertNotNil(last)
  lu.assertEquals(last.cmd, { 'git', 'add', 'file.txt' })
end

function TestInit:test_run_fetch_command()
  self.git.run('fetch origin')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'fetch', 'origin' })
end

function TestInit:test_run_clean_command()
  self.git.run('clean -fd')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'clean', '-fd' })
end

function TestInit:test_run_reset_command()
  self.git.run('reset HEAD')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'reset', 'HEAD' })
end

function TestInit:test_run_rm_command()
  self.git.run('rm file.txt')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'rm', 'file.txt' })
end

function TestInit:test_run_show_command()
  self.git.run('show HEAD')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'show', 'HEAD' })
end

function TestInit:test_run_blame_command()
  self.git.run('blame file.txt')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd[1], 'git')
  lu.assertEquals(last.cmd[2], 'blame')
  lu.assertEquals(last.cmd[3], '--line-porcelain')
end

function TestInit:test_run_cherry_pick_no_args()
  self.git.run('cherry-pick')
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestInit:test_run_cherry_pick_with_args()
  self.git.run('cherry-pick abc123')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'cherry-pick', 'abc123' })
end

function TestInit:test_run_merge_no_args()
  self.git.run('merge')
  lu.assertEquals(self.job.get_call_count(), 0)
end

function TestInit:test_run_merge_with_args()
  self.git.run('merge feature')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'merge', 'feature' })
end

function TestInit:test_run_config_no_args()
  self.git.run('config')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'config', '--list' })
end

function TestInit:test_run_config_with_args()
  self.git.run('config user.name')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'config', 'user.name' })
end

function TestInit:test_run_mv_command()
  self.git.run('mv old.txt new.txt')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'mv', 'old.txt', 'new.txt' })
end

function TestInit:test_run_grep_command()
  self.git.run('grep TODO')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'grep', '-n', 'TODO' })
end

function TestInit:test_run_reflog_command()
  self.git.run('reflog')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'reflog' })
end

function TestInit:test_run_update_index_command()
  self.git.run('update-index --refresh')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'update-index', '--refresh' })
end

function TestInit:test_run_pull_command()
  self.git.run('pull origin')
  lu.assertEquals(self.job.get_call_count(), 1)
  local last = self.job.get_last_call()
  lu.assertEquals(last.cmd, { 'git', 'pull', 'origin' })
end

-- ================
-- complete() tests
-- ================

function TestInit:test_complete_first_arg_all()
  local result = self.git.complete('', 'Git ', 4)
  lu.assertNotNil(result)
  lu.assertTrue(#result > 0)
  lu.assertTrue(vim.tbl_contains(result, 'add'))
  lu.assertTrue(vim.tbl_contains(result, 'status'))
  lu.assertTrue(vim.tbl_contains(result, 'commit'))
end

function TestInit:test_complete_first_arg_filtered()
  local result = self.git.complete('a', 'Git a', 5)
  lu.assertEquals(result, { 'add' })
end

function TestInit:test_complete_first_arg_st()
  local result = self.git.complete('st', 'Git st', 6)
  lu.assertTrue(vim.tbl_contains(result, 'status'))
  lu.assertTrue(vim.tbl_contains(result, 'stash'))
end

function TestInit:test_complete_first_arg_cherry()
  local result = self.git.complete('cherry', 'Git cherry', 10)
  lu.assertEquals(result, { 'cherry-pick' })
end

function TestInit:test_complete_first_arg_no_match()
  local result = self.git.complete('xyz', 'Git xyz', 7)
  lu.assertEquals(result, {})
end

function TestInit:test_complete_delegates_to_command()
  local result = self.git.complete('--p', 'Git fetch --p', 13)
  lu.assertNotNil(result)
  lu.assertTrue(vim.tbl_contains(result, '--prune'))
  lu.assertTrue(vim.tbl_contains(result, '--prune-tags'))
end

function TestInit:test_complete_no_complete_function()
  local result = self.git.complete('x', 'Git clean x', 11)
  lu.assertNil(result)
end

return TestInit

