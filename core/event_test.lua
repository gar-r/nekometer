local lu = require("luaunit")

local mockFilter = {}
local mockUtil = {}
local mockPets = {}
local nekometer = {
    filter = mockFilter,
    util = mockUtil,
    pets = mockPets,
}

UnitGUID = function(u) return u end

loadfile("core/event.lua")("test", nekometer)

TestEvent = {}

-- raw test event data from https://warcraft.wiki.gg/wiki/COMBAT_LOG_EVENT
local testData = {
    swing = { 1617986084.18, "SWING_DAMAGE", false, "Player-1096-06DF65C1", "Xiaohuli", 1297, 0, "Creature-0-4253-0-160-94-000070569B", "Cutpurse", 68168, 0, 3, -1, 1, nil, nil, nil, true, false, false, false },
    spell = { 1617986113.264, "SPELL_DAMAGE", false, "Player-1096-06DF65C1", "Xiaohuli", 1297, 0, "Creature-0-4253-0-160-94-000070569B", "Cutpurse", 68168, 0, 585, "Smite", 2, 47, 19, 2, nil, nil, nil, false, false, false, false },
    reflect = { 1620561974.121, "SPELL_MISSED", false, "Creature-0-4234-0-138-44176-000016DAE1", "Bluegill Wanderer", 2632, 0, "Player-1096-06DF65C1", "Xiaohuli", 66833, 0, 83669, "Water Bolt", 16, "REFLECT", false, 15, false },
    absorb = { 1620561974.121, "SPELL_ABSORBED", false, "Creature-0-4234-0-138-44176-000016DAE1",
        "Bluegill Wanderer", 2632, 0, "Player-1096-06DF65C1", "Xiaohuli", 66833, 0, 83669, "Water Bolt", 16,
        "Player-1096-06DF65C1", "Xiaohuli", 66833, 0, 17, "Power Word: Shield", 2, 15, false },
    death = { 1620561974.121, "UNIT_DIED", 0000000000000000, nil, 0x80000000, 0x80000000, "Creature-0-1469-2450-16377-99773-0000785473", "Bloodworm", 0x2114, 0x0, 0 },
    interrupt = { 1617986113.264, "SPELL_INTERRUPT", false, "Player-1096-06DF65C1", "Xiaohuli", 1297 },
    dispel = { 1617986113.264, "SPELL_DISPEL", false, "Player-1096-06DF65C1", "Xiaohuli", 1297 },
    steal = { 1617986113.264, "SPELL_STOLEN", false, "Player-1096-06DF65C1", "Xiaohuli", 1297 },
}

function TestEvent:setUp()
    mockFilter:resetMock()
    mockPets:resetMock()
end

function TestEvent:test_event_type()
    lu.assertEquals(nekometer.event:new(testData.swing):GetType(), "SWING_DAMAGE")
    lu.assertEquals(nekometer.event:new(testData.spell):GetType(), "SPELL_DAMAGE")
    lu.assertEquals(nekometer.event:new(testData.absorb):GetType(), "SPELL_ABSORBED")
    lu.assertEquals(nekometer.event:new(testData.death):GetType(), "UNIT_DIED")
    lu.assertEquals(nekometer.event:new(testData.interrupt):GetType(), "SPELL_INTERRUPT")
    lu.assertEquals(nekometer.event:new(testData.dispel):GetType(), "SPELL_DISPEL")
    lu.assertEquals(nekometer.event:new(testData.steal):GetType(), "SPELL_STOLEN")
end

function TestEvent:test_get_source_standard()
    local e = nekometer.event:new(testData.spell)
    lu.assertEquals(e:GetSource(), { id = "Player-1096-06DF65C1", name = "Xiaohuli" })
end

