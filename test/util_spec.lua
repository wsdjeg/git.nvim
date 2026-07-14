-- test/util_spec.lua
-- Comprehensive tests for git.util module

local lu = require('luaunit')

TestUtil = {}

function TestUtil:setUp()
  self.util = require('git.util')
end

function TestUtil:tearDown()
  vim.cmd('silent! only')
end

-- ==============
-- parser() tests
-- ==============

function TestUtil:test_parser_simple()
  local result = self.util.parser('add file.txt')
  lu.assertEquals(result, { 'add', 'file.txt' })
end

function TestUtil:test_parser_multiple_args()
  local result = self.util.parser('commit -m hello world')
  lu.assertEquals(result, { 'commit', '-m', 'hello', 'world' })
end

function TestUtil:test_parser_quoted_string()
  local result = self.util.parser('commit -m "hello world"')
  lu.assertEquals(result, { 'commit', '-m', 'hello world' })
end

function TestUtil:test_parser_escaped_quote()
  local result = self.util.parser('commit -m "say \\"hi\\""')
  lu.assertEquals(result, { 'commit', '-m', 'say "hi"' })
end

function TestUtil:test_parser_empty_string()
  local result = self.util.parser('')
  lu.assertEquals(result, {})
end

function TestUtil:test_parser_single_arg()
  local result = self.util.parser('status')
  lu.assertEquals(result, { 'status' })
end

function TestUtil:test_parser_trailing_space()
  local result = self.util.parser('add file.txt ')
  lu.assertEquals(result, { 'add', 'file.txt' })
end

function TestUtil:test_parser_leading_space()
  local result = self.util.parser(' add file.txt')
  lu.assertEquals(result, { 'add', 'file.txt' })
end

function TestUtil:test_parser_multiple_spaces()
  local result = self.util.parser('add  file.txt')
  lu.assertEquals(result, { 'add', 'file.txt' })
end

function TestUtil:test_parser_only_spaces()
  local result = self.util.parser('   ')
  lu.assertEquals(result, {})
end

function TestUtil:test_parser_quoted_empty()
  local result = self.util.parser('commit -m ""')
  lu.assertEquals(result, { 'commit', '-m', '' })
end

function TestUtil:test_parser_dashed_arg()
  local result = self.util.parser('checkout -b new-branch')
  lu.assertEquals(result, { 'checkout', '-b', 'new-branch' })
end

function TestUtil:test_parser_hyphenated_command()
  local result = self.util.parser('cherry-pick abc123')
  lu.assertEquals(result, { 'cherry-pick', 'abc123' })
end

function TestUtil:test_parser_multiple_quoted()
  local result = self.util.parser('commit -m "first" -m "second"')
  lu.assertEquals(result, { 'commit', '-m', 'first', '-m', 'second' })
end

-- ===========
-- fill() tests
-- ===========

function TestUtil:test_fill()
  local result = self.util.fill('abc', 5)
  lu.assertEquals(result, 'abc  ')
end

function TestUtil:test_fill_truncate()
  local result = self.util.fill('abcdef', 3)
  lu.assertEquals(result, 'abc')
end

function TestUtil:test_fill_custom_char()
  local result = self.util.fill('ab', 5, '-')
  lu.assertEquals(result, 'ab---')
end

function TestUtil:test_fill_exact_length()
  local result = self.util.fill('abcde', 5)
  lu.assertEquals(result, 'abcde')
end

function TestUtil:test_fill_empty_string()
  local result = self.util.fill('', 5)
  lu.assertEquals(result, '     ')
end

function TestUtil:test_fill_zero_length()
  local result = self.util.fill('abc', 0)
  lu.assertEquals(result, '')
end

function TestUtil:test_fill_longer_string()
  local result = self.util.fill('abcdefghij', 4)
  lu.assertEquals(result, 'abcd')
end

-- ==================
-- string2chars() tests
-- ==================

function TestUtil:test_string2chars_simple()
  local result = self.util.string2chars('abc')
  lu.assertEquals(result, { 'a', 'b', 'c' })
end

function TestUtil:test_string2chars_single()
  local result = self.util.string2chars('x')
  lu.assertEquals(result, { 'x' })
end

function TestUtil:test_string2chars_empty()
  local result = self.util.string2chars('')
  lu.assertEquals(result, {})
end

function TestUtil:test_string2chars_with_spaces()
  local result = self.util.string2chars('a b')
  lu.assertEquals(result, { 'a', ' ', 'b' })
end

-- ================
-- is_float() tests
-- ================

function TestUtil:test_is_float_regular_window()
  local winid = vim.api.nvim_get_current_win()
  lu.assertFalse(self.util.is_float(winid))
end

function TestUtil:test_is_float_floating_window()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 10,
    height = 1,
    row = 0,
    col = 0,
  })
  lu.assertTrue(self.util.is_float(win))
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })
end

function TestUtil:test_is_float_zero()
  lu.assertFalse(self.util.is_float(0))
end

function TestUtil:test_is_float_negative()
  lu.assertFalse(self.util.is_float(-1))
end

-- ====================
-- update_buffer() tests
-- ====================

function TestUtil:test_update_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  self.util.update_buffer(buf, { 'line1', 'line2', 'line3' })
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  lu.assertEquals(lines, { 'line1', 'line2', 'line3' })
  vim.api.nvim_buf_delete(buf, { force = true })
end

function TestUtil:test_update_buffer_empty()
  local buf = vim.api.nvim_create_buf(false, true)
  self.util.update_buffer(buf, {})
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  lu.assertEquals(lines, { '' })
  vim.api.nvim_buf_delete(buf, { force = true })
end

function TestUtil:test_update_buffer_overwrite()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'old1', 'old2' })
  self.util.update_buffer(buf, { 'new1' })
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  lu.assertEquals(lines, { 'new1' })
  vim.api.nvim_buf_delete(buf, { force = true })
end

function TestUtil:test_update_buffer_invalid()
  -- should not error with invalid buffer
  self.util.update_buffer(99999, { 'test' })
  lu.assertTrue(true)
end

-- ===================
-- is_last_win() tests
-- ===================

function TestUtil:test_is_last_win_single()
  vim.cmd('silent! only')
  local result = self.util.is_last_win()
  lu.assertTrue(result)
end

return TestUtil

