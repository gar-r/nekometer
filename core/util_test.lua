local lu = require("luaunit")

local nekometer = {}

loadfile("core/util.lua")("test", nekometer)

TestUtil = {}

function TestUtil:test_remove_realm_info()
    local util = nekometer.util
    lu.assertEquals(util:RemoveRealmInfo("playerName"), "playerName")
    lu.assertEquals(util:RemoveRealmInfo("playerName-realm"), "playerName")
    lu.assertEquals(util:RemoveRealmInfo("playerName-realm-foobar"), "playerName")
end

function TestUtil:test_get_spell_texture()
    C_Spell = {
        GetSpellInfo = function(id)
            if id == 1 then
                return {iconID = 100}
            end
        end
    }
    local util = nekometer.util
    lu.assertEquals(util:GetSpellTexture(1), 100)
    lu.assertEquals(util:GetSpellTexture(2), nil)
end