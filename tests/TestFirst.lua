local lu = require 'lib/luaunit'

TestFirst = {}

function TestFirst:test_first()
    lu.assertEquals(true, true)
end
