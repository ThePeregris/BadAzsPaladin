-- [[ [|cffF58CBA|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris
-- Version: 3.2
-- Target:  Turtle WoW (1.12 / LUA 5.0)
-- Requer:  BadAzsCore.lua (v1.8+)

local BadAzsPalVersion = "|cffF58CBABadAzsPaladin v3.3|r"
local _Cast = CastSpellByName

-- ============================================================
-- [ CONFIGURAÇÃO E DADOS ESTÁTICOS ]
-- ============================================================

-- Texturas para identificar Debuffs (Opener)
local DebuffTextures = {
    ["Seal of the Crusader"] = "HolySmite",
    ["Seal of Wisdom"]       = "RighteousnessAura",
    ["Seal of Light"]        = "HealingAura"
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

-- Cache para evitar Toggle de Holy Strike
local BadAzs_SlotCache = { ["Holy Strike"] = nil }

-- Scanner de Tooltip Isolado
CreateFrame("GameTooltip", "BadAzsPal_Scanner", nil, "GameTooltipTemplate")
BadAzsPal_Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

-- ============================================================
-- [1. INICIALIZAÇÃO, FILTROS E CACHE]
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

        -- Filtro de Spam do Chat
        local block = {
            "fail", "not ready", "enough rage", "enough mana", "Another action", "range", 
            "No target", "recovered", "Ability", "Must be in", "nothing to attack", 
            "facing", "Unknown unit", "Inventory is full", "Cannot equip", 
            "Item is not ready", "Target needs to be", "You are dead", "spell is not learned"
        }
        for i = 1, 7 do
            local frame = _G["ChatFrame"..i]
            if frame and not frame.BHookedPal then
                local original = frame.AddMessage
                frame.AddMessage = function(self, msg, r, g, b, id)
                    if msg and type(msg) == "string" then
                        for _, p in pairs(block) do if string.find(msg, p) then return end end
                    end
                    original(self, msg, r, g, b, id)
                end
                frame.BHookedPal = true
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(BadAzsPalVersion)
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[Config]|r Opener: " .. BadAzsPalDB.Opener .. " || Main: " .. BadAzsPalDB.Main)
    end

    -- Atualiza Cache de Slots (Procura onde está o Holy Strike)
    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        BadAzs_SlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
                    BadAzsPal_Scanner:SetAction(i)
                    local name = BadAzsPal_ScannerTextLeft1:GetText()
                    if name == "Holy Strike" then 
                        BadAzs_SlotCache["Holy Strike"] = i 
                        break 
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- [2. HELPERS DE CONFLITO E SEGURANÇA]
-- ============================================================

local function BadAzs_IsQueued(spellName)
    local slot = BadAzs_SlotCache[spellName]
    if slot and IsCurrentAction(slot) then
        return true
    end
    return false
end

local function BadAzs_Cast(t) 
    if t == "Attack" then 
        if BadAzs_StartAttack then BadAzs_StartAttack() else AttackTarget() end
        return 
    end
    if t == "Holy Strike" and BadAzs_IsQueued("Holy Strike") then
        return 
    end
    _Cast(t) 
end

local function BadAzs_HasSeal()
    if not BadAzs_HasBuff then return false end
    return BadAzs_HasBuff("InnerRage") or 
           BadAzs_HasBuff("ThunderBolt") or 
           BadAzs_HasBuff("Holy_Righteousness") or 
           BadAzs_HasBuff("SealOfFury")
end

local function BadAzs_TargetHasOpenerDebuff()
    if not BadAzsPalDB or not BadAzs_TargetHasDebuff then return true end
    local opener = BadAzsPalDB.Opener
    if opener == "None" then return true end
    
    local texture = DebuffTextures[opener]
    if not texture then return true end
    return BadAzs_TargetHasDebuff(texture)
end

-- ============================================================
-- [3. SISTEMA SMART BUFF (ALT KEY)]
-- ============================================================
local function BadAzs_SmartBuff()
    local spell = BadAzsPalDB.Blessing
    if IsControlKeyDown() then
        local greater = GreaterBlessings[spell]
        if greater then spell = greater end
    end
    
    local targetUnit = "player"
    local restoreTarget = false
    
    if UnitExists("mouseover") and UnitIsFriend("player", "mouseover") and not UnitIsDead("mouseover") then
        targetUnit = "mouseover"
        restoreTarget = true
    elseif UnitExists("target") and UnitIsFriend("player", "target") and not UnitIsDead("target") then
        targetUnit = "target"
        restoreTarget = false
    end
    
    if restoreTarget then
        TargetUnit(targetUnit); _Cast(spell); TargetLastTarget()
    else
        if targetUnit == "player" then TargetUnit("player") end 
        _Cast(spell)
        if targetUnit == "player" and UnitExists("target") then TargetLastTarget() end
    end
end

-- ============================================================
-- [4. ROTAÇÃO RETRIBUTION (DPS)]
-- ============================================================
function BadAzsRet()
    if IsAltKeyDown() then BadAzs_SmartBuff(); return end
    
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()
    
    if not BadAzs_GetMana or not BadAzs_Ready then 
        DEFAULT_CHAT_FRAME:AddMessage("BadAzsCore not loaded!")
        return 
    end
    
    local mana = BadAzs_GetMana()      
    local thp = BadAzs_GetTargetHP()   
    local targetType = UnitCreatureType("target")
    
    -- 1. Aura (Removido UnitIsMounted para corrigir erro no 1.12)
    -- Se você estiver montado e apertar o macro, ele vai castar a aura e te desmontar.
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
    local OpenerDone = BadAzs_TargetHasOpenerDebuff()
    local DesiredSeal = BadAzsPalDB.Main
    
    if not OpenerDone and BadAzsPalDB.Opener ~= "None" then DesiredSeal = BadAzsPalDB.Opener end
    if mana < 15 then DesiredSeal = "Seal of Wisdom" end

    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzs_Cast("Judgement"); return end
    if not BadAzs_HasSeal() then BadAzs_Cast(DesiredSeal); return end

    -- 6. Holy Strike (Cache Protected)
    if mana > 60 and BadAzs_Ready("Holy Strike") then BadAzs_Cast("Holy Strike") end
end

-- ============================================================
-- [5. ROTAÇÃO PROTECTION (TANK)]
-- ============================================================
function BadAzsProt()
    if IsAltKeyDown() then BadAzs_SmartBuff(); return end
    
    BadAzs_Cast("Attack")
    UIErrorsFrame:Clear()

    if not BadAzs_GetMana then return end
    local mana = BadAzs_GetMana()

    -- 1. Righteous Fury
    if not BadAzs_HasBuff("SealOfFury") then BadAzs_Cast("Righteous Fury"); return end

    -- 2. Holy Shield
    if BadAzs_Ready("Holy Shield") then BadAzs_Cast("Holy Shield"); return end

    -- 3. Crusader Strike
    if BadAzs_Ready("Crusader Strike") then BadAzs_Cast("Crusader Strike"); return end

    -- 4. Consecration
    if mana > 30 and BadAzs_Ready("Consecration") and CheckInteractDistance("target", 3) then
        BadAzs_Cast("Consecration"); return
    end

    -- 5. Seal Logic
    if BadAzs_HasSeal() and BadAzs_Ready("Judgement") then BadAzs_Cast("Judgement"); return end
    
    local TankSeal = "Seal of Righteousness"
    if mana < 15 then TankSeal = "Seal of Wisdom" end
    if not BadAzs_HasSeal() then BadAzs_Cast(TankSeal); return end
end

-- ============================================================
-- [6. COMANDOS SLASH]
-- ============================================================
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

SLASH_BADAZSPALCMD1 = "/badpal"
SlashCmdList["BADAZSPALCMD"] = function(msg)
    msg = string.lower(msg)
    
    if string.find(msg, "cycle") then BadAzs_CycleBlessing(); return end

    -- OPENER
    if string.find(msg, "opener crus") then BadAzsPalDB.Opener = "Seal of the Crusader"
    elseif string.find(msg, "opener wis") then BadAzsPalDB.Opener = "Seal of Wisdom"
    elseif string.find(msg, "opener light") then BadAzsPalDB.Opener = "Seal of Light"
    elseif string.find(msg, "opener none") then BadAzsPalDB.Opener = "None"
    
    -- MAIN
    elseif string.find(msg, "main comm") or string.find(msg, "main soc") then BadAzsPalDB.Main = "Seal of Command"
    elseif string.find(msg, "main right") or string.find(msg, "main sor") then BadAzsPalDB.Main = "Seal of Righteousness"
    elseif string.find(msg, "main wis") then BadAzsPalDB.Main = "Seal of Wisdom"
    
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs Paladin v3.3]|r")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal cycle")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal opener [crus | wis | light | none]")
        DEFAULT_CHAT_FRAME:AddMessage("/badpal main [comm | right | wis]")
        DEFAULT_CHAT_FRAME:AddMessage("Current: " .. (BadAzsPalDB.Opener or "?") .. " -> " .. (BadAzsPalDB.Main or "?"))
        return
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Updated.")
end

SLASH_BADRET1 = "/bret"; SlashCmdList["BADRET"] = BadAzsRet
SLASH_BADPROT1 = "/bprot"; SlashCmdList["BADPROT"] = BadAzsProt
