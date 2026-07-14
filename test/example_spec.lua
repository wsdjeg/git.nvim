-- test/example_spec.lua
-- Example test file demonstrating the test framework usage
--
-- Comprehensive tests have been moved to dedicated spec files:
--   test/util_spec.lua     - git.util module tests
--   test/init_spec.lua     - git.init module tests (run, complete)
--   test/log_spec.lua      - git.log module tests
--   test/command_spec.lua  - all git.command.* module tests
--
-- This file is kept as a reference for writing new tests.

local lu = require('luaunit')

TestExample = {}

function TestExample:test_framework_loaded()
  lu.assertNotNil(lu)
end

return TestExample