function TestEvent:test_get_source_merged_pet()
    NekometerConfig = { mergePets = true }
    local e = nekometer.event:new(testData.swing)
    mockFilter.isOwned = true
    mockFilter.isPet = true
    mockPets.owner = { id = 200, name = "owner" }
    lu.assertEquals(e:GetSource(), { id = 200, name = "owner" })
    lu.assertTrue(mockPets.lookupCalled)
    lu.assertEquals(mockPets.lookupArg, "Player-1096-06DF65C1")
end

function TestEvent:test_get_source_unmerged_pet()
    NekometerConfig = { mergePets = false }
    local e = nekometer.event:new(testData.swing)
    mockFilter.isOwned = true
    mockFilter.isPet = true
    lu.assertEquals(e:GetSource(), { id = "Player-1096-06DF65C1", name = "Xiaohuli" })
end

function TestEvent:test_get_source_guardian_pet_always_merged()
    NekometerConfig = { mergePets = false }
    local e = nekometer.event:new(testData.swing)
    mockFilter.isOwned = true
    mockFilter.isPet = false
    mockPets.owner = { id = 200, name = "owner" }
    lu.assertEquals(e:GetSource(), { id = 200, name = "owner" })
end

function TestEvent:test_get_source_absorb()
    local e = nekometer.event:new(testData.absorb)
    mockFilter.isFriendly = true
    lu.assertEquals(e:GetSource(), {
        id = "Player-1096-06DF65C1",
        name = "Xiaohuli"
    })
end

function TestEvent:test_get_source_reflect()
    local e = nekometer.event:new(testData.reflect)
    mockFilter.isEnemy = true
    mockFilter.isFriendly = true
    mockFilter.isOwned = false
    lu.assertEquals(e:GetSource(), {
        id = "Player-1096-06DF65C1",
        name = "Xiaohuli"
    })
end

function TestEvent:test_get_amount_standard()
    -- we expect the effective amount in all cases (value - absorb/overheal)
    lu.assertEquals(nekometer.event:new(testData.swing):GetAmount(), 3)
    lu.assertEquals(nekometer.event:new(testData.spell):GetAmount(), 28)
end

function TestEvent:test_get_amount_reflect()
    local e = nekometer.event:new(testData.reflect)
    e.prevSelfHarm = 100
    mockFilter.isEnemy = true
    mockFilter.isFriendly = true
    mockFilter.isOwned = false
    lu.assertEquals(e:GetAmount(), 100)
end

function TestEvent:test_get_amount_absorb()
    local e = nekometer.event:new(testData.absorb)
    mockFilter.isFriendly = true
    lu.assertEquals(e:GetAmount(), 15)
end

function TestEvent:test_get_ability_swing()
    local e = nekometer.event:new(testData.swing)
    lu.assertEquals(e:GetAbility().name, "Melee")
end

function TestEvent:test_get_ability_standard()
    local e = nekometer.event:new(testData.spell)
    lu.assertEquals(e:GetAbility(), { id = 585, name = "Smite" })
end

function TestEvent:test_get_ability_absorb()
    local e = nekometer.event:new(testData.absorb)
    mockFilter.isFriendly = true
    lu.assertEquals(e:GetAbility(), { id = 17, name = "Power Word: Shield" })
end

function TestEvent:test_get_ability_reflect()
    local e = nekometer.event:new(testData.reflect)
    mockFilter.isEnemy = true
    mockFilter.isFriendly = true
    mockFilter.isOwned = false
    lu.assertEquals(e:GetAbility().name, "Spell Reflect")
end

function TestEvent:test_is_spell_reflect()
    local e = nekometer.event:new(testData.reflect)
    mockFilter.isEnemy = true
    mockFilter.isFriendly = true
    mockFilter.isOwned = false
    lu.assertTrue(e:IsSpellReflect())
    lu.assertTrue(mockFilter.isEnemyCalled)
    lu.assertEquals(mockFilter.isEnemyArg, 2632)
    lu.assertTrue(mockFilter.isFriendlyCalled)
    lu.assertEquals(mockFilter.isFriendlyArg, 66833)
    lu.assertTrue(mockFilter.isOwnedCalled)
    lu.assertEquals(mockFilter.isOwnedArg, 66833)
