-- [[ [|cff355E3BB|r]adAzs |cffF58CBAPaladin|r ]]
-- Author:  ThePeregris
-- Version: 4.2 (Self-Sufficient + Book Panel + Localizacao EN/PT)
-- Target:  Vanilla/Classic WoW (1.12 / LUA 5.0)
-- Requires: BadAzs Core (apenas utilitarios universais: Vision/Focus/Racial/ManualMouseover)

local BadAzsPalVersion = "|cffF58CBA[BadAzsPaladin v4.2]|r"

-- ==========================================================
-- LOCALIZACAO (EN padrao / PT alternativo)
-- ==========================================================
local BadAzsPal_L = {
    EN = {
        loaded      = "Loaded. Type /badazs pally to configure.",
        title       = "BadAzs Paladin",
        openerLabel = "Opener Seal",
        mainLabel   = "Main Seal",
        blessLabel  = "ALT Blessing (Smart Buff)",
        explainOpener = "Seal cast first on a fresh target so its Judgement lands before your main seal takes over. Click to cycle: Crusader, Wisdom, Light, or None.",
        explainMain   = "Seal kept active for sustained damage once the opener debuff is already on the target. Click to cycle: Command, Righteousness, Wisdom.",
        explainBless  = "Hold ALT and mouseover a party member to cast this Blessing on them. Hold CTRL+ALT for the Greater version. Click to cycle which Blessing is used.",
        cmdHeader   = "Macros",
        cmdList = {
            "/bapret - Retribution rotation",
            "/bapprot - Protection rotation",
            "Hold ALT - Cast Blessing on mouseover",
            "Hold CTRL+ALT - Greater Blessing",
            "/badazs pally - Open this panel"
        }
    },
    PT = {
        loaded      = "Carregado. Digite /badazs pally para configurar.",
        title       = "BadAzs Paladin",
        openerLabel = "Selo de Abertura",
        mainLabel   = "Selo Principal",
        blessLabel  = "Bencao no ALT (Smart Buff)",
        explainOpener = "Selo lancado primeiro num alvo novo pra debuff do Judgement cair antes do selo principal assumir. Clique pra ciclar: Crusader, Wisdom, Light ou None.",
        explainMain   = "Selo mantido ativo pro dano sustentado depois que o debuff de abertura ja esta no alvo. Clique pra ciclar: Command, Righteousness, Wisdom.",
        explainBless  = "Segure ALT e passe o mouse num membro do grupo pra lancar essa Bencao nele. Segure CTRL+ALT pra versao Maior. Clique pra ciclar qual Bencao e usada.",
        cmdHeader   = "Macros",
        cmdList = {
            "/bapret - Rotacao Retribution",
            "/bapprot - Rotacao Protection",
            "Segure ALT - Lanca Bencao no mouseover",
            "Segure CTRL+ALT - Bencao Maior",
            "/badazs pally - Abre este painel"
        }
    }
}

-- ==========================================================
-- [0] MOTOR SITUACIONAL INTERNALIZADO (antes vinha do Core)
-- ==========================================================
CreateFrame("GameTooltip", "BadAzsPal_TooltipScanner", nil, "GameTooltipTemplate")
BadAzsPal_TooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local function BadAzsPal_RawCast(spellName)
    if spellName == "Attack" then
        -- Toggle de auto-attack agora mora no Core (BadAzs_StartAttack) - e
        -- mecanica identica pra qualquer classe, unica fonte de verdade.
        if BadAzs_StartAttack then BadAzs_StartAttack() end
        return
    end
    CastSpellByName(spellName)
end

local function BadAzsPal_FindSpellId(spellName)
    local i = 1
    while true do
        local name = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then return i end
        i = i + 1
    end
    return nil
end

local function BadAzsPal_Ready(spellName)
    local id = BadAzsPal_FindSpellId(spellName)
    if not id then return false end
    local start = GetSpellCooldown(id, BOOKTYPE_SPELL)
    local isUsable, notEnoughMana = true, false
    if IsUsableSpell then isUsable, notEnoughMana = IsUsableSpell(id, BOOKTYPE_SPELL) end
    return isUsable and not notEnoughMana and start == 0
end

