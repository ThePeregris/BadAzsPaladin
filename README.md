# [B]adAzs Paladin – MODULAR TACTICAL SUITE (v1.3 Seal & Blessing Selector)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Core Integration*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>

## 1. TECHNICAL MANIFESTO | BadAzsPaladin

**Version:** v1.3 (Seal & Blessing Selector)  
**Target:** Turtle WoW (Client 1.12.x – LUA 5.0)  
**Architecture:** Modular Holy Engine + Core Attack API  
**Author:** **ThePeregris**

**BadAzsPaladin** is a **Decision Support System (DSS)** focused on optimizing the **Seal and Judgement** cycle (Seal Twisting/Cycling).  
Unlike common "spam" scripts, this engine understands the **Turtle WoW** class changes, prioritizing abilities like *Crusader Strike* and *Holy Strike* to maximize DPS and Threat generation while keeping the player in control.

✔️ **Auto-Seal Persistence**  
✔️ **Dynamic Seal & Blessing Selector (New in v1.3)**  
✔️ Optimized for Turtle WoW Meta  

---

## 2. CORE FEATURES (What the script actually does)

### ⚔️ Core Attack API (Shared)

Utilizes the global `BadAzs_StartAttack()` infrastructure from the Core, ensuring:

* Safe Auto-Attack start (White hit)  
* Prevention of "Attack Drop" when switching targets  
* Native integration with the Warrior module  

### 🔄 Seal & Judge Engine

The heart of the Paladin is the Judgement cycle. The script manages this automatically:

1. **Verification:** Checks if a Seal is active.  
2. **Judgement:** If a Seal is active and *Judgement* is ready → Executes Judgement.  
3. **Immediate Re-Seal:** In the next cycle (milliseconds later), the script detects the absence of the Seal and reapplies it immediately.  
4. **Mana Fallback:** If mana is critical (< 20%), it automatically swaps to *Seal of Wisdom* to recover resources.  

### 🐢 Turtle WoW Meta Protocol

The script was designed specifically for the server's class changes:

* **Crusader Strike Priority:** Used on absolute *cooldown* (generates mana and damage).  
* **Holy Strike Dump:** Used as a *mana dump* when resources are high (> 60%), replacing the basic attack without resetting the swing timer.  
* **Execute (Hammer of Wrath):** Absolute priority when the target reaches 20% HP.  

---

## 3. SEAL SELECTION SYSTEM (v1.2)

You can now change seal priority in real-time without editing the code, adapting to your weapon (2H vs 1H).

**Commands:**

* `/badpal seal soc` → Sets **Seal of Command** (Priority for Slow Weapons / 2H).
* `/badpal seal sor` → Sets **Seal of Righteousness** (Priority for Fast Weapons / Spell Power).
* `/badpal seal crusader` → Sets **Seal of the Crusader**.

*Configuration is automatically saved between sessions.*

---

## 4. TACTICAL OVERRIDES (Key Modifiers)

### ⌨️ ALT — Smart Buffing Protocol

Forget action bars cluttered with blessings.

* **In Combat or Out:** Holding **ALT** and triggering the macro executes `BadAzsBuffs()`.
* **Action:** Applies the configured *Blessing* (Default: Might for Solo) on yourself.
* **Utility:** Quick rebuff without losing target or stopping the rotation.

---

## 5. COMBAT MODULES

### 🛡️ `/bprot` — PROTECTION (TANK)

**Function:** Active Mitigation + Threat Generation

* **Righteous Fury:** Constant verification (Auto-cast if missing).
* **Holy Shield:** Spammed on cooldown for mitigation and reflected damage.
* **Consecration:** Smart usage (only if mana > 30% and enemy is in range).
* **Threat Cycle:**
1. Crusader Strike (Burst Threat)
2. Judgement of Righteousness
3. Seal of Righteousness (Fixed Sustainability)



### ⚔️ `/bret` — RETRIBUTION (DPS)

**Function:** Burst Damage + Mana Efficiency

