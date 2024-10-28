local lu = require("luaunit")

local nekometer = {
    cache = {
        new = function(_, _, _) end
    }
}

UnitGUID = function(unit)
    if unit == "pet" then
        return "petId"
    elseif unit == "player" then
        return "playerId"
    elseif unit == "FooBar" then
        return "foobarId"
    end
end

UnitName = function(unit)
    if unit == "player" then
        return "playerName"
    end
end

_G["UNITNAME_SUMMON_TITLE1"] = "%s's Totem"
_G["UNITNAME_SUMMON_TITLE2"] = "%s's Guardian"

C_TooltipInfo = {
    GetHyperlink = function(link)
        if link == "unit:otherPetId" then
            return {
                lines = {
                    { leftText = "Mr. Pet" },
                    { leftText = "FooBar's Guardian" },
                },
            }
        end
    end
}

format = string.format

loadfile("core/pets.lua")("test", nekometer)

TestPets = {}

function TestPets:test_query_player_pet()
    local expected = { id = "playerId", name = "playerName" }
    local actual = nekometer.pets_obj:queryOwner("petId")
    lu.assertEquals(actual, expected)
end

function TestPets:test_query_tooltip_info()
    local actual = nekometer.pets_obj:queryOwner("otherPetId")
    lu.assertEquals(actual, { id = "foobarId", name = "FooBar" })
end
