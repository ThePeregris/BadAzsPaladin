-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 3.7 (Stable Revert)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.1+

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v3.7|r"

-- ============================================================
-- [ CONFIGURAÇÃO E DADOS ESTÁTICOS ]
-- ============================================================
local DebuffTextures = {
    ["Seal of the Crusader"] = "Spell_Holy_HolySmite",        
    ["Seal of Wisdom"]       = "Spell_Holy_RighteousnessAura", 
    ["Seal of Light"]        = "Spell_Holy_HealingAura"        
}

local BlessingList = { 
    "Blessing of Might", "Blessing of Wisdom", "Blessing of Kings", 
    "Blessing of Sanctuary", "Blessing of Light", "Blessing of Salvation" 
}

local BadAzs_SlotCache = { ["Holy Strike"] = nil }

-- Scanner de Tooltip
BadAzsPal_Scanner = CreateFrame("GameTooltip", "BadAzsPal_Scanner", nil, "GameTooltipTemplate")
BadAzsPal_Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

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

    -- Scanner de Holy Strike (Proteção Anti-Toggle)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        BadAzs_SlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
                    BadAzsPal_Scanner:ClearLines()
                    BadAzsPal_Scanner:SetAction(i)
                    local name = BadAzsPal_ScannerTextLeft1:GetText()
                    if name == "Holy Strike" then BadAzs_SlotCache["Holy Strike"] = i; break end
                end
            end
        end
    end
end)

-- ============================================================
-- [ 2. HELPERS ]
-- ============================================================

local function BadAzs_HasSeal()
    return BadAzs_HasBuff("HolySmite") or       -- Crusader
           BadAzs_HasBuff("ThunderBolt") or     -- Righteousness
           BadAzs_HasBuff("RighteousnessAura") or -- Wisdom
           BadAzs_HasBuff("HealingAura") or     -- Light
           BadAzs_HasBuff("SealOfWrath") or     -- Justice
           BadAzs_HasBuff("SealOfFury") or      -- Righteous Fury
           BadAzs_HasBuff("Ability_Warrior_InnerRage") -- Command
end

-- ============================================================
-- [ 3. MÓDULOS DE COMBATE ]
-- ============================================================

-- RETRIBUTION
function BadAzsRet()
    if not UnitExists("target") then return end
    
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local mana = BadAzs_GetMana()       
    local thp = BadAzs_GetTargetHP()    
    local targetType = UnitCreatureType("target")
    
    -- Aura
    if not BadAzs_HasBuff("Sanctity") then BadAzs_Cast("Sanctity Aura") end

    -- Execute
    if thp <= 20 and BadAzs_Ready("Hammer of Wrath") then BadAzs_Cast("Hammer of Wrath"); return end

    -- Crusader Strike (Turtle WoW)
    if BadAzs_Ready("Crusader Strike") then BadAzs_Cast("Crusader Strike"); return end

    -- Exorcism (Undead/Demon)
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready("Exorcism") then 
        BadAzs_Cast("Exorcism"); return 
    end

    -- Lógica Seal/Judge
    local DesiredSeal = BadAzsPalDB.Main
    local openerTex = DebuffTextures[BadAzsPalDB.Opener]
    
    if BadAzsPalDB.Opener ~= "None" and openerTex and not BadAzs_TargetHasDebuff(openerTex) then
        DesiredSeal = BadAzsPalDB.Opener
    end

    if mana < 15 then DesiredSeal = "Seal of Wisdom" end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzs_Cast("Judgement"); return end
    if not BadAzs_HasSeal() then BadAzs_Cast(DesiredSeal); return end

    -- Holy Strike (Proteção de Toggle)
    if mana > 60 and BadAzs_Ready("Holy Strike") then
        local slot = BadAzs_SlotCache["Holy Strike"]
        if slot and not IsCurrentAction(slot) then BadAzs_Cast("Holy Strike") end
    end
end

-- PROTECTION
function BadAzsProt()
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
-- [ 4. COMANDOS SLASH ]
-- ============================================================
function BadAzs_CycleBlessing()
    local i = (BadAzsPalDB.BlessIndex or 1) + 1
    if i > table.getn(BlessingList) then i = 1 end
    BadAzsPalDB.BlessIndex = i
    BadAzsPalDB.Blessing = BlessingList[i]
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Buff: " .. BlessingList[i])
end

SLASH_BAPCONFIG1 = "/bapconfig"
SlashCmdList["BAPCONFIG"] = function(msg)
    msg = string.lower(msg)
    if msg == "cycle" then 
        BadAzs_CycleBlessing()
    elseif string.find(msg, "opener") then
        if string.find(msg, "crus") then BadAzsPalDB.Opener = "Seal of the Crusader"
        elseif string.find(msg, "wis") then BadAzsPalDB.Opener = "Seal of Wisdom"
        elseif string.find(msg, "none") then BadAzsPalDB.Opener = "None" end
        DEFAULT_CHAT_FRAME:AddMessage("Opener: " .. BadAzsPalDB.Opener)
    elseif string.find(msg, "main") then
        if string.find(msg, "comm") then BadAzsPalDB.Main = "Seal of Command"
        elseif string.find(msg, "right") then BadAzsPalDB.Main = "Seal of Righteousness" end
        DEFAULT_CHAT_FRAME:AddMessage("Main Seal: " .. BadAzsPalDB.Main)
    end
end

SLASH_BAPRET1 = "/bapret"; SlashCmdList["BAPRET"] = BadAzsRet
SLASH_BAPPROT1 = "/bapprot"; SlashCmdList["BAPPROT"] = BadAzsProt
