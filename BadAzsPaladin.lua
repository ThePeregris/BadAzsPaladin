-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 1.5 (Safe Mode & Turtle WoW)
-- Target:  Turtle WoW (1.12 / LUA 5.0)

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v1.5 (Safe)|r"
local _Cast = CastSpellByName

-- ============================================================
-- [ CONFIGURAÇÃO DINÂMICA ]
-- ============================================================
local MyAuras = {
    RET = "Sanctity Aura",
    PROT = "Retribution Aura"
}
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

-- Verifica se temos qualquer Selo ativo (Texturas Vanilla 1.12)
local function BadAzs_HasSeal()
    -- Depende do Core v1.7+ para BadAzs_HasBuff
    if not BadAzs_HasBuff then return false end

    return BadAzs_HasBuff("Ability_ThunderBolt") or             -- Righteousness
           BadAzs_HasBuff("Ability_Warrior_InnerRage") or       -- Command
           BadAzs_HasBuff("Spell_Holy_Holysmite") or            -- Crusader
           BadAzs_HasBuff("Spell_Holy_RighteousnessAura") or    -- Wisdom/Light (Variante 1)
           BadAzs_HasBuff("Spell_Holy_HealingAura")             -- Light (Variante 2)
end

-- ============================================================
-- [ ROTAÇÃO RET (DPS) ]
-- ============================================================
function BadAzsRet()
    -- 1. Segurança de Alvo: Se não tem alvo, tenta pegar e para.
    if not UnitExists("target") then 
        if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
        return 
    end
    
    -- Inicia Combate
    if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
    UIErrorsFrame:Clear()
    
    -- 2. Coleta de Dados Segura (Fallback se Core falhar)
    local mana = 0
    if BadAzs_GetMana then mana = BadAzs_GetMana() else mana = UnitMana("player") end -- Fallback simples

    local thp = 100
    if BadAzs_GetTargetHP then thp = BadAzs_GetTargetHP() end
    
    -- Segurança para UnitCreatureType (evita erro nil)
    local targetType = UnitCreatureType("target") or "Unknown"
    
    -- 3. Aura Check (Prioridade Zero)
    if BadAzs_HasBuff and not BadAzs_HasBuff("Sanctity") and not UnitIsMounted("player") then 
        _Cast(MyAuras.RET) 
    end

    -- 4. Execute (Hammer of Wrath)
    -- Só checa se HP < 20
    if thp > 0 and thp <= 20 and BadAzs_Ready and BadAzs_Ready("Hammer of Wrath") then 
        _Cast("Hammer of Wrath")
        return
    end

    -- 5. Crusader Strike (Turtle WoW MVP)
    if BadAzs_Ready and BadAzs_Ready("Crusader Strike") then
        _Cast("Crusader Strike")
        return
    end

    -- 6. Exorcism (Undead/Demon)
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready and BadAzs_Ready("Exorcism") then
        _Cast("Exorcism")
        return
    end

    -- 7. Judgement (Explode o Selo)
    if BadAzs_HasSeal() and BadAzs_Ready and BadAzs_Ready("Judgement") then
        _Cast("Judgement")
        return
    end

    -- 8. Re-Selo Dinâmico (Se estiver sem selo)
    if not BadAzs_HasSeal() then
        if mana < 20 and BadAzs_Ready and BadAzs_Ready(SealMana) then
            _Cast(SealMana)
        else
            _Cast(BadAzsPalDB.Seal)
        end
        return
    end

    -- 9. Holy Strike Dump (Se sobrar mana)
    if mana > 60 and BadAzs_Ready and BadAzs_Ready("Holy Strike") then
        _Cast("Holy Strike")
    end
end

-- ============================================================
-- [ ROTAÇÃO PROT (TANK) ]
-- ============================================================
function BadAzsProt()
    if not UnitExists("target") then 
        if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
        return 
    end
    
    if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
    UIErrorsFrame:Clear()

    local mana = 0
    if BadAzs_GetMana then mana = BadAzs_GetMana() end

    -- 1. Righteous Fury (Essencial para Tank)
    if BadAzs_HasBuff and not BadAzs_HasBuff("Spell_Holy_SealOfFury") then
        _Cast("Righteous Fury")
        return
    end

    -- 2. Holy Shield (Mitigação Primária)
    if BadAzs_Ready and BadAzs_Ready("Holy Shield") then
        _Cast("Holy Shield")
        return
    end

    -- 3. Crusader Strike (Gera Threat + Mana no Turtle)
    if BadAzs_Ready and BadAzs_Ready("Crusader Strike") then
        _Cast("Crusader Strike")
        return
    end

    -- 4. Consecration (AoE Threat - Cuidado com Mana)
    if mana > 30 and BadAzs_Ready and BadAzs_Ready("Consecration") and CheckInteractDistance("target", 3) then
        _Cast("Consecration")
        return
    end

    -- 5. Judgement
    if BadAzs_HasSeal() and BadAzs_Ready and BadAzs_Ready("Judgement") then
        _Cast("Judgement")
        return
    end

    -- 6. Recast do Selo (Fixo em Righteousness para Threat Constante)
    if not BadAzs_HasSeal() then
        if mana < 15 then _Cast(SealMana) else _Cast("Seal of Righteousness") end
        return
    end
end

-- ============================================================
-- [ UTILITÁRIOS & BUFFS (ALT KEY) ]
-- ============================================================
function BadAzsBuffs()
    local target = "player"
    if UnitExists("target") and UnitIsFriend("player", "target") then
        target = "target"
    end
    CastSpellByName(BadAzsPalDB.Blessing, OnSelf)
    if SpellIsTargeting() then SpellTargetUnit(target) end
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
    
    -- [[ SELETOR DE SELOS (Comandos Curtos) ]]
    if string.find(msg, "seal comm") then
        BadAzsPalDB.Seal = "Seal of Command"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cffFF0000Seal of Command|r")
        
    elseif string.find(msg, "seal right") then
        BadAzsPalDB.Seal = "Seal of Righteousness"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cff00FFFFSeal of Righteousness|r")
        
    elseif string.find(msg, "seal crus") then
        BadAzsPalDB.Seal = "Seal of the Crusader"
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Selo: |cffFFFF00Seal of the Crusader|r")
    
    -- [[ SELETOR DE BLESSINGS ]]
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
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs Paladin v1.5]|r")
        DEFAULT_CHAT_FRAME:AddMessage("Selo Atual: " .. BadAzsPalDB.Seal)
        DEFAULT_CHAT_FRAME:AddMessage("Blessing (ALT): " .. BadAzsPalDB.Blessing)
        DEFAULT_CHAT_FRAME:AddMessage("--- Comandos ---")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal seal [comm | right | crus]")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal bless [might | kings | wisdom | sanc]")
    end
end

SLASH_BADRET1 = "/bret"
SlashCmdList["BADRET"] = BadAzs_RetWrapper

SLASH_BADPROT1 = "/bprot"
SlashCmdList["BADPROT"] = BadAzs_ProtWrapper