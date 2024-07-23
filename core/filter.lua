local _, nekometer = ...

local filter = {
    friendly = bit.bor(
        COMBATLOG_OBJECT_AFFILIATION_MINE,
        COMBATLOG_OBJECT_AFFILIATION_PARTY,
        COMBATLOG_OBJECT_AFFILIATION_RAID,
        COMBATLOG_OBJECT_REACTION_FRIENDLY,
        COMBATLOG_OBJECT_CONTROL_MASK,
        COMBATLOG_OBJECT_TYPE_MASK
    ),
    pet = bit.bor(
        COMBATLOG_OBJECT_AFFILIATION_MINE,
        COMBATLOG_OBJECT_AFFILIATION_PARTY,
        COMBATLOG_OBJECT_AFFILIATION_RAID,
        COMBATLOG_OBJECT_REACTION_FRIENDLY,
        COMBATLOG_OBJECT_CONTROL_PLAYER,
        COMBATLOG_OBJECT_TYPE_PET
    ),
    owned = bit.bor(
        COMBATLOG_OBJECT_AFFILIATION_MINE,
        COMBATLOG_OBJECT_AFFILIATION_PARTY,
        COMBATLOG_OBJECT_AFFILIATION_RAID,
        COMBATLOG_OBJECT_REACTION_FRIENDLY,
        COMBATLOG_OBJECT_CONTROL_MASK,
        COMBATLOG_OBJECT_TYPE_GUARDIAN,
        COMBATLOG_OBJECT_TYPE_PET,
        COMBATLOG_OBJECT_TYPE_OBJECT
    ),
    enemy = bit.bor(
        COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
        COMBATLOG_OBJECT_REACTION_NEUTRAL,
        COMBATLOG_OBJECT_REACTION_HOSTILE,
        COMBATLOG_OBJECT_CONTROL_MASK,
        COMBATLOG_OBJECT_TYPE_MASK
    )
}

function filter:IsFriendly(oflags)
    return CombatLog_Object_IsA(oflags, self.friendly)
end

function filter:IsPet(oflags)
    return CombatLog_Object_IsA(oflags, self.pet)
end

function filter:IsOwned(oflags)
    return CombatLog_Object_IsA(oflags, self.owned)
end

function filter:IsEnemy(oflags)
    return CombatLog_Object_IsA(oflags, filter.enemy)
end

nekometer.filter = filter
