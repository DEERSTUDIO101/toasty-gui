# Toasty GUI Hub — Design Spec
**Datum:** 2026-08-28
**Status:** Approved

---

## Übersicht

Ein Roblox Script Hub als CoreGui-Injection. Gebaut als **Component Library** (Lego-Prinzip): erst alle UI-Bausteine isoliert entwickeln, dann zum fertigen Hub zusammensetzen. Mobile-first, drei wechselbare Themes, Key-basiertes Zugangssystem.

---

## Architektur

### Injection
- Wird in `game:GetService("CoreGui")` injiziert
- Kein Reset durch `PlayerGui`-Cleanup
- Single `ScreenGui` mit `ResetOnSpawn = false`

### Datei-Struktur
```
ToastyGUI/
├── Components/         -- Alle UI-Bausteine (Library)
│   ├── Button.lua
│   ├── Card.lua
│   ├── Input.lua
│   ├── Modal.lua
│   ├── Badge.lua
│   ├── Sidebar.lua
│   ├── BottomNav.lua
│   ├── Avatar.lua
│   └── ThemeProvider.lua
├── Screens/            -- Fertige Screens aus Components
│   ├── LoginScreen.lua
│   ├── HomeScreen.lua
│   ├── DetailScreen.lua
│   └── SettingsScreen.lua
├── Theme/
│   └── Themes.lua      -- Alle 3 Theme-Definitionen
└── Main.lua            -- Entry Point, CoreGui-Setup
```

---

## Themes

### Glassmorphism (Default)
| Token | Wert |
|---|---|
| Background | `#0a0a0f` → `#12121a` (Gradient) |
| Panel BG | `rgba(255,255,255,0.06)` / Transparency 0.85 |
| Panel Border | `rgba(255,255,255,0.12)` |
| Blur | UIBlur Size 20 |
| Accent | `#00d4ff` (Cyan) |
| Text Primary | `#ffffff` |
| Text Secondary | `#a0a0b0` |

### Dark Theme
| Token | Wert |
|---|---|
| Panel BG | `#1a1a2e` solid |
| Panel Border | `#2a2a3e` |
| Accent | `#00d4ff` (gleich) |

### Flat Theme
| Token | Wert |
|---|---|
| Panel BG | `#f5f5f5` |
| Text Primary | `#1a1a1a` |
| Accent | `#6366f1` (Indigo) |

Theme-Auswahl wird gespeichert (z.B. via `writefile` oder equivalent).

---

## Screens

### 1. Login Screen
- Key-Input Field (6–8 Zeichen)
- "Login" Button
- "Als Gast fortfahren" Button (subtiler Link-Style)
- Toasty Logo / Branding

### 2. Home Screen (Card Grid)
**Header-Bar:**
- Links: Toasty Logo
- Rechts: Discord-Username (wenn eingeloggt) oder "Gast" Badge

**Navigation:**
- Desktop: Icon-only Sidebar links (🏠 Home, ⚙️ Settings)
- Mobile: Bottom Navigation Bar (gleiche Icons, größer)

**Card Grid:**
- 3–4 Spalten Desktop / 2 Spalten Mobile
- Jede Card: Game Icon (64×64), Game Name, Typ-Badge, Dummy-Preis

### 3. Script Detail (Modal)
Öffnet sich nach Card-Klick:
```
┌──────────────────────────────┐
│ [X]   Game Name              │
│ ─────────────────────────    │
│ [Badge: Ad / Premium]        │
│                              │
│ [🔗 Link kopieren]           │  (nur bei Ad-Typ)
│                              │
│ Key: [____________] [Check]  │
│                              │
│ [▶ Execute]  ← nur nach OK   │
└──────────────────────────────┘
```
Premium ohne Login: "Login erforderlich" statt Link-Button.

### 4. Settings Screen
- Theme-Switcher: 3 Optionen (Glassmorphism / Dark / Flat) mit Preview-Vorschau
- Gespeichertes Theme laden beim Start
- Weitere Settings-Slots für spätere Backend-Features

---

## Script-Typen (UI-States)

| Typ | Eingeloggt | Nicht eingeloggt |
|---|---|---|
| **Ad** | Link kopieren + Key-Input | Link kopieren + Key-Input |
| **Premium** | Key-Input (bereits verifiziert) | "Login erforderlich" + Key-Input (disabled) |

---

## Component Library — Bausteine

Jeder Baustein wird isoliert gebaut und getestet, bevor er in einen Screen eingebaut wird.

| Component | Beschreibung |
|---|---|
| `Button` | Primary, Secondary, Ghost-Varianten; Hover-Animation |
| `Input` | Text-Input mit Label, Placeholder, Focus-State |
| `Card` | Game-Card mit Icon-Slot, Name, Badge, Preis |
| `Badge` | "Ad" / "Premium" Label mit Farb-Codierung |
| `Modal` | Overlay-Modal mit Close-Button, animiertes Open/Close |
| `Sidebar` | Icon-only, aktiver State-Highlight |
| `BottomNav` | Mobile Navigation Bar |
| `Avatar` | Discord-Username-Anzeige mit kleinem Icon |
| `ThemeProvider` | Zentrales Theme-System, gibt Farb-Tokens raus |

---

## Animationen
- **Cards**: Hover → leichtes Scale (1.02) + Glow-Effect
- **Screen-Wechsel**: Fade + Slide (TweenService)
- **Button-Klick**: kurzes Press-Down (Scale 0.97)
- **Modal Open/Close**: Scale + Fade

---

## Mobile Anpassungen
- Bottom Nav statt Sidebar
- Cards: 2-spaltig
- Alle Touch-Targets min. 44px Höhe
- Schriftgrößen +2pt
- Modal: volle Breite, von unten einfahren

---

## Nicht in Scope (UI Only)
- Backend-API Calls
- Echte Key-Validierung
- Ad-Link-Generierung
- Discord OAuth
- Preise (Dummy-Daten)
