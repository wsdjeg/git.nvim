-- test/minimal_init.lua
-- Minimal Neovim configuration for testing

print('Initializing test environment...')

-- Set up essential settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false
vim.opt.verbose = 1

-- Save project root before any CWD changes
local project_root = vim.fn.getcwd()
_G.PROJECT_ROOT = project_root

-- Set up package path with absolute paths so they work after CWD change
-- 1. lua/?.lua and lua/?/init.lua - Main plugin source code
-- 2. test/?.lua - Mock modules (job, notify)
-- 3. test/.deps/?.lua - Test dependencies (luaunit)
package.path = project_root .. '/lua/?.lua;'
  .. project_root .. '/lua/?/init.lua;'
  .. project_root .. '/test/?.lua;'
  .. project_root .. '/test/.deps/?.lua;'
  .. package.path
vim.opt.runtimepath:prepend(project_root)

-- Create temporary test directory
local test_dir = vim.fn.tempname() .. '_git_nvim_test'
vim.fn.mkdir(test_dir, 'p')

-- Initialize test git repository
local function init_test_repo()
  local git_bin = vim.fn.executable('git') == 1 and 'git' or nil
  if not git_bin then
    print('[WARN] git not found, skipping repo initialization')
    return
  end

  -- Set up minimal git config for test repo
  vim.fn.system({ 'git', 'init', test_dir })
  vim.fn.system({ 'git', '-C', test_dir, 'config', 'user.name', 'Test User' })
  vim.fn.system({ 'git', '-C', test_dir, 'config', 'user.email', 'test@example.com' })

  -- Create initial commit
  local readme = test_dir .. '/README.md'
  vim.fn.writefile({ '# Test Repo' }, readme)
  vim.fn.system({ 'git', '-C', test_dir, 'add', '.' })
  vim.fn.system({ 'git', '-C', test_dir, 'commit', '-m', 'initial commit' })
end

init_test_repo()

-- Set test directory as working directory for git operations
vim.cmd('cd ' .. test_dir)

-- Load plugin source (plugin/git.lua registers the :Git command)
local ok, err = pcall(function()
  require('git')
  -- Manually load plugin file to register :Git command
  vim.cmd('runtime plugin/git.lua')
end)

if not ok then
  print('Error initializing test environment: ' .. err)
else
  print('Test environment initialized successfully')
  print('Test directory: ' .. test_dir)
end

