local lu = require("luaunit")

local nekometer = {}

loadfile("core/report.lua")("test", nekometer)

TestReport = {
    output = {},
    oldPrint = nil,
}

function TestReport:setUp()
    self.oldPrint = print
    self.output = {}
    print = function(s)
        table.insert(self.output, s)
    end
end

function TestReport:tearDown()
    print = self.oldPrint
end

function TestReport:test_create_report()
    local meterData = {
        ["key-0123"] = {
            name = "foo",
            value = 12345,
        },
        ["key-0456"] = {
            name = "bar",
            value = 67890,
        },
    }
    local expected = {
        {
            id = "key-0456",
            name = "bar",
            value = 67890,
        },
        {
            id = "key-0123",
            name = "foo",
            value = 12345,
        },
        ["source"] = "test",
    }
    local actual = nekometer.CreateReport(meterData, "test")
    lu.assertEquals(actual, expected)
end

function TestReport:test_print_report()
    local report = {
        {
            id = "key-0456",
            name = "bar",
            value = 67890,
        },
        {
            id = "key-0123",
            name = "foo",
            value = 12345,
        },
        ["source"] = "test",
    }
    local expected = {
        " 1: bar (67890)",
        " 2: foo (12345)",
    }
    nekometer.PrintReport(report)
    lu.assertEquals(self.output, expected)
end