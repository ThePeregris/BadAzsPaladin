# [B]adAzs Paladin 

**Battle Analysis Driven Assistant Zmart System** <br>
*Vanilla / Classic WoW Edition – Core Integration*
<a href="https://www.paypal.com/donate/?hosted_button_id=VLAFP6ZT8ATGU">
  <img src="https://github.com/ThePeregris/MainAssets/blob/main/Donate_PayPal.png" alt="Tips Appreciated!" align="right" width="120" height="75">
</a>
<br><br><br>
<hr>

Addon de rotação para Paladin, feito para **Turtle WoW (cliente 1.12 / Lua 5.0)**.
Cobre **Retribution** e **Protection** com sistema de selos configurável, smart buff no mouseover e integração com o [BadAzs Core](../BadAzsCore).

## Requisitos

- **BadAzs Core** (obrigatório) — fornece o sistema de poções/bandagens (`Sustain`) e o roteador de painéis (`/badazs`).
- **ItemRack** (opcional) — não usado diretamente pelo Paladin hoje, mas fica disponível se o Core/outros addons precisarem.

## Instalação

Copie a pasta inteira para `Interface/AddOns/`, mantendo o nome:

```
AddOns/
  BadAzsPaladin/
    BadAzsPaladin.toc
    BadAzsPaladin.lua
```

Confirme na tela de personagem (botão **AddOns**) que `BadAzs Paladin` está habilitado — e que **BadAzs Core** também está.

## Macros

| Comando | O que faz |
|---|---|
| `/bapret` | Rotação Retribution |
| `/bapprot` | Rotação Protection |
| Segurar **ALT** + `/bapret` ou `/bapprot` | Lança a Bênção configurada em quem estiver no mouseover (Smart Buff) |
| Segurar **CTRL+ALT** + o mesmo macro | Lança a versão **Maior** (Greater) da Bênção, se disponível |
| `/badazs pally` | Abre o painel de configuração |

Cada macro já lida com abertura de selo, troca pro selo principal e uso de poções/bandagens (herdado do Core) sozinho.

## Sistema de Selos

- **Selo de Abertura (Opener)** — lançado no alvo assim que ele não tem o debuff de Julgamento correspondente ainda, pra garantir que o Judgement bata antes do selo principal assumir.
- **Selo Principal (Main)** — mantido ativo pro dano sustentado depois que o debuff de abertura já está no alvo.

Os dois são escolhidos clicando no botão do painel, que cicla pelas opções:
- Opener: `Seal of the Crusader` → `Seal of Wisdom` → `Seal of Light` → `None`
- Main: `Seal of Command` → `Seal of Righteousness` → `Seal of Wisdom`

## Painel de configuração (`/badazs pally`)

Formato de "livro": página esquerda com os controles, página direita com a explicação de cada um.

- **Selo de Abertura** e **Selo Principal** — botões de ciclo (clique pra trocar).
- **Bênção no ALT (Smart Buff)** — botão de ciclo que define qual Bênção é lançada ao segurar ALT + mouseover. Ciclo corrigido nessa versão (`/bapconfig cycle` antigo nunca funcionava — a função não existia).
- **Botão de idioma** (`EN`/`PT`) no canto superior esquerdo — troca o idioma de toda a interface na hora.

## SavedVariables

- `BadAzsPalDB.Opener` — string, selo de abertura
- `BadAzsPalDB.Main` — string, selo principal
- `BadAzsPalDB.Blessing` — string, bênção atual do ALT
- `BadAzsPalDB.BlessIndex` — índice interno do ciclo de bênção
- `BadAzsPalDB.Locale` — `"EN"` ou `"PT"`

## Arquitetura interna

Desde a v4.0, o Paladin é **self-sufficient**: não depende mais do Core para checagens de combate (`Cast`, `Ready`, `HasBuff`, `TargetHasDebuff`, `GetTargetHP`, `GetMana`, scanner de tooltip, tracking de ataque). O Core só é usado para:

- `BadAzs_Sustain()` — poções de vida/mana, healthstone, bandagem (chamado automaticamente no início de cada rotação).
- `BadAzs_ManualMouseover()` — utilitário genérico de castar em quem está no mouseover sem perder o target atual (usado pelo Smart Buff).
- Roteador `/badazs` — cada addon de classe se registra em `BadAzs_PanelRegistry`, evitando conflito entre addons que usam o mesmo prefixo de comando.

## Changelog

- **v4.2** — Painel em formato de livro (controles + explicações), textura de fundo estilo questlog, correção do slash `/badazs` (antes `/badasz`).
- **v4.1** — Localização EN/PT.
- **v4.0** — Reescrita self-sufficient, painel gráfico de configuração, correção do bug `BadAzs_CycleBlessing` (chamada mas nunca definida na versão anterior).
- **v3.9** — Última versão baseada em comandos de texto (`/bapconfig`).
