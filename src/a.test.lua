local bufo = require("bufo")

bufo.suite("A", function ()
    local x

    bufo.before_all(function ()
        x = 10
    end)

    bufo.test("bebra", function ()
        assert(x ~= 10)
    end)
end)
