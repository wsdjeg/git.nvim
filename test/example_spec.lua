-- test/example_spec.lua
-- Example test file demonstrating the test framework usage

local lu = require('luaunit')

TestUtil = {}

function TestUtil:setUp()
  self.util = require('git.util')
end

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

TestInit = {}

function TestInit:test_module_loads()
  local git = require('git')
  lu.assertNotNil(git)
  lu.assertIsFunction(git.run)
  lu.assertIsFunction(git.complete)
end

return TestUtil