local function BadAzsPal_HasBuff(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local texture = UnitBuff("player", i)
        if string.find(texture, buffName) then return true end
        i = i + 1
    end
    return false
end

local function BadAzsPal_TargetHasDebuff(textureName)
    local i = 1
    while UnitDebuff("target", i) do
        local texture = UnitDebuff("target", i)
        if string.find(texture, textureName) then return true end
        i = i + 1
    end
    return false
end

local function BadAzsPal_GetTargetHP()
    if not UnitExists("target") then return 0 end
    local h, hmax = UnitHealth("target"), UnitHealthMax("target")
    if not hmax or hmax == 0 then return 0 end
    return (h / hmax) * 100
end

local function BadAzsPal_GetMana()
    local cur, max = UnitMana("player"), UnitManaMax("player")
    if max == 0 then return 0 end
    return (cur / max) * 100
end

-- ======================================================
-- SEALS (BUFFS NO PLAYER)
-- ======================================================
local SealBuffIcons = {
    ["Seal of the Crusader"]  = "Spell_Holy_HolySmite",
    ["Seal of Wisdom"]        = "Spell_Holy_RighteousnessAura",
    ["Seal of Command"]       = "Ability_Warrior_InnerRage",
    ["Seal of Light"]         = "Spell_Holy_HealingAura",
    ["Seal of Justice"]       = "Spell_Holy_SealOfWrath",
    ["Seal of Righteousness"] = "Ability_ThunderBolt"
}

-- Selos julgados (debuff no target)
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

local OpenerList = { "Seal of the Crusader", "Seal of Wisdom", "Seal of Light", "None" }
local MainList = { "Seal of Command", "Seal of Righteousness", "Seal of Wisdom" }

-- ======================================================
-- INIT / CACHE
-- ======================================================
local PaladinSlotCache = { ["Holy Strike"] = nil }

local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
loadFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
loadFrame:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        if not BadAzsPalDB then BadAzsPalDB = {} end
        if not BadAzsPalDB.Opener then BadAzsPalDB.Opener = "Seal of the Crusader" end
        if not BadAzsPalDB.Main then BadAzsPalDB.Main = "Seal of Command" end
        if not BadAzsPalDB.Blessing then BadAzsPalDB.Blessing = "Blessing of Might" end
        if not BadAzsPalDB.BlessIndex then BadAzsPalDB.BlessIndex = 1 end
        if not BadAzsPalDB.Locale then BadAzsPalDB.Locale = "EN" end

        DEFAULT_CHAT_FRAME:AddMessage(BadAzsPalVersion .. " " .. BadAzsPal_L[BadAzsPalDB.Locale].loaded)
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_SLOT_CHANGED" then
        PaladinSlotCache["Holy Strike"] = nil
        for i = 1, 120 do
            if HasAction(i) then
                local texture = GetActionTexture(i)
                if texture and string.find(texture, "Spell_Holy_Imbue") then
                    BadAzsPal_TooltipScanner:SetAction(i)
                    local name = BadAzsPal_TooltipScannerTextLeft1:GetText()
                    if name == "Holy Strike" then
                        PaladinSlotCache["Holy Strike"] = i
                        break
                    end
                end
            end
        end
    end
end)

local function BadAzsPal_Cast(spellName)
    if spellName == "Holy Strike" then
        local slot = PaladinSlotCache["Holy Strike"]
        if slot and IsCurrentAction(slot) then return end
    end
    BadAzsPal_RawCast(spellName)
end

-- ======================================================
-- DETECCAO DE SEAL ATIVO
-- ======================================================
local function BadAzs_HasSeal()
    for _, icon in pairs(SealBuffIcons) do
        if BadAzsPal_HasBuff(icon) then return true end
    end
    return false
end

local function BadAzs_TargetHasOpenerDebuff()
    if not BadAzsPalDB then return true end
    local opener = BadAzsPalDB.Opener
    if opener == "None" then return true end
    local texture = DebuffTextures[opener]
    if not texture then return true end
    return BadAzsPal_TargetHasDebuff(texture)
end

-- ======================================================
-- CICLO DE BENCAO (corrigido - antes era chamado e nunca existia)
-- ======================================================
function BadAzs_CycleBlessing()
    BadAzsPalDB.BlessIndex = (BadAzsPalDB.BlessIndex or 0) + 1
    if BadAzsPalDB.BlessIndex > table.getn(BlessingList) then
        BadAzsPalDB.BlessIndex = 1
    end
    BadAzsPalDB.Blessing = BlessingList[BadAzsPalDB.BlessIndex]
    DEFAULT_CHAT_FRAME:AddMessage("|cffF58CBA[BadAzs]|r Bencao (ALT): " .. BadAzsPalDB.Blessing)
    if BadAzsPal_RefreshPanel then BadAzsPal_RefreshPanel() end
end

local function BadAzs_CycleOpener()
    local idx = 1
    for i, v in ipairs(OpenerList) do if v == BadAzsPalDB.Opener then idx = i end end
    idx = idx + 1
    if idx > table.getn(OpenerList) then idx = 1 end
    BadAzsPalDB.Opener = OpenerList[idx]
end

local function BadAzs_CycleMain()
    local idx = 1
    for i, v in ipairs(MainList) do if v == BadAzsPalDB.Main then idx = i end end
    idx = idx + 1
    if idx > table.getn(MainList) then idx = 1 end
    BadAzsPalDB.Main = MainList[idx]
end

-- ======================================================
-- SMART BUFF (ALT) - usa utilitario generico do Core
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
    if BadAzs_Sustain then BadAzs_Sustain() end

    BadAzsPal_Cast("Attack")
    UIErrorsFrame:Clear()

    local mana = BadAzsPal_GetMana()
    local thp = BadAzsPal_GetTargetHP()
    local targetType = UnitCreatureType("target")

    if not BadAzsPal_HasBuff("Sanctity") then BadAzsPal_Cast("Sanctity Aura") end
    if thp <= 20 and BadAzsPal_Ready("Hammer of Wrath") then BadAzsPal_Cast("Hammer of Wrath"); return end
    if BadAzsPal_Ready("Crusader Strike") then BadAzsPal_Cast("Crusader Strike"); return end
    if (targetType == "Undead" or targetType == "Demon") and BadAzsPal_Ready("Exorcism") then
        BadAzsPal_Cast("Exorcism"); return
    end

    local OpenerDone = BadAzs_TargetHasOpenerDebuff()
    local DesiredSeal = BadAzsPalDB.Main

    if not OpenerDone and BadAzsPalDB.Opener ~= "None" then DesiredSeal = BadAzsPalDB.Opener end
    if mana < 15 then DesiredSeal = "Seal of Wisdom" end

    if BadAzs_HasSeal() and BadAzsPal_Ready("Judgement") then BadAzsPal_Cast("Judgement"); return end
    if not BadAzs_HasSeal() then BadAzsPal_Cast(DesiredSeal); return end

    if mana > 60 and BadAzsPal_Ready("Holy Strike") then BadAzsPal_Cast("Holy Strike") end
end

-- ======================================================
-- PROTECTION
-- ======================================================
function BadAzsProt()
    if IsAltKeyDown() then BadAzs_SmartBuff(); return end
    if BadAzs_Sustain then BadAzs_Sustain() end

    BadAzsPal_Cast("Attack")
    UIErrorsFrame:Clear()

    local mana = BadAzsPal_GetMana()

    if not BadAzsPal_HasBuff("SealOfFury") then BadAzsPal_Cast("Righteous Fury"); return end
    if BadAzsPal_Ready("Holy Shield") then BadAzsPal_Cast("Holy Shield"); return end
    if BadAzsPal_Ready("Crusader Strike") then BadAzsPal_Cast("Crusader Strike"); return end

    if mana > 30 and BadAzsPal_Ready("Consecration") and CheckInteractDistance("target", 3) then
        BadAzsPal_Cast("Consecration"); return
    end

    if BadAzs_HasSeal() and BadAzsPal_Ready("Judgement") then BadAzsPal_Cast("Judgement"); return end

    local TankSeal = "Seal of Righteousness"
    if mana < 15 then TankSeal = "Seal of Wisdom" end
    if not BadAzs_HasSeal() then BadAzsPal_Cast(TankSeal); return end
end

-- ==========================================================
-- PAINEL GRAFICO DE CONFIGURACAO (/badazs pally)
-- Formato de livro: pagina esquerda = controles, pagina direita = explicacoes
-- ==========================================================
local Panel = CreateFrame("Frame", "BadAzsPaladinPanel", UIParent)
Panel:SetWidth(620)
Panel:SetHeight(500)
Panel:SetPoint("CENTER", 0, 0)
Panel:SetMovable(true)
Panel:EnableMouse(true)
Panel:RegisterForDrag("LeftButton")
Panel:SetScript("OnDragStart", function() this:StartMoving() end)
Panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
Panel:SetFrameStrata("DIALOG")
Panel:Hide()

