# [B]adAzs Paladin – MODULAR TACTICAL SUITE (v3.4)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Core Integration*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsPaladin

**Version:** v3.4 (Dual Seal & Smart Buff)  
**Target:** Turtle WoW (Client 1.12.x – LUA 5.0)  
**Architecture:** Conflict Free / Slot Cache / Dual Seal Engine  
**Requires:** BadAzsCore (v1.8+)  
**Author:** **ThePeregris**

**BadAzsPaladin** is a **Decision Support System (DSS)** designed for the Turtle WoW meta.  
Unlike version 1.x, the **v3.4** engine introduces a **Dual Seal System** (Opener vs. Main) and a **Smart Buff System** that handles mouseover casting and Greater Blessings automatically.  

✔️ **Dual Seal Logic (Opener/Main)**  
✔️ **Smart Buffs (Mouseover & Greater Blessings)**  
✔️ **Holy Strike Anti-Toggle Protection (Slot Cache)**

---

## 2. CORE FEATURES

### ⚔️ Core Attack API (Shared)

Utilizes `BadAzs_StartAttack()` from BadAzsCore v1.8 to ensure safe Auto-Attack engagement without stopping swings when switching targets.

### 🛡️ Holy Strike Protection (Slot Cache)

The script scans your action bars to find where **Holy Strike** is located. It uses `IsCurrentAction()` to check if the spell is already queued (glowing).

* **Result:** It never "un-queues" your Holy Strike by accidentally pressing the button twice.

### 🔄 Dual Seal Engine

The script divides combat into two phases:

1. **Opener:** Applies a specific Seal to debuff the enemy (e.g., *Seal of the Crusader*).
2. **Main:** Once the debuff is detected, it switches to your damage/tanking seal (e.g., *Seal of Command*).

---

## 3. CONFIGURATION (New in v3.4)

### Setting the Opener (Debuff)

Which seal to use *first* to apply a debuff?

* `/badpal opener crus` → **Seal of the Crusader** (Standard DPS).
* `/badpal opener wis` → **Seal of Wisdom** (Mana Restore).
* `/badpal opener light` → **Seal of Light** (Healing).
* `/badpal opener none` → **None** (Skip straight to damage).

### Setting the Main Seal (Damage/Tank)

Which seal to use *after* the debuff is applied?

* `/badpal main comm` → **Seal of Command** (2H Weapons).
* `/badpal main right` → **Seal of Righteousness** (Tank / 1H).
* `/badpal main wis` → **Seal of Wisdom** (Mana Battery Mode).

### Setting the Blessing (Cycle)

Select which blessing is used by the **ALT** key.

* `/badpal cycle` → Cycles through available blessings (Might > Wisdom > Kings > etc).

---

## 4. TACTICAL OVERRIDES (Smart Buff System)

### ⌨️ ALT — Smart Buffing

Hold **ALT** while pressing your rotation macro (`/bret` or `/bprot`).

**Priority Logic:**

1. **Mouseover (Friend):** Buffs the unit under your mouse pointer (Party/Raid Frame or 3D model).
2. **Target (Friend):** Buffs your current target if friendly.
3. **Self:** If no mouseover or friendly target, buffs **Player**.

**Greater Blessings:**

* Hold **CTRL + ALT**: Casts the **Greater Blessing** (15 min) version of the selected spell.
* *Requires "Symbol of Kings".*

---

## 5. COMBAT MODULES

### 🛡️ `/bprot` — PROTECTION (TANK)

* **Righteous Fury:** Auto-cast protection.
* **Holy Shield:** Spammed on cooldown.
* **Consecration:** Smart usage (Mana > 30% + Range check).
* **Threat:** Prioritizes Crusader Strike > Judgement > Seal of Righteousness.

### ⚔️ `/bret` — RETRIBUTION (DPS)

* **Hammer of Wrath:** Priority #1 (< 20% HP).
* **Crusader Strike:** Priority #2 (Mana/Damage).
* **Exorcism:** Auto-cast on Undead/Demon.
* **Seal Logic:** Checks for Opener Debuff -> Switches to Main Seal.
* **Holy Strike:** Dumps excess mana (> 60%) without clipping attacks.

---

## 6. INSTALLATION

**Order in `.toc` file is critical:**

```ini
BadAzsCore.lua
BadAzsPaladin.lua

```

---

## 7. QUICK COMMANDS

| Command | Action |
| --- | --- |
| `/bret` | Retribution Rotation |
| `/bprot` | Protection/Tank Rotation |
| `/badpal cycle` | Select Next Blessing |
| `/badpal opener crus` | Set Opener: Crusader |
| `/badpal main soc` | Set Main: Command |
| `ALT + Macro` | Smart Buff (Normal) |
| `CTRL + ALT + Macro` | Smart Buff (Greater) |

---

---

# PT-BR / PORTUGUÊS

# [B]adAzs Paladin – MODULAR TACTICAL SUITE (v3.4)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Integração Core*

