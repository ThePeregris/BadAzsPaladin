-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris
-- Version: 1.3 (Seal & Blessing Selector)
-- Target:  Turtle WoW (1.12 / LUA 5.0)

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v1.3|r"
local _Cast = CastSpellByName

-- ============================================================
-- [ CONFIGURAÇÃO DINÂMICA ]
-- ============================================================
-- As preferências são salvas em BadAzsPalDB (Seal e Blessing)

local MyAuras = {
    RET = "Sanctity Aura",
    PROT = "Retribution Aura"
}

-- Padrão de Mana para fallback
local SealMana = "Seal of Wisdom"

-- ============================================================
-- [ INICIALIZAÇÃO ]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:SetScript("OnEvent", function()
    if not BadAzsPalDB then BadAzsPalDB = { Seal = "Seal of Command", Blessing = "Blessing of Might" } end
    
    -- Fallbacks de segurança
    if not BadAzsPalDB.Seal then BadAzsPalDB.Seal = "Seal of Command" end
    if not BadAzsPalDB.Blessing then BadAzsPalDB.Blessing = "Blessing of Might" end

    DEFAULT_CHAT_FRAME:AddMessage(BadAzsPalVersion)
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[Config]|r: " .. BadAzsPalDB.Seal .. " / " .. BadAzsPalDB.Blessing)
    DEFAULT_CHAT_FRAME:AddMessage("Use /badpal para ver as opções.")
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
    if not BadAzs_HasSeal() then
        if mana < 20 and BadAzs_Ready(SealMana) then
            _Cast(SealMana)
        else
            _Cast(BadAzsPalDB.Seal) -- Usa preferência salva
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
        if mana < 15 then _Cast(SealMana) else _Cast("Seal of Righteousness") end
        return
    end
end

-- ============================================================
-- [ UTILITÁRIOS & BUFFS (ALT KEY) ]
-- ============================================================
function BadAzsBuffs()
    -- Tenta castar a blessing salva se não estiver em GCD global
    -- Nota: Buffs podem ser castados em combate, removi a restrição de combate para flexibilidade
    _Cast(BadAzsPalDB.Blessing)
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
    
    -- [[ SELETOR DE SELOS ]]
    if string.find(msg, "seal soc") or string.find(msg, "seal command") then
        BadAzsPalDB.Seal = "Seal of Command"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cffFF0000Seal of Command|r")
        
    elseif string.find(msg, "seal sor") or string.find(msg, "seal right") then
        BadAzsPalDB.Seal = "Seal of Righteousness"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cff00FFFFSeal of Righteousness|r")
        
    elseif string.find(msg, "seal crusader") then
        BadAzsPalDB.Seal = "Seal of the Crusader"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cffFFFF00Seal of the Crusader|r")
    
    -- [[ SELETOR DE BLESSINGS (Novo na v1.3) ]]
    elseif string.find(msg, "bless might") then
        BadAzsPalDB.Blessing = "Blessing of Might"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Blessing (ALT): |cffFF0000Might|r")

    elseif string.find(msg, "bless kings") then
        BadAzsPalDB.Blessing = "Blessing of Kings"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Blessing (ALT): |cffFFFFFFKings|r")

    elseif string.find(msg, "bless wisdom") then
        BadAzsPalDB.Blessing = "Blessing of Wisdom"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Blessing (ALT): |cff0000FFWisdom|r")

    elseif string.find(msg, "bless sanc") then
        BadAzsPalDB.Blessing = "Blessing of Sanctuary"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Blessing (ALT): |cffCCCCCCSanctuary|r")
        
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs Paladin v1.3]|r")
        DEFAULT_CHAT_FRAME:AddMessage("Selo Atual: " .. BadAzsPalDB.Seal)
        DEFAULT_CHAT_FRAME:AddMessage("Blessing (ALT): " .. BadAzsPalDB.Blessing)
        DEFAULT_CHAT_FRAME:AddMessage("--- Comandos ---")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal seal [soc | sor | crusader]")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal bless [might | kings | wisdom | sanc]")
    end
end

SLASH_BADRET1 = "/bret"
SlashCmdList["BADRET"] = BadAzs_RetWrapper

SLASH_BADPROT1 = "/bprot"
SlashCmdList["BADPROT"] = BadAzs_ProtWrapper