local LeftPage = CreateFrame("Frame", nil, Panel)
LeftPage:SetWidth(300)
LeftPage:SetHeight(280)
LeftPage:SetPoint("TOPLEFT", Panel, "TOPLEFT", 0, -60)
LeftPage:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local RightPage = CreateFrame("Frame", nil, Panel)
RightPage:SetWidth(300)
RightPage:SetHeight(280)
RightPage:SetPoint("TOPLEFT", Panel, "TOPLEFT", 320, -60)
RightPage:SetBackdrop({
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local title = Panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("|cffF58CBABadAzs Paladin|r")

local closeBtn = CreateFrame("Button", "BadAzsPaladinPanelClose", Panel, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -4, -4)

local langBtn = CreateFrame("Button", "BadAzsPal_LangBtn", Panel, "UIPanelButtonTemplate")
langBtn:SetPoint("TOPLEFT", 8, -10)
langBtn:SetWidth(44); langBtn:SetHeight(20)

-- ==================== PAGINA ESQUERDA: CONTROLES ====================
local openerLabel = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
openerLabel:SetPoint("TOP", 0, -14)

local openerBtn = CreateFrame("Button", "BadAzsPal_OpenerBtn", LeftPage, "UIPanelButtonTemplate")
openerBtn:SetPoint("TOP", 0, -34)
openerBtn:SetWidth(230)
openerBtn:SetHeight(22)

local mainLabel = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainLabel:SetPoint("TOP", 0, -104)

local mainBtn = CreateFrame("Button", "BadAzsPal_MainBtn", LeftPage, "UIPanelButtonTemplate")
mainBtn:SetPoint("TOP", 0, -124)
mainBtn:SetWidth(230)
mainBtn:SetHeight(22)

local blessLabel = LeftPage:CreateFontString(nil, "OVERLAY", "GameFontNormal")
blessLabel:SetPoint("TOP", 0, -194)

local blessBtn = CreateFrame("Button", "BadAzsPal_BlessBtn", LeftPage, "UIPanelButtonTemplate")
blessBtn:SetPoint("TOP", 0, -214)
blessBtn:SetWidth(230)
blessBtn:SetHeight(22)

-- ==================== PAGINA DIREITA: EXPLICACOES ====================
local explainOpener = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainOpener:SetPoint("TOP", 0, -14)
explainOpener:SetWidth(260)
explainOpener:SetJustifyH("LEFT")
explainOpener:SetSpacing(2)

local explainMain = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainMain:SetPoint("TOP", 0, -104)
explainMain:SetWidth(260)
explainMain:SetJustifyH("LEFT")
explainMain:SetSpacing(2)

local explainBless = RightPage:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explainBless:SetPoint("TOP", 0, -194)
explainBless:SetWidth(260)
explainBless:SetJustifyH("LEFT")
explainBless:SetSpacing(2)

-- ==================== RODAPE: LEMBRETE DE COMANDOS ====================
local divider = Panel:CreateTexture(nil, "ARTWORK")
divider:SetPoint("TOP", 0, -348)
divider:SetWidth(590); divider:SetHeight(1)
divider:SetTexture(0.5, 0.5, 0.5, 0.5)

local cmdHeader = Panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
cmdHeader:SetPoint("TOP", 0, -360)

local cmdText = Panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
cmdText:SetPoint("TOP", 0, -380)
cmdText:SetWidth(560)
cmdText:SetJustifyH("LEFT")
cmdText:SetSpacing(3)

function BadAzsPal_RefreshPanel()
    local L = BadAzsPal_L[BadAzsPalDB.Locale]

    title:SetText("|cffF58CBA" .. L.title .. "|r")
    langBtn:SetText(BadAzsPalDB.Locale)

    openerLabel:SetText("|cffffd200" .. L.openerLabel .. "|r")
    mainLabel:SetText("|cffffd200" .. L.mainLabel .. "|r")
    blessLabel:SetText("|cffffd200" .. L.blessLabel .. "|r")

    openerBtn:SetText(BadAzsPalDB.Opener)
    mainBtn:SetText(BadAzsPalDB.Main)
    blessBtn:SetText(BadAzsPalDB.Blessing)

    explainOpener:SetText(L.explainOpener)
    explainMain:SetText(L.explainMain)
    explainBless:SetText(L.explainBless)

    cmdHeader:SetText("|cffffd200" .. L.cmdHeader .. "|r")
    local lines = ""
    local i
    for i = 1, table.getn(L.cmdList) do
        if i > 1 then lines = lines .. "\n" end
        lines = lines .. L.cmdList[i]
    end
    cmdText:SetText(lines)
end

langBtn:SetScript("OnClick", function()
    if BadAzsPalDB.Locale == "EN" then BadAzsPalDB.Locale = "PT" else BadAzsPalDB.Locale = "EN" end
    BadAzsPal_RefreshPanel()
end)

openerBtn:SetScript("OnClick", function()
    BadAzs_CycleOpener()
    BadAzsPal_RefreshPanel()
end)

mainBtn:SetScript("OnClick", function()
    BadAzs_CycleMain()
    BadAzsPal_RefreshPanel()
end)

blessBtn:SetScript("OnClick", function()
    BadAzs_CycleBlessing()
end)

Panel:SetScript("OnShow", function() BadAzsPal_RefreshPanel() end)

-- ==========================================================
-- ==========================================================
-- SLASH COMMANDS
-- ==========================================================
BadAzs_PanelRegistry = BadAzs_PanelRegistry or {}
BadAzs_PanelRegistry["pally"] = function()
    if Panel:IsShown() then Panel:Hide() else Panel:Show() end
end

SLASH_BAPRET1  = "/bapret";  SlashCmdList["BAPRET"]  = BadAzsRet
SLASH_BAPPROT1 = "/bapprot"; SlashCmdList["BAPPROT"] = BadAzsProt
