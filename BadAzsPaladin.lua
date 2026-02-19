-- [[ [|cff355E3BB|r]adAzs |cff32CD32Paladin|r ]]
-- Author:  ThePeregris & Gemini
-- Version: 3.9 (Self-Sufficient / Generic Core)
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core v2.3+

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v3.9|r"

-- Cache Local para proteção do Holy Strike
local PaladinSlotCache = { ["Holy Strike"] = nil }

-- ======================================================
-- SEALS (BUFFS NO PLAYER) — MAPEAMENTO CONFIRMADO
-- ======================================================
local SealBuffIcons = {
    ["Seal of the Crusader"]   = "Spell_Holy_HolySmite",
    ["Seal of Wisdom"]        = "Spell_Holy_RighteousnessAura",
    ["Seal of Command"]       = "Ability_Warrior_InnerRage",
    ["Seal of Light"]         = "Spell_Holy_HealingAura",
    ["Seal of Justice"]       = "Spell_Holy_SealOfWrath",
    ["Seal of Righteousness"] = "Ability_ThunderBolt"
}

-- ======================================================
-- SEALS JULGADOS (DEBUFF NO TARGET)
-- ======================================================
local DebuffTextures = {
    ["Seal of the Crusader"] = "Spell_Holy_HolySmite",
    ["Seal of Wisdom"]       = "Spell_Holy_RighteousnessAura",
    ["Seal of Light"]        = "Spell_Holy_HealingAura",
    ["Seal of Justice"]      = "Spell_Holy_SealOfWrath"
}

-- ======================================================
-- BLESSINGS (BUFFS NO PLAYER) — MAPEAMENTO CONFIRMADO
-- ======================================================
local BlessingBuffIcons = {
    ["Blessing of Might"]      = "Spell_Holy_FistOfJustice",
    ["Blessing of Wisdom"]    = "Spell_Holy_SealOfWisdom",
    ["Blessing of Salvation"] = "Spell_Holy_SealOfSalvation",
    ["Blessing of Kings"]     = "Spell_Magic_MageArmor",
    ["Blessing of Light"]     = "Spell_Holy_PrayerOfHealing02"
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

-- ======================================================
-- INIT / CACHE
-- ======================================================
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

    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        PaladinSlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
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

-- ======================================================
-- CAST WRAPPER
-- ======================================================
local function BadAzsPal_Cast(spellName)
    if spellName == "Holy Strike" then
        local slot = PaladinSlotCache["Holy Strike"]
        if slot and IsCurrentAction(slot) then return end
    end
    BadAzs_Cast(spellName)
end

-- ======================================================
-- DETECÇÃO DE SEAL ATIVO (FINAL)
-- ======================================================
local function BadAzs_HasSeal()
    for _, icon in pairs(SealBuffIcons) do
        if BadAzs_HasBuff(icon) then
            return true
        end
    end
    return false
end

local function BadAzs_TargetHasOpenerDebuff()
    if not BadAzsPalDB then return true end
    local opener = BadAzsPalDB.Opener
    if opener == "None" then return true end

    local texture = DebuffTextures[opener]
    if not texture then return true end
    return BadAzs_TargetHasDebuff(texture)
end

-- ======================================================
-- SMART BUFF (ALT)
-- ======================================================
local function BadAzs_SmartBuff()
    local spell = BadAzsPalDB.Blessing
    if IsControlKeyDown() then
        local greater = GreaterBlessings[spell]
        if greater then spell = greater end
    end
    BadAzs_ManualMouseover(spell, false)
end

-- ======================================================
-- RETRIBUTION
-- ======================================================
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

-- ======================================================
-- PROTECTION
-- ======================================================
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

-- ======================================================
-- SLASH COMMANDS
-- ======================================================
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

SLASH_BAPRET1   = "/bapret";   SlashCmdList["BAPRET"]   = BadAzsRet
SLASH_BAPPROT1  = "/bapprot";  SlashCmdList["BAPPROT"]  = BadAzsProt