* **Auto-Aura:** Applies *Sanctity Aura* if not mounted.
* **Execute Phase:** Fires *Hammer of Wrath* (< 20% HP).
* **Anti-Undead/Demon:** Automatically uses *Exorcism* if the target type matches.
* **Damage Rotation:**
1. Crusader Strike (Mana/Damage Generator)
2. Judgement
3. **Selected Seal** (Command or Righteousness via `/badpal`)
4. Holy Strike (only with excess mana)



---

## 6. INSTALLATION & DEPENDENCIES

### Loading Order (.toc)

It is **mandatory** to load the Core before the Paladin module:

```ini
Core.lua
BadAzsPaladin.lua

```

### Optional

* **UnitXP_SP3**: For ultra-precise cooldown detection (natively supported by the Core).

---

## 7. QUICK COMMANDS

| Command | Action |
| --- | --- |
| `/bret` | Retribution Rotation |
| `/bprot` | Protection/Tank Rotation |
| `/badpal seal soc` | 2H Weapon Mode (Command) |
| `/badpal seal sor` | 1H Weapon Mode (Righteousness) |
| `ALT + Macro` | Auto Self-Buff (Might) |
| `/badpal bless might` | ALT key for Blessing of Might |
| `/badpal bless kings` | ALT key for Blessing of Kings |
| `/badpal bless wisdom` | ALT key for Blessing of Wisdom |
| `/badpal bless sanc` | ALT key for Blessing of Sanctuary (Prot) |
| ---

## BADAZS PHILOSOPHY

> **"The Light protects, but the Hammer resolves."**

**BadAzsPaladin** removes the tedious micro-management of reapplying seals every 8 seconds, allowing you to focus on positioning, healing allies, and controlling the battlefield.

---

**BadAzsPaladin v1.3 (Turtle Edition)**
*Powered by Core Attack API*

--------------------------
# PT-BR
---------------------------
# [B]adAzs Paladin – MODULAR TACTICAL SUITE (v1.3 Selos e Bênçãos selecionáveis)

**Battle Analysis Driven Assistant Zmart System**
*Turtle WoW Edition – Core Integration*

## 1. TECHNICAL MANIFESTO | BadAzsPaladin

**Version:** v1.3 Seal & Blessing Selectable
**Target:** Turtle WoW (Client 1.12.x – LUA 5.0)
**Architecture:** Modular Holy Engine + Core Attack API
**Author:** **ThePeregris**

O **BadAzsPaladin** é um **Decision Support System (DSS)** focado na otimização do ciclo de **Julgamento e Selo** (Seal Twisting/Cycling).
Diferente de scripts comuns de "spam", este motor entende as mudanças do **Turtle WoW**, priorizando habilidades como *Crusader Strike* e *Holy Strike* para maximizar o DPS e a geração de Threat, mantendo o jogador no controle.

✔️ **Auto-Seal Persistence**
✔️ **Seal & Blessing: Selector Dinâmico (Novo na v1.3)**
✔️ Otimizado para o Meta do Turtle WoW

---

## 2. CORE FEATURES (O que o script realmente faz)

### ⚔️ Core Attack API (Shared)

Utiliza a infraestrutura global `BadAzs_StartAttack()` do Core, garantindo:

* Início seguro de Auto-Attack (White hit)
* Prevenção de "Attack Drop" ao trocar de alvo
* Integração nativa com o módulo Warrior

### 🔄 Seal & Judge Engine

O coração do paladino é o ciclo de Julgamento. O script gerencia isso automaticamente:

1. **Verificação:** Checa se um Selo está ativo.
2. **Julgamento:** Se o Selo está ativo e *Judgement* está pronto → Executa o Julgamento.
3. **Re-Selo Imediato:** No próximo ciclo (milissegundos depois), o script detecta a ausência do Selo e o reaplica imediatamente.
4. **Mana Fallback:** Se a mana estiver crítica (< 20%), troca automaticamente para *Seal of Wisdom* para recuperar recursos.

### 🐢 Turtle WoW Meta Protocol

O script foi desenhado especificamente para as mudanças de classe do servidor:

