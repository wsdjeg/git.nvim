-- test/log_spec.lua
-- Tests for git.log module (graceful degradation without logger)

local lu = require('luaunit')

TestLog = {}

function TestLog:setUp()
  self.log = require('git.log')
end

function TestLog:test_info_does_not_error()
  self.log.info('test message')
  lu.assertTrue(true)
end

function TestLog:test_warn_does_not_error()
  self.log.warn('test message')
  lu.assertTrue(true)
end

function TestLog:test_debug_does_not_error()
  self.log.debug('test message')
  lu.assertTrue(true)
end

function TestLog:test_info_with_empty_string()
  self.log.info('')
  lu.assertTrue(true)
end

function TestLog:test_info_with_nil()
  self.log.info(nil)
  lu.assertTrue(true)
end

return TestLog

