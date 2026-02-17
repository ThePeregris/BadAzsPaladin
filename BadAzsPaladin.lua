-- [[ [|cff355E3BB|r]adAzs |cff32CD32Paladin|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 3.9 (Self-Sufficient / Generic Core)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.3+

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v3.9|r"

-- Cache Local para proteção do Holy Strike
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

local GreaterBlessings = {
    ["Blessing of Might"]     = "Greater Blessing of Might",
    ["Blessing of Wisdom"]    = "Greater Blessing of Wisdom",
    ["Blessing of Kings"]     = "Greater Blessing of Kings",
    ["Blessing of Sanctuary"] = "Greater Blessing of Sanctuary",
    ["Blessing of Light"]     = "Greater Blessing of Light",
    ["Blessing of Salvation"] = "Greater Blessing of Salvation"
}

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
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[Config]|r Opener: " .. BadAzsPalDB.Opener .. " || Main: " .. BadAzsPalDB.Main)
    end

    -- Scanner de Slots (Trazido do Core para cá)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        PaladinSlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                -- Procura especificamente pela textura de imbuir arma (Holy Strike)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
                    -- Usa o scanner global do Core apenas como ferramenta
                    BadAzs_TooltipScanner:SetAction(i)
                    local name = BadAzs_TooltipScannerTextLeft1:GetText()
                    if name == "Holy Strike" then 
                        PaladinSlotCache["Holy Strike"] = i 
                        break 
                    end
                end
            end
        end
    end
end)

-- Cast Wrapper Local (Proteção)
local function BadAzsPal_Cast(spellName)
    -- Proteção para não desligar o Holy Strike se já estiver ativo
    if spellName == "Holy Strike" then
        local slot = PaladinSlotCache["Holy Strike"]
        if slot and IsCurrentAction(slot) then return end 
    end
    
    -- Chama o Core para executar o ataque no target
    BadAzs_Cast(spellName)
end

local function BadAzs_HasSeal()
    return BadAzs_HasBuff("HolySmite") or       
           BadAzs_HasBuff("ThunderBolt") or     
           BadAzs_HasBuff("RighteousnessAura") or 
           BadAzs_HasBuff("HealingAura") or     
           BadAzs_HasBuff("SealOfWrath") or
           BadAzs_HasBuff("SealOfFury") or       
           BadAzs_HasBuff("Ability_Warrior_InnerRage") 
end

local function BadAzs_TargetHasOpenerDebuff()
    if not BadAzsPalDB then return true end
    local opener = BadAzsPalDB.Opener
    if opener == "None" then return true end
    
    local texture = DebuffTextures[opener]
    if not texture then return true end
    return BadAzs_TargetHasDebuff(texture)
end

-- Utilidade com Mouseover (ALT)
local function BadAzs_SmartBuff()
    local spell = BadAzsPalDB.Blessing
    if IsControlKeyDown() then
        local greater = GreaterBlessings[spell]
        if greater then spell = greater end
    end
    
    -- Usa a nova função global do Core v2.3
    -- false = não usa "assist", apenas buffa e volta
    BadAzs_ManualMouseover(spell, false)
end

-- [[ ROTAÇÃO RETRIBUTION ]]
function BadAzsRet()
    if IsAltKeyDown() then BadAzs_SmartBuff(); return end
    
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    local mana = BadAzs_GetMana()        
    local thp = BadAzs_GetTargetHP()     
    local targetType = UnitCreatureType("target")
    
    if not BadAzs_HasBuff("Sanctity") then BadAzsPal_Cast("Sanctity Aura") end
    if thp <= 20 and BadAzs_Ready("Hammer of Wrath") then BadAzsPal_Cast("Hammer of Wrath"); return end
    if BadAzs_Ready("Crusader Strike") then BadAzsPal_Cast("Crusader Strike"); return end
    if (targetType == "Undead" or targetType == "Demon") and BadAzs_Ready("Exorcism") then 
        BadAzsPal_Cast("Exorcism"); return 
    end

    local OpenerDone = BadAzs_TargetHasOpenerDebuff()
    local DesiredSeal = BadAzsPalDB.Main
    
    if not OpenerDone and BadAzsPalDB.Opener ~= "None" then DesiredSeal = BadAzsPalDB.Opener end
    if mana < 15 then DesiredSeal = "Seal of Wisdom" end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzsPal_Cast("Judgement"); return end
    if not BadAzs_HasSeal() then BadAzsPal_Cast(DesiredSeal); return end

    if mana > 60 and BadAzs_Ready("Holy Strike") then BadAzsPal_Cast("Holy Strike") end
end

-- [[ ROTAÇÃO PROTECTION ]]
function BadAzsProt()
    if IsAltKeyDown() then BadAzs_SmartBuff(); return end
    
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()

    local mana = BadAzs_GetMana()

    if not BadAzs_HasBuff("SealOfFury") then BadAzsPal_Cast("Righteous Fury"); return end
    if BadAzs_Ready("Holy Shield") then BadAzsPal_Cast("Holy Shield"); return end
    if BadAzs_Ready("Crusader Strike") then BadAzsPal_Cast("Crusader Strike"); return end

    if mana > 30 and BadAzs_Ready("Consecration") and CheckInteractDistance("target", 3) then
        BadAzsPal_Cast("Consecration"); return
    end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzsPal_Cast("Judgement"); return end
    
    local TankSeal = "Seal of Righteousness"
    if mana < 15 then TankSeal = "Seal of Wisdom" end
    if not BadAzs_HasSeal() then BadAzsPal_Cast(TankSeal); return end
end

function BadAzs_CycleBlessing()
    if not BadAzsPalDB then return end
    local i = BadAzsPalDB.BlessIndex or 1
    i = i + 1
    if i > table.getn(BlessingList) then i = 1 end
    
    BadAzsPalDB.BlessIndex = i
    BadAzsPalDB.Blessing = BlessingList[i]
    
    local msg = BlessingList[i]
    if string.find(msg, "Might") then msg = "|cffFF0000" .. msg .. "|r"
    elseif string.find(msg, "Wisdom") then msg = "|cff0000FF" .. msg .. "|r"
    elseif string.find(msg, "Kings") then msg = "|cffFFFFFF" .. msg .. "|r"
    elseif string.find(msg, "Salvation") then msg = "|cff00FF00" .. msg .. "|r"
    end
    
    UIErrorsFrame:AddMessage("Next Buff: " .. msg, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Buff Cycle: " .. msg)
end

SLASH_BADAZSPALCMD1 = "/bapconfig"
SlashCmdList["BADAZSPALCMD"] = function(msg)
    msg = string.lower(msg)
    
    if string.find(msg, "cycle") then BadAzs_CycleBlessing(); return end
    
    if string.find(msg, "opener crus") then BadAzsPalDB.Opener = "Seal of the Crusader"
    elseif string.find(msg, "opener wis") then BadAzsPalDB.Opener = "Seal of Wisdom"
    elseif string.find(msg, "opener light") then BadAzsPalDB.Opener = "Seal of Light"
    elseif string.find(msg, "opener none") then BadAzsPalDB.Opener = "None"
    
    elseif string.find(msg, "main comm") or string.find(msg, "main soc") then BadAzsPalDB.Main = "Seal of Command"
    elseif string.find(msg, "main right") or string.find(msg, "main sor") then BadAzsPalDB.Main = "Seal of Righteousness"
    elseif string.find(msg, "main wis") then BadAzsPalDB.Main = "Seal of Wisdom"
    
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs Paladin v3.9]|r")
        DEFAULT_CHAT_FRAME:AddMessage("/bapconfig cycle")
        DEFAULT_CHAT_FRAME:AddMessage("/bapconfig opener [crus | wis | light | none]")
        DEFAULT_CHAT_FRAME:AddMessage("/bapconfig main [comm | right | wis]")
        DEFAULT_CHAT_FRAME:AddMessage("Current: " .. (BadAzsPalDB.Opener or "?") .. " -> " .. (BadAzsPalDB.Main or "?"))
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Updated.")
end

SLASH_BAPRET1 = "/bapret"; SlashCmdList["BAPRET"] = BadAzsRet
SLASH_BAPPROT1 = "/bapprot"; SlashCmdList["BAPPROT"] = BadAzsProt
