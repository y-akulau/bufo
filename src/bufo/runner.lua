local Class = require("classe").Class
local bufo = require("bufo")

local M = {}

--- @class (exact) TestReporterClass: Class
--- @field public new fun(self: self): TestReporter
local TestReporter = Class:new("TestReporter")

--- @class (exact) TestReporter
TestReporter.prototype = TestReporter.prototype

--- @private
--- @return void
function TestReporter.prototype:__init()
end

--- @public
--- @return void
function TestReporter.prototype:reset()
end

--- @class (exact) TestOutputClass: Class
--- @field public new fun(self: self): TestOutput
local TestOutput = Class:new("TestOutput")

--- @class (exact) TestOutput
TestOutput.prototype = TestOutput.prototype

--- @private
--- @return void
function TestOutput.prototype:__init()
end

--- @public
--- @return void
function TestOutput.prototype:reset()
end

--- @class (exact) TestRunnerClass: Class
--- @field public new fun(self: self): TestRunner
local TestRunner = Class:new("TestRunner")

--- @class (exact) TestRunner
--- @field private _output TestOutput
--- @field private _report TestReporter
--- @field private _stack  TestSuite[]
TestRunner.prototype = TestRunner.prototype

--- @private
--- @return void
function TestRunner.prototype:__init()
    self._stack = {}
end

--- @public
--- @param suites TestSuite[]
--- @return void
function TestRunner.prototype:run(suites)
    self._output = TestOutput:new()
    self._report = TestReporter:new()

    for _, suite in ipairs(suites) do
        self:_run_suite(suite)
    end

    self._output:reset()
    self._report:reset()
end

--- @private
--- @param suite TestSuite
--- @return void
function TestRunner.prototype:_run_suite(suite)
    local indent = (" "):rep(#self._stack)
    print(indent .. suite.name)

    table.insert(self._stack, suite)

    for _, before_all in ipairs(suite.hooks.before_all) do
        before_all()
    end

    for _, child in ipairs(suite.children) do
        if child.children ~= nil then
            --- @diagnostic disable-next-line: param-type-mismatch
            self:_run_suite(child)
        else
            --- @diagnostic disable-next-line: param-type-mismatch
            self:_run_test(child)
        end
    end

    for i = #suite.hooks.after_all, 1, -1 do
        local after_all = suite.hooks.after_all[i]
        after_all()
    end

    table.remove(self._stack)
end

--- @private
--- @param test Test
--- @return void
function TestRunner.prototype:_run_test(test)
    local indent = (" "):rep(#self._stack)
    local ok, error = pcall(test.body)

    if not ok then
        print(indent .. "X " .. test.name)
        print(indent .. "", error)
    else
        print(indent .. "V " .. test.name)
    end
end

--- @class TestRunOptions
--- @field files string[]

--- @param options TestRunOptions
--- @return void
function M.run(options)
    local context = bufo.TestContext:new()
    context:run(function ()
        for _, file in ipairs(options.files) do
            local ok, error = pcall(dofile, file)
            if not ok then
                print("Failed to load test file " .. file .. ": " .. error)
            end
        end
    end)

    local runner = TestRunner:new()
    runner:run(context.roots)
end

return M
