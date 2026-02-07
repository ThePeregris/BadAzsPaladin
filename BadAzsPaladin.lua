-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris
-- Version: 1.1 (Core Integrated)

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v1.1|r"
local _Cast = CastSpellByName

-- ============================================================
-- [ CONFIGURAÇÃO ]
-- ============================================================
local MySeals = {
    RET = "Seal of Command",
    PROT = "Seal of Righteousness",
    MANA = "Seal of Wisdom"
}

local MyAuras = {
    RET = "Sanctity Aura",
    PROT = "Retribution Aura"
}

-- Verifica se temos qualquer Selo ativo (Usando Helper Global)
local function BadAzs_HasSeal()
    return BadAzs_HasBuff("Ability_Warrior_InnerRage") or 
           BadAzs_HasBuff("Ability_ThunderBolt") or       
           BadAzs_HasBuff("Holy_RighteousnessAura") or    
           BadAzs_HasBuff("Spell_Holy_RighteousnessAura") 
end

-- ============================================================
-- [ ROTAÇÃO RET ]
-- ============================================================
function BadAzsRet()
    BadAzs_StartAttack() -- Core API
    UIErrorsFrame:Clear()
    
    local mana = BadAzs_GetMana()      -- Usando Global Core
    local thp = BadAzs_GetTargetHP()   -- Usando Global Core
    local targetType = UnitCreatureType("target")
    
    -- 1. Aura Check
    if not BadAzs_HasBuff("Sanctity") and not UnitIsMounted("player") then 
        _Cast(MyAuras.RET) 
    end

    -- 2. Execute
    if thp <= 20 and BadAzs_Ready("Hammer of Wrath") then -- Usando Global Core
        _Cast("Hammer of Wrath")
        return
    end

    -- 3. Crusader Strike
    if BadAzs_Ready("Crusader Strike") then
        _Cast("Crusader Strike")
        return
    end

    -- 4. Exorcism
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready("Exorcism") then
        _Cast("Exorcism")
        return
    end

    -- 5. Judgement
    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then
        _Cast("Judgement")
        return
    end

    -- 6. Re-Selo
    if not BadAzs_HasSeal() then
        if mana < 20 and BadAzs_Ready(MySeals.MANA) then
            _Cast(MySeals.MANA)
        else
            _Cast(MySeals.RET)
        end
        return
    end

    -- 7. Holy Strike Dump
    if mana > 60 and BadAzs_Ready("Holy Strike") then
        _Cast("Holy Strike")
    end
end
