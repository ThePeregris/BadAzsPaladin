-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 3.7 (All Seals Fix)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.3+

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v3.8|r"

-- ============================================================
-- [ CONFIGURAÇÃO E DADOS ESTÁTICOS ]
-- ============================================================
local PaladinSlotCache = { ["Holy Strike"] = nil }

local DebuffTextures = {
    ["Seal of the Crusader"] = "Spell_Holy_HolySmite",        
    ["Seal of Wisdom"]       = "Spell_Holy_RighteousnessAura", 
    ["Seal of Light"]        = "Spell_Holy_HealingAura",
    ["Seal of Justice"]      = "Spell_Holy_SealOfWrath"
}

local BlessingList = {
    "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings",
    "Blessing of Sanctuary", "Blessing of Light", "Blessing of Salvation"
}

-- ============================================================
-- [ 1. INICIALIZAÇÃO E CACHE ]
-- ============================================================
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
loadFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        if not BadAzsPalDB then BadAzsPalDB = {} end
        if not BadAzsPalDB.Opener then BadAzsPalDB.Opener = "Seal of the Crusader" end
        if not BadAzsPalDB.Main   then BadAzsPalDB.Main = "Seal of Command" end
        if not BadAzsPalDB.Blessing then BadAzsPalDB.Blessing = "Blessing of Might" end
        if not BadAzsPalDB.BlessIndex then BadAzsPalDB.BlessIndex = 1 end

        DEFAULT_CHAT_FRAME:AddMessage(BadAzsPalVersion .. " Loaded.")
    end

    -- Scanner de Holy Strike para proteção de Toggle
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        PaladinSlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
                    BadAzs_TooltipScanner:SetAction(i)
                    local name = BadAzs_TooltipScannerTextLeft1:GetText()
                    if name == "Holy Strike" then PaladinSlotCache["Holy Strike"] = i; break end
                end
            end
        end
    end
end)

-- ============================================================
-- [ 2. HELPERS DE SELOS E BUFFS ]
-- ============================================================

-- Verifica se temos QUALQUER selo ativo (Fix para Turtle WoW)
local function BadAzs_HasSeal()
    return BadAzs_HasBuff("HolySmite") or       
           BadAzs_HasBuff("ThunderBolt") or     
           BadAzs_HasBuff("RighteousnessAura") or 
           BadAzs_HasBuff("HealingAura") or     
           BadAzs_HasBuff("SealOfWrath") or
           BadAzs_HasBuff("SealOfFury") or      
           BadAzs_HasBuff("Ability_Warrior_InnerRage") 
end

-- Função de Utilidade para Buffs (Usa a Via Rápida do Core)
local function Paladin_SmartBuff()
    local spell = BadAzsPalDB.Blessing
    -- Se segurar CTRL, tenta a versão Greater
    if IsControlKeyDown() then
        spell = "Greater " .. spell
    end
    -- Usa BadAzs_Util para trocar de alvo, buffar e voltar pro Boss instantaneamente
    BadAzs_Util(spell)
end

-- Função para Purificar no Mouseover (Pode ser usada em macro separada)
function BadAzsPalCleanse()
    BadAzs_Util("Cleanse")
end

-- ============================================================
-- [ 3. ROTAÇÃO RETRIBUTION (DPS) ]
-- ============================================================
function BadAzsRet()
    -- SE segurar ALT: Buffa o alvo sob o mouse sem perder o Boss
    if IsAltKeyDown() then Paladin_SmartBuff(); return end
    
    -- Se não tem alvo, não faz nada
    if not UnitExists("target") then return end

    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local mana = BadAzs_GetMana()       
    local thp = BadAzs_GetTargetHP()    
    local targetType = UnitCreatureType("target")
    
    -- 1. Aura
    if not BadAzs_HasBuff("Sanctity") then BadAzs_Cast("Sanctity Aura") end

    -- 2. Execute
    if thp <= 20 and BadAzs_Ready("Hammer of Wrath") then BadAzs_Cast("Hammer of Wrath"); return end

    -- 3. Crusader Strike
    if BadAzs_Ready("Crusader Strike") then BadAzs_Cast("Crusader Strike"); return end

    -- 4. Exorcism
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready("Exorcism") then 
        BadAzs_Cast("Exorcism"); return 
    end

    -- 5. Lógica Seal/Judge
    local DesiredSeal = BadAzsPalDB.Main
    local openerTexture = DebuffTextures[BadAzsPalDB.Opener]
    
    -- Se o opener não estiver no alvo, foca nele primeiro
    if BadAzsPalDB.Opener ~= "None" and openerTexture and not BadAzs_TargetHasDebuff(openerTexture) then
        DesiredSeal = BadAzsPalDB.Opener
    end

    -- Mana Save: Se a mana estiver crítica, usa Wisdom
    if mana < 15 then DesiredSeal = "Seal of Wisdom" end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzs_Cast("Judgement"); return end
    if not BadAzs_HasSeal() then BadAzs_Cast(DesiredSeal); return end

    -- 6. Holy Strike (Proteção Anti-Toggle)
    if mana > 60 and BadAzs_Ready("Holy Strike") then
        local slot = PaladinSlotCache["Holy Strike"]
        if slot and not IsCurrentAction(slot) then BadAzs_Cast("Holy Strike") end
    end
end

-- ============================================================
-- [ 4. ROTAÇÃO PROTECTION (TANK) ]
-- ============================================================
function BadAzsProt()
    if IsAltKeyDown() then Paladin_SmartBuff(); return end
    if not UnitExists("target") then return end

    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()

    local mana = BadAzs_GetMana()

    if not BadAzs_HasBuff("SealOfFury") then BadAzs_Cast("Righteous Fury"); return end
    if BadAzs_Ready("Holy Shield") then BadAzs_Cast("Holy Shield"); return end
    if BadAzs_Ready("Crusader Strike") then BadAzs_Cast("Crusader Strike"); return end

    if mana > 30 and BadAzs_Ready("Consecration") and CheckInteractDistance("target", 3) then
        BadAzs_Cast("Consecration"); return
    end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzs_Cast("Judgement"); return end
    
    local TankSeal = "Seal of Righteousness"
    if mana < 15 then TankSeal = "Seal of Wisdom" end
    if not BadAzs_HasSeal() then BadAzs_Cast(TankSeal); return end
end

-- ============================================================
-- [ 5. COMANDOS SLASH ]
-- ============================================================
function BadAzs_CycleBlessing()
    local i = BadAzsPalDB.BlessIndex + 1
    if i > table.getn(BlessingList) then i = 1 end
    BadAzsPalDB.BlessIndex = i
    BadAzsPalDB.Blessing = BlessingList[i]
    UIErrorsFrame:AddMessage("Next Buff: " .. BlessingList[i], 1, 1, 0)
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Buff: " .. BlessingList[i])
end

SLASH_BAPCONFIG1 = "/bapconfig"
SlashCmdList["BAPCONFIG"] = function(msg)
    msg = string.lower(msg)
    if msg == "cycle" then BadAzs_CycleBlessing()
    elseif string.find(msg, "opener") then
        if string.find(msg, "crus") then BadAzsPalDB.Opener = "Seal of the Crusader"
        elseif string.find(msg, "wis") then BadAzsPalDB.Opener = "Seal of Wisdom"
        elseif string.find(msg, "none") then BadAzsPalDB.Opener = "None" end
        DEFAULT_CHAT_FRAME:AddMessage("Opener set to: " .. BadAzsPalDB.Opener)
    elseif string.find(msg, "main") then
        if string.find(msg, "comm") then BadAzsPalDB.Main = "Seal of Command"
        elseif string.find(msg, "right") then BadAzsPalDB.Main = "Seal of Righteousness" end
        DEFAULT_CHAT_FRAME:AddMessage("Main Seal set to: " .. BadAzsPalDB.Main)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /bapconfig cycle | opener [crus/wis/none] | main [comm/right]")
    end
end

SLASH_BAPRET1 = "/bapret"; SlashCmdList["BAPRET"] = BadAzsRet
SLASH_BAPPROT1 = "/bapprot"; SlashCmdList["BAPPROT"] = BadAzsProt