* **Crusader Strike Priority:** Usado em *cooldown* absoluto (gera mana e dano).
* **Holy Strike Dump:** Utilizado como *mana dump* quando os recursos sobram (> 60%), substituindo o ataque básico sem resetar o swing timer.
* **Execute (Hammer of Wrath):** Prioridade total quando o alvo atinge 20% de HP.

---

## 3. SISTEMA DE SELEÇÃO DE SELOS (v1.2)

Agora você pode alterar a prioridade de selo em tempo real sem editar o código, adaptando-se à sua arma (2H vs 1H).

**Comandos:**

* `/badpal seal soc` → Define **Seal of Command** (Prioridade para Armas Lentas / 2H).
* `/badpal seal sor` → Define **Seal of Righteousness** (Prioridade para Armas Rápidas / Spell Power).
* `/badpal seal crusader` → Define **Seal of the Crusader**.

*A configuração é salva automaticamente entre sessões.*

---

## 4. MODIFICADORES DE TECLA (Tactical Overrides)

### ⌨️ ALT — Smart Buffing Protocol

Esqueça barras de ação lotadas de bênçãos.

* **Em Combate ou Fora:** Segurar **ALT** e acionar o macro executa o `BadAzsBuffs()`.
* **Ação:** Aplica a *Blessing* configurada (Padrão: Might para Solo) em você mesmo.
* **Utilidade:** Rebuff rápido sem perder o target ou parar a rotação.

---

## 5. MÓDULOS DE COMBATE

### 🛡️ `/bprot` — PROTECTION (TANK)

**Função:** Mitigação Ativa + Threat Generation

* **Righteous Fury:** Verificação constante (Auto-cast se faltar).
* **Holy Shield:** Spam em cooldown para mitigação e dano refletido.
* **Consecration:** Uso inteligente (apenas se mana > 30% e inimigo próximo).
* **Threat Cycle:**
1. Crusader Strike (Burst Threat)
2. Judgement of Righteousness
3. Seal of Righteousness (Sustentação Fixa)


### ⚔️ `/bret` — RETRIBUTION (DPS)

**Função:** Burst Damage + Mana Efficiency

* **Auto-Aura:** Aplica *Sanctity Aura* se não estiver montado.
* **Execute Phase:** Dispara *Hammer of Wrath* (< 20% HP).
* **Anti-Undead/Demon:** Usa *Exorcism* automaticamente se o tipo do alvo for compatível.
* **Rotação de Dano:**
1. Crusader Strike (Gerador de Mana/Dano)
2. Judgement
3. **Seal Selecionado** (Command ou Righteousness via `/badpal`)
4. Holy Strike (apenas com excesso de mana)

---

## 6. INSTALAÇÃO & DEPENDÊNCIAS

### Ordem de Carregamento (.toc)

É **obrigatório** carregar o Core antes do módulo Paladin:

```ini
BadAzsCore.lua
BadAzsPaladin.lua

```

### Opcionais

* **UnitXP_SP3**: Para detecção ultra-precisa de cooldowns (suportado nativamente pelo Core).

---

## 7. COMANDOS RÁPIDOS

| Comando | Ação |
| --- | --- |
| `/bret` | Retribution Rotation |
| `/bprot` | Protection/Tank Rotation |
| `/badpal seal soc` | Modo Arma 2H (Command) |
| `/badpal seal sor` | Modo Arma 1H (Righteousness) |
| `ALT + Macro` | Auto Self-Buff |
| `/badpal bless might` | ALT para Blessing of Might |
| `/badpal bless kings` | ALT para Blessing of Kings |
| `/badpal bless wisdom` | ALT para Blessing of Wisdom |
| `/badpal bless sanc` | ALT para Blessing of Sanctuary (Proteção) |
| ---

## FILOSOFIA BADAZS

> **"A Luz protege, mas o Martelo resolve."**

O **BadAzsPaladin** remove a micro-gestão chata de reaplicar selos a cada 8 segundos, permitindo que você foque no posicionamento, na cura de aliados e no controle do campo de batalha.

---

**BadAzsPaladin v1.3 (Turtle Edition)**
*Powered by Core Attack API*
