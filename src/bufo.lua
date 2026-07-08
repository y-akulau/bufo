local Class = require("classe").Class

local M = {}

--- @class (exact) TestContextClass: Class
--- @field private _current TestContext?
--- @field public new       fun(self: self): TestContext
local TestContext = Class:new("TestContext")

--- @class (exact) TestContext
--- @field public roots TestSuite[]
--- @field public trail TestSuite[]
TestContext.prototype = TestContext.prototype

--- @public
--- @return TestContext
function TestContext:current()
    if not self._current then
        error("Execution is outside the test context", 0)
    end

    return self._current
end

--- @private
--- @return void
function TestContext.prototype:__init()
    self.roots = {}
    self.trail = {}
end

--- @generic T
--- @public
--- @param block fun(): T
--- @return T
function TestContext.prototype:run(block)
    local previous_context = TestContext._current
    TestContext._current = self
    local ok, result = pcall(block)

    TestContext._current = previous_context
    if not ok then error(result) end

    return result
end

M.TestContext = TestContext

--- @alias TestBody fun(): void

--- @class (exact) Test
--- @field name string
--- @field body TestBody

--- @alias TestHook fun(): void

--- @class (exact) TestHooks
--- @field before_all  TestHook[]
--- @field after_all   TestHook[]
--- @field before_each TestHook[]
--- @field after_each  TestHook[]

--- @alias TestSuiteBlock fun(): void

--- @class (exact) TestSuite
--- @field name     string
--- @field hooks    TestHooks
--- @field children (Test | TestSuite)[]

--- @param name string
--- @param body TestBody
--- @return void
function M.test(name, body)
    local context = TestContext:current()

    --- @type Test
    local test = { name = name, body = body }

    local current_suite = context.trail[#context.trail]
    --- @cast current_suite + nil
    if not current_suite then
        error("Test \"" .. name .. "\" is declared outside of a test suite", 0)
    end

    table.insert(current_suite.children, test)
end

M.it = M.test

--- @param name  string
--- @param block TestSuiteBlock
--- @return void
function M.suite(name, block)
    local context = TestContext:current()

    --- @type TestSuite
    local suite = {
        name = name,
        hooks = {
            before_all = {},
            after_all = {},
            before_each = {},
            after_each = {}
        },
        children = {}
    }

    table.insert(context.trail, suite)
    local ok, caught = pcall(block)
    table.remove(context.trail, #context.trail)
    if not ok then
        error("Failed to declare a test suite \"" .. name .. "\" (" .. caught .. ")", 0)
    end

    local current_suite = context.trail[#context.trail]
    --- @cast current_suite + nil
    table.insert(current_suite and current_suite.children or context.roots, suite)
end

M.describe = M.suite

--- @internal
--- @param name string
--- @param body TestHook
--- @return void
local function hook(name, body)
    local context = TestContext:current()

    local current_suite = context.trail[#context.trail]
    --- @cast current_suite + nil
    if not current_suite then
        error(name .. " hook is declared outside of a test suite", 0)
    end

    table.insert(current_suite.hooks[name], body)
end

--- @param block TestHook
--- @return void
function M.before_all(block)
    hook("before_all", block)
end

function M.after_all(block)
    hook("after_all", block)
end

function M.before_each(block)
    hook("before_each", block)
end

function M.after_each(block)
    hook("after_each", block)
end

return M