end

function TestEvent:test_is_self_harm()
    local e = nekometer.event:new({ 12345, "SPELL_DAMAGE", 0, 100, 0, 0, 0, 100 })
    lu.assertTrue(e:IsSelfHarm())
end

function TestEvent:test_is_absorb()
    local e = nekometer.event:new(testData.absorb)
    mockFilter.isFriendly = true
    lu.assertTrue(e:IsAbsorb())
    lu.assertTrue(e:IsFriendlyAbsorb())
    lu.assertTrue(mockFilter.isFriendlyCalled)
    lu.assertEquals(mockFilter.isFriendlyArg, 66833)
end

function TestEvent:test_is_source_friendly()
    local e = nekometer.event:new({ 12345, "SPELL_DAMAGE", 0, 0, 0, "id" })
    mockFilter.isFriendly = true
    lu.assertTrue(e:IsSourceFriendly())
    lu.assertTrue(mockFilter.isFriendlyCalled)
    lu.assertEquals(mockFilter.isFriendlyArg, "id")
end

function TestEvent:test_is_friendly_death()
    local e = nekometer.event:new(testData.death)
    mockFilter.isFriendly = true
    lu.assertTrue(e:IsFriendlyDeath())
    lu.assertTrue(mockFilter.isFriendlyCalled)
    lu.assertEquals(mockFilter.isFriendlyArg, 0)
end

function TestEvent:test_is_interrupt()
    local e = nekometer.event:new(testData.interrupt)
    lu.assertTrue(e:IsInterrupt())
end

function TestEvent:test_is_dispel()
    local e = nekometer.event:new(testData.dispel)
    lu.assertTrue(e:IsDispel())
end

function TestEvent:test_is_dispel_spell_steal()
    local e = nekometer.event:new(testData.steal)
    lu.assertTrue(e:IsDispel())
end

function TestEvent:test_is_damage()
    lu.assertTrue(nekometer.event:new(testData.swing):IsDamage())
    lu.assertTrue(nekometer.event:new(testData.spell):IsDamage())
end

function TestEvent:test_is_heal()
    local e = nekometer.event:new({ 12345, "SPELL_HEAL" })
    lu.assertTrue(e:IsHeal())
end

function TestEvent:test_is_summon()
    local e = nekometer.event:new({ 12345, "SPELL_SUMMON" })
    lu.assertTrue(e:IsSummon())
end

function TestEvent:test_is_done_by_player()
    local e = nekometer.event:new({ 12345, "SPELL_DAMAGE" })
    e[4] = "player"
    e[5] = "name"
    lu.assertTrue(e:IsDoneByPlayer())
end

function mockFilter:IsEnemy(arg)
    self.isEnemyCalled = true
    self.isEnemyArg = arg
    return self.isEnemy
end

function mockFilter:IsFriendly(arg)
    self.isFriendlyCalled = true
    self.isFriendlyArg = arg
    return self.isFriendly
end

function mockFilter:IsOwned(arg)
    self.isOwnedCalled = true
    self.isOwnedArg = arg
    return self.isOwned
end

function mockFilter:IsPet(arg)
    self.isPetCalled = true
    self.isPetArg = arg
    return self.isPet
end

function mockFilter:resetMock()
    self.isEnemy = false
    self.isFriendly = false
    self.isOwned = false
    self.isPet = false
    self.isEnemyCalled = false
    self.isFriendlyCalled = false
    self.isOwnedCalled = false
    self.isPetCalled = false
end

function mockUtil:RemoveRealmInfo(s)
    return s
end

function mockPets:Lookup(arg)
    self.lookupCalled = true
    self.lookupArg = arg
    return self.owner
end

function mockPets:resetMock()
    self.owner = nil
    self.lookupCalled = false
    self.lookupArg = nil
end
