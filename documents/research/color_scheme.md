# DotLife Moments: Design System & Color Palettes

## 1. Design Philosophy
**Vibe:** Calm, Peaceful, Minimalist, "No Shame."
**Core Visual:** A monochrome dot matrix where empty space acts as texture, not emptiness.
**Platform:** iOS 17+ (SwiftUI).

---

## 2. Semantic Token Definitions
The app should use semantic naming rather than color naming (e.g., use `appBackground` not `creamyWhite`).

| Token Name | Usage |
| :--- | :--- |
| `appBackground` | The main background of the `Capture` and `Visualize` pages. |
| `surface` | Used for cards, sheets, or the expanded "Detail" view background. |
| `textPrimary` | Main user input, titles, and active content. |
| `textSecondary` | Timestamps, placeholder text, and subtle UI labels. |
| `accent` | The primary action color (Add button, links, active states). |
| `dotBase` | The single hue used for the dot matrix. **See Dot Logic below.** |

---

## 3. The Dot Matrix Logic
The "Dot Grid" is the core UI element. It does not use different colors for empty vs. full. It uses **Opacity** to create a "texture" effect.

* **Empty Dot (Texture):** Render `dotBase` at **8% - 12% Opacity**.
    * *Visual Goal:* Should look like a watermark or paper texture.
* **Filled Dot (Experience):** Render `dotBase` at **85% - 100% Opacity**.
    * *Visual Goal:* Should look like ink or a clear indicator.
* **Multiple Items:** If a bucket has >1 experience, increase intensity or add a subtle ring stroke; do not change hue.

---

## 4. Color Themes (5 Variations)

### Option 1: Morning Mist (Airy & Clean)
*Best for: Clarity, mental space, reducing anxiety.*

| Token | Light Mode Hex | Dark Mode Hex |
| :--- | :--- | :--- |
| `appBackground` | `#F5F7FA` (Ice White) | `#0F172A` (Deep Slate) |
| `surface` | `#FFFFFF` (Pure White) | `#1E293B` (Light Slate) |
| `textPrimary` | `#1E293B` (Midnight Blue) | `#E2E8F0` (Mist White) |
| `textSecondary` | `#94A3B8` (Cool Grey) | `#64748B` (Slate Grey) |
| `accent` | `#3B82F6` (Air Blue) | `#60A5FA` (Glow Blue) |
| `dotBase` | `#3B82F6` | `#60A5FA` |

### Option 2: Paper & Ink (Warm & Tactile)
*Best for: Journaling feel, reading comfort, groundedness.*

| Token | Light Mode Hex | Dark Mode Hex |
| :--- | :--- | :--- |
| `appBackground` | `#FDFBF7` (Cream) | `#1C1C1E` (Warm Charcoal) |
| `surface` | `#FFFFFF` (White) | `#2C2C2E` (Dark Sepia) |
| `textPrimary` | `#2D2A26` (Soft Black) | `#E5E5E0` (Bone White) |
| `textSecondary` | `#8E8B86` (Pencil Grey) | `#8E8E93` (Warm Grey) |
| `accent` | `#4A4A4A` (Graphite) | `#A1A1AA` (Stone) |
| `dotBase` | `#2D2A26` | `#E5E5E0` |

### Option 3: Forest Floor (Biophilic & Restorative)
*Best for: Mindfulness, growth, breathing.*

| Token | Light Mode Hex | Dark Mode Hex |
| :--- | :--- | :--- |
| `appBackground` | `#F2F5F3` (Pale Mist) | `#111C16` (Deep Forest) |
| `surface` | `#FFFFFF` (White) | `#1A2621` (Dark Moss) |
| `textPrimary` | `#0F291E` (Deep Pine) | `#D1FAE5` (Pale Sage) |
| `textSecondary` | `#6B7280` (Stone Grey) | `#6EE7B7` (Muted Mint) |
| `accent` | `#10B981` (Sage Green) | `#34D399` (Fern) |
| `dotBase` | `#059669` | `#34D399` |

### Option 4: Ceramic (Human & Organic)
*Best for: "No Shame" principle, warmth, forgiveness.*

| Token | Light Mode Hex | Dark Mode Hex |
| :--- | :--- | :--- |
| `appBackground` | `#FAFAF9` (Sand) | `#282320` (Espresso) |
| `surface` | `#FFFFFF` (White) | `#3F3733` (Dark Clay) |
| `textPrimary` | `#44403C` (Earth Brown) | `#E7E5E4` (Sandstone) |
| `textSecondary` | `#A8A29E` (Warm Dust) | `#A8A29E` (Warm Dust) |
| `accent` | `#D97706` (Terracotta) | `#F59E0B` (Amber) |
| `dotBase` | `#D97706` | `#F59E0B` |

### Option 5: Twilight (Dreamy & Reflective)
*Best for: Memory, abstraction, sleep hygiene.*

| Token | Light Mode Hex | Dark Mode Hex |
| :--- | :--- | :--- |
| `appBackground` | `#FAF5FF` (Pale Lavender) | `#1E1B4B` (Midnight Violet) |
| `surface` | `#FFFFFF` (White) | `#312E81` (Deep Indigo) |
| `textPrimary` | `#3B0764` (Dark Grape) | `#E9D5FF` (Soft Lilac) |
| `textSecondary` | `#9333EA` (Muted Purple) | `#A78BFA` (Light Violet) |
| `accent` | `#9333EA` (Royal Purple) | `#C084FC` (Bright Lilac) |
| `dotBase` | `#7E22CE` | `#A78BFA` |
