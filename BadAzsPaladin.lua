-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris
-- Version: 1.2 (Seal Selector)
-- Target:  Turtle WoW (1.12 / LUA 5.0)

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v1.2|r"
local _Cast = CastSpellByName

-- ============================================================
-- [ CONFIGURAÇÃO DINÂMICA ]
-- ============================================================
-- A preferência de Selo agora é salva em BadAzsPalDB.Seal
-- Padrões de Backup:
local MySeals = {
    PROT = "Seal of Righteousness",
    MANA = "Seal of Wisdom"
}

local MyAuras = {
    RET = "Sanctity Aura",
    PROT = "Retribution Aura"
}

-- ============================================================
-- [ INICIALIZAÇÃO ]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:SetScript("OnEvent", function()
    if not BadAzsPalDB then BadAzsPalDB = { Seal = "Seal of Command" } end
    -- Fallback se a variável estiver vazia
    if not BadAzsPalDB.Seal then BadAzsPalDB.Seal = "Seal of Command" end

    DEFAULT_CHAT_FRAME:AddMessage(BadAzsPalVersion)
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[Selo Atual]|r: " .. BadAzsPalDB.Seal)
    DEFAULT_CHAT_FRAME:AddMessage("Use /badpal seal [soc | sor] para trocar.")
end)

-- Verifica se temos qualquer Selo ativo (Usando Helper Global)
local function BadAzs_HasSeal()
    return BadAzs_HasBuff("Ability_Warrior_InnerRage") or       -- Righteousness
           BadAzs_HasBuff("Ability_ThunderBolt") or             -- Command
           BadAzs_HasBuff("Holy_RighteousnessAura") or          -- Crusader
           BadAzs_HasBuff("Spell_Holy_RighteousnessAura")       -- Wisdom/Light
end

-- ============================================================
-- [ ROTAÇÃO RET (DPS) ]
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
    if thp <= 20 and BadAzs_Ready("Hammer of Wrath") then 
        _Cast("Hammer of Wrath")
        return
    end

    -- 3. Crusader Strike (Turtle WoW Priority)
    if BadAzs_Ready("Crusader Strike") then
        _Cast("Crusader Strike")
        return
    end

    -- 4. Exorcism (Undead/Demon)
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready("Exorcism") then
        _Cast("Exorcism")
        return
    end

    -- 5. Judgement
    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then
        _Cast("Judgement")
        return
    end

    -- 6. Re-Selo Dinâmico
    -- Usa o selo definido em BadAzsPalDB.Seal
    if not BadAzs_HasSeal() then
        if mana < 20 and BadAzs_Ready(MySeals.MANA) then
            _Cast(MySeals.MANA)
        else
            _Cast(BadAzsPalDB.Seal) -- AQUI ESTÁ A MUDANÇA
        end
        return
    end

    -- 7. Holy Strike Dump
    if mana > 60 and BadAzs_Ready("Holy Strike") then
        _Cast("Holy Strike")
    end
end

-- ============================================================
-- [ ROTAÇÃO PROT (TANK) ]
-- ============================================================
function BadAzsProt()
    BadAzs_StartAttack()
    UIErrorsFrame:Clear()

    local mana = BadAzs_GetMana()

    -- 1. Righteous Fury
    if not BadAzs_HasBuff("Spell_Holy_SealOfFury") then
        _Cast("Righteous Fury")
        return
    end

    -- 2. Holy Shield (Mitigação)
    if BadAzs_Ready("Holy Shield") then
        _Cast("Holy Shield")
        return
    end

    -- 3. Crusader Strike (Threat)
    if BadAzs_Ready("Crusader Strike") then
        _Cast("Crusader Strike")
        return
    end

    -- 4. Consecration (AoE Threat)
    if mana > 30 and BadAzs_Ready("Consecration") and CheckInteractDistance("target", 3) then
        _Cast("Consecration")
        return
    end

    -- 5. Judgement
    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then
        _Cast("Judgement")
        return
    end

    -- 6. Selo de Tank (Fixo em Righteousness para Threat consistente)
    if not BadAzs_HasSeal() then
        if mana < 15 then _Cast(MySeals.MANA) else _Cast(MySeals.PROT) end
        return
    end
end

-- ============================================================
-- [ UTILITÁRIOS & BUFFS ]
-- ============================================================
function BadAzsBuffs()
    if not UnitAffectingCombat("player") then
        _Cast("Blessing of Might")
    end
end

-- ============================================================
-- [ SLASH COMMANDS & CONFIGURAÇÃO ]
-- ============================================================

function BadAzs_RetWrapper() 
    if IsAltKeyDown() then BadAzsBuffs() else BadAzsRet() end 
end

function BadAzs_ProtWrapper() 
    if IsAltKeyDown() then BadAzsBuffs() else BadAzsProt() end 
end

-- Handler de Configuração (/badpal)
SLASH_BADAZSPALCMD1 = "/badpal"
SlashCmdList["BADAZSPALCMD"] = function(msg)
    msg = string.lower(msg)
    
    if string.find(msg, "seal soc") or string.find(msg, "seal command") then
        BadAzsPalDB.Seal = "Seal of Command"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo Principal: |cffFF0000Seal of Command|r")
        
    elseif string.find(msg, "seal sor") or string.find(msg, "seal right") then
        BadAzsPalDB.Seal = "Seal of Righteousness"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo Principal: |cff00FFFFSeal of Righteousness|r")
        
    elseif string.find(msg, "seal crusader") then
        BadAzsPalDB.Seal = "Seal of the Crusader"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo Principal: |cffFFFF00Seal of the Crusader|r")
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs Paladin Config]|r")
        DEFAULT_CHAT_FRAME:AddMessage("Selo Atual: " .. BadAzsPalDB.Seal)
        DEFAULT_CHAT_FRAME:AddMessage("Comandos:")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal seal soc      (Seal of Command - 2H)")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal seal sor      (Seal of Righteousness - 1H/SP)")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal seal crusader (Seal of the Crusader)")
    end
end

SLASH_BADRET1 = "/bret"
SlashCmdList["BADRET"] = BadAzs_RetWrapper

SLASH_BADPROT1 = "/bprot"
SlashCmdList["BADPROT"] = BadAzs_ProtWrapper
