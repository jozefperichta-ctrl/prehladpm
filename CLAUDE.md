# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Single-file (`index.html`) project management dashboard for an architecture firm. No build system, no framework — vanilla HTML/CSS/JS deployed via GitHub Pages.

Live URL: `https://jozefperichta-ctrl.github.io/prehladpm/`

To deploy changes: `git add index.html && git commit -m "..." && git push origin main`, then hard-refresh the browser (Ctrl+Shift+R).

## Architecture

Everything lives in `index.html`. Structure:

1. **CSS** — CSS custom properties in `:root`, mobile-first styles
2. **HTML** — 4 bottom nav tabs (Štúdia / Projekcia / Inžiniering / Archív), one `secPrehled` section that serves all 4 tabs
3. **JS** — inline `<script>` at the bottom, no modules

### State

All mutable state is in module-level `let` variables:

| Variable | localStorage key | Purpose |
|---|---|---|
| `projects` | — | Array loaded from Google Sheets |
| `stavMap` | `pmStav` | `{cislo: 'pripravovany'\|'aktivny'\|'pozastaveny'}` |
| `dennikMap` | `pmDennik` | `{cislo: [{datum, text}]}` |
| `geminiMap` | `pmGemini` | `{cislo: 'AI summary text'}` |
| `ulohy` | `pmUlohy` | `{cislo: [{id,profesia,stav,...}]}` |
| `cfg` | `pmCfg3` | `{url: Apps Script URL}` |
| `activeFaza` | — | Current tab: `'Štúdia'\|'Projekcia'\|'Inžiniering'\|'Archív'` |
| `activeStav` | — | Current status filter: `'pripravovany'\|'aktivny'\|'pozastaveny'` |

### Data flow

- `syncData()` fetches from Google Sheets via Apps Script REST endpoint (`cfg.url`)
- `parseRows()` maps raw sheet rows to project objects, including `OLD_FAZA_MAP` migration for legacy phase values
- If no `cfg.url` is set, `loadDemo()` loads hardcoded sample data
- Project fields stored in Google Sheets: `cislo, nazov, faza, projektant, lopta, _, deadline, podfaza, podpodfaza`
- `stavMap`, `dennikMap`, `geminiMap`, `ulohy` are localStorage-only (not in Sheets)

### Key rendering pattern

`renderProjects()` re-renders the full project list. **Never call `renderAll()` / `renderProjects()` from within a project detail interaction** — it collapses all open detail panels.

Instead, use `refreshUlohy(cislo)` which updates only `#pd-ulohy-{cislo}` innerHTML. Apply the same targeted-refresh pattern for any future interaction that happens inside an open `.proj-detail`.

### Phase structure

```
Štúdia       — no sub-phases
Projekcia
  Stavebný zámer → Predprojektová príprava / Príprava pre profesie /
                   Koordinácia s profesiami / Dopracovanie dokumentácie / Expedícia
  Projekt stavby → Príprava pre profesie / Koordinácia s profesiami /
                   Dopracovanie dokumentácie / Expedícia
Inžiniering  — no sub-phases
Archív       — no status filter (pripravovany/aktivny/pozastaveny hidden)
```

`PODFAZY` constant defines the sub-phase options. `goTab()` shows/hides the stav toggle and Gemini button based on tab.

### Gemini integration

`geminiZhrnVsetky()` calls Apps Script action `zhrniProjekt` for each visible project, passing the last 5 diary entries as context. Result stored in `geminiMap` and shown in `projRowHtml()`.

## Planned next step

Replace Google Sheets backend with Caflou API (`https://app.caflou.com/api/v1/{account_id}/`, Bearer Token auth). Caflou will own: projects, tasks. Dashboard continues to own: fáza, podfáza, stav, denník, lopta, Gemini summaries. Storage for the dashboard-only fields (currently localStorage) is not yet decided.