## 1. MANIFESTO TÉCNICO

**Versão:** v3.4 (Selo Duplo & Smart Buff)
**Alvo:** Turtle WoW (Client 1.12.x – LUA 5.0)
**Arquitetura:** Livre de Conflitos / Cache de Slot / Motor de Selo Duplo
**Requer:** BadAzsCore (v1.8+)
**Autor:** **ThePeregris & Gemini**

O **BadAzsPaladin v3.4** é um salto evolutivo. Diferente da versão 1.x, este motor introduz o **Sistema de Selo Duplo** (Abertura vs Principal) e um **Sistema de Smart Buff** que gerencia mouseover e Greater Blessings automaticamente.

✔️ **Lógica de Selo Duplo (Opener/Main)**
✔️ **Smart Buffs (Mouseover & Greater Blessings)**
✔️ **Proteção de Holy Strike (Slot Cache)**

---

## 2. FUNCIONALIDADES PRINCIPAIS

### 🛡️ Proteção do Holy Strike (Slot Cache)

O script escaneia suas barras de ação para encontrar onde o **Holy Strike** está. Ele usa `IsCurrentAction()` para saber se a magia já está "armada" (brilhando).

* **Resultado:** Ele nunca cancela seu Holy Strike por apertar o botão duas vezes acidentalmente.

### 🔄 Motor de Selo Duplo

O combate é dividido em duas fases:

1. **Opener (Abertura):** Aplica um selo para colocar Debuff no inimigo (ex: *Seal of the Crusader*).
2. **Main (Principal):** Assim que o debuff é detectado, troca para o selo de dano/tank (ex: *Seal of Command*).

---

## 3. CONFIGURAÇÃO (Novo na v3.4)

### Configurar Abertura (Opener)

Qual selo usar *primeiro*?

* `/badpal opener crus` → **Seal of the Crusader** (Padrão DPS).
* `/badpal opener wis` → **Seal of Wisdom** (Restaurar Mana).
* `/badpal opener light` → **Seal of Light** (Cura).
* `/badpal opener none` → **Nenhum** (Vai direto para o dano).

### Configurar Principal (Main)

Qual selo usar *depois* do debuff?

* `/badpal main comm` → **Seal of Command** (Armas 2H).
* `/badpal main right` → **Seal of Righteousness** (Tank / 1H).
* `/badpal main wis` → **Seal of Wisdom** (Modo Bateria de Mana).

### Configurar Bênção (Cycle)

Seleciona qual bênção será usada pela tecla **ALT**.

* `/badpal cycle` → Alterna entre as bênçãos disponíveis (Might > Wisdom > Kings > etc).

---

## 4. SMART BUFF SYSTEM (Overrides)

### ⌨️ ALT — Buff Inteligente

Segure **ALT** enquanto aperta seu macro de rotação (`/bret` ou `/bprot`).

**Lógica de Prioridade:**

1. **Mouseover (Amigo):** Buffa quem estiver embaixo do seu mouse (Party Frame ou Boneco 3D).
2. **Target (Amigo):** Buffa seu alvo atual se for amigo.
3. **Self:** Se não tiver mouseover nem alvo amigo, buffa o **Jogador**.

**Greater Blessings (Raide):**

* Segure **CTRL + ALT**: Lança a **Greater Blessing** (15 min) da bênção selecionada.
* *Requer reagente "Symbol of Kings".*

---

## 5. MÓDULOS DE COMBATE

### 🛡️ `/bapprot` — PROTECTION (TANK)

* **Righteous Fury:** Proteção de auto-cast.
* **Holy Shield:** Usado sempre que disponível.
* **Consecration:** Uso inteligente (Mana > 30% + Checagem de Alcance).
* **Threat:** Prioriza Crusader Strike > Judgement > Seal of Righteousness.

### ⚔️ `/bapret` — RETRIBUTION (DPS)

* **Hammer of Wrath:** Prioridade #1 (< 20% HP).
* **Crusader Strike:** Prioridade #2 (Mana/Dano).
* **Exorcism:** Auto-cast em Undead/Demon.
* **Holy Strike:** Gasta excesso de mana (> 60%) sem cortar ataques.

---

## 6. INSTALAÇÃO

**A ordem no arquivo `.toc` é crítica:**

```ini
BadAzsCore.lua
BadAzsPaladin.lua

```

---

## 7. COMANDOS RÁPIDOS

| Comando | Ação |
| --- | --- |
| `/bapret` | Rotação Retribution |
| `/bapprot` | Rotação Protection |
| `/badpal cycle` | Selecionar Próxima Bênção |
| `/badpal opener crus` | Definir Abertura: Crusader |
| `/badpal main soc` | Definir Principal: Command |
| `ALT + Macro` | Smart Buff (Normal) |
| `CTRL + ALT + Macro` | Smart Buff (Greater) |

---

**BadAzsPaladin v3.2 (Turtle Edition)**
*Powered by Core Attack API*
