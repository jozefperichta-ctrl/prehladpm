# Špecifikácia – prehladPM prestavba

## Navigácia

Spodné menu má 4 položky zodpovedajúce fázam projektu:
- Štúdia
- Projekcia
- Inžiniering
- Archív

Ponuky a Plán sú zatiaľ skryté (môžu sa vrátiť neskôr).

---

## Fázy a podfázy

### Štúdia
Bez podfáz.

### Projekcia
- Stavebný zámer
  - Predprojektová príprava
  - Príprava pre profesie
  - Koordinácia s profesiami
  - Dopracovanie dokumentácie
  - Expedícia
- Projekt stavby
  - Príprava pre profesie
  - Koordinácia s profesiami
  - Dopracovanie dokumentácie
  - Expedícia

### Inžiniering
Bez podfáz.

### Archív
Bez podfáz. Bez prepínača aktívne/pozastavené.

---

## Stav projektu

Každý projekt môže byť:
- **Aktívny** (default)
- **Pozastavený**

Platí len pre Štúdiu, Projekciu a Inžiniering. V Archíve sa stav nepoužíva.

Prepínač aktívne / pozastavené je v hlavičke prehľadu (nie per-projekt).

---

## Zoznam projektov (pohľad)

Každý riadok zobrazuje len:
1. Číslo projektu
2. Názov projektu
3. Fáza › Podfáza › Pod-podfáza
4. Gemini zhrnutie (2 vety, posledné vygenerované)

Jedno tlačidlo **"Zhrň projekty"** v hlavičke – vygeneruje Gemini zhrnutia pre všetky projekty naraz.

---

## Detail projektu (po kliknutí)

Po kliknutí na projekt sa zobrazí detail s:

### Fáza
Editovateľný výber: Fáza → Podfáza → Pod-podfáza (len pre Projekciu sú 2 úrovne pod fázou, ostatné nemajú podfázy).

### Lopta
Dropdown: PM / Šéf / Klient (voliteľné – ak nie je nastavené, pole je prázdne).

### Denník projektu
- Záznamy s dátumom (každý záznam sa pridá a ostane, neprepisuje sa)
- Funguje rovnako ako história úloh
- Každý záznam = dátum + text

### Gemini zhrnutie
- Zobrazí sa posledné vygenerované zhrnutie
- Generuje sa tlačidlom "Zhrň projekty" pre všetky projekty naraz

### Úlohy
- Zoznam úloh projektu
- Pridávanie nových úloh
- Každá úloha má: profesia, popis, stav, zodpovedná osoba (lopta)

---

## Gemini integrácia

- Spúšťa sa manuálne tlačidlom "Zhrň projekty"
- Vstup: denník záznamov projektu (alebo posledné záznamy)
- Výstup: 2-vetové zhrnutie stavu projektu
- Uloží sa k projektu a zobrazí v zozname

---

## Mapovanie starých fáz na nové

| Stará fáza | Nová fáza |
|---|---|
| Štúdia | Štúdia |
| Stavebný zámer | Projekcia › Stavebný zámer |
| Stavebný projekt | Projekcia › Projekt stavby |
| Realizačný projekt | Projekcia › Projekt stavby |
| Stavebný a realizačný projekt | Projekcia › Projekt stavby |
| Projektový servis pre inžiniering | Inžiniering |
| Čakanie – inžiniering zámeru | Inžiniering |
| Čakanie – inžiniering projektu | Inžiniering |
| Autorský dozor | Inžiniering |
| Pozastavené | stav = Pozastavené (fáza zostáva pôvodná) |
| Ukončené | Archív |

---

## Mapovanie Caflou → naše fázy

Pole v Caflou: **stav projektu**

| Caflou hodnota | Naša fáza | Podfáza |
|---|---|---|
| 0_Podklady | Štúdia | — |
| 1_Štúdia | Štúdia | — |
| 2_SZ | Projekcia | Stavebný zámer |
| 3_DSP | Projekcia | Projekt stavby |
| 3_PS | Projekcia | Projekt stavby |
| 4_RP | Projekcia | — |
| 5_Inžiniering | Inžiniering | — |
| 6_Autorský dozor | Inžiniering | — |

---

## Odstránené polia

Tieto polia sa z projektov odstraňujú (nepoužívali sa v praxi):
- Akcia áno/nie
- Od kedy čaká

---

## Čo zostáva bokom (zatiaľ)

- Ponuky (cenové ponuky)
- Plán (kalendár)
- Gmail → Google Chat Space prepojenie
- Automatické odmietacie emaily
