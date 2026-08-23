---
omd: 0.1
brand: 복불복룰렛
bootstrapped_from: nintendo
bootstrapped_at: 2026-08-23T15:37:26+09:00
---

<!--
omd:inspired-only
This file uses the verified Nintendo reference values from the local OMD reference
DESIGN.md, verified 2026-06-17 from Nintendo US and JP surfaces. It is an inspired
variation for 복불복룰렛, not a Nintendo product or affiliation claim.

Confirmed project facts supplied by the user:
- Product name: 복불복룰렛
- Product age: launched about one year ago
- Audience segments: friends, families, coworkers

Not supplied by the user and intentionally unresolved:
- Core thesis
- Official tagline
- Forbidden product categories or positioning
- Wheel-specific color set, pointer treatment, spin duration, and celebration sequence
Do not invent these values. Replace the FILL IN markers after product decisions are made.
-->

# Design System of 복불복룰렛 — Nintendo-inspired

## 1. Visual Theme & Atmosphere

복불복룰렛 uses a Nintendo-inspired variation: a light, near-shadowless interface where one saturated action color does most of the emotional work. The verified reference uses a pure white canvas (`#ffffff`), cool-grey surfaces (`#f8f8f8`, `#efefef`), warm dark-grey text (`#484848` on the US surface, `#3c3c3c` on the JP surface), and Nintendo red (`#e60012`) with restraint.

For this roulette product, the interface chrome stays calm and orderly so the wheel and the winner reveal can carry the energy. The reference value of `#e60012` is the action color for the primary spin/confirm path. The wheel's segment palette is intentionally unresolved; do not infer a rainbow or casino palette from the reference.

The reference typography is friendly and legible rather than theatrical: 16px body text, 28px feature headlines, semibold headings, regular prose, and generous CJK rhythm on the Japanese surface. This supports a product used by the confirmed audience segments—friends, families, and coworkers—without assuming a narrower age, region, or personality profile.

Depth remains restrained. Standard separation comes from surface tint and `#e0e0e0` hairlines; standard cards use a whisper-soft shadow and featured cards use the slightly firmer reference shadow. Geometry is gently rounded: 12px cards, 8px primary buttons, 20px utility pills, and 48px action/status pills.

**Key Characteristics:**
- One reference action color, Nintendo red (`#e60012`), reserved for the primary spin/confirm path and direct action links
- Warm dark-grey ink instead of pure black — `#484848` for the US/Latin reference and `#3c3c3c` for the JP reference
- Geologica Variable on the verified US reference surface; the verified Japanese CJK stack on the JP reference surface
- Light canvas with cool-grey tinted surfaces and a single `#e0e0e0` hairline
- Near-shadowless depth — soft lift for ordinary tiles, firmer lift only for featured content
- Gently rounded geometry: 12px cards, 8px primary buttons, 20px utility pills, 48px action/status pills
- Wheel segment colors, pointer styling, and winner-celebration palette remain unresolved until product direction is confirmed

## 2. Color Palette & Roles

### Primary

- **Reference Action Red** (`#e60012`): Verified Nintendo primary action value. Use for the primary spin/confirm CTA and direct action links. This is a reference token, not a Nintendo brand claim for 복불복룰렛.

### Text / Ink

- **Ink Grey (US reference)** (`#484848`): Primary body, heading, nav, and label color on the verified US reference surface.
- **Ink Grey (JP reference)** (`#3c3c3c`): Primary text color on the verified Japanese reference surface.
- **Muted Grey** (`#727272`): Secondary text, captions, and metadata on the US reference surface.
- **Muted Grey (JP reference)** (`#8c8c8c`): Secondary and tertiary text on the Japanese reference surface.
- **Disabled Grey** (`#c8c8c8`): Disabled controls, placeholders, and lowest-emphasis labels.

### Neutral & Surface

- **Pure White** (`#ffffff`): Page background, card surfaces, and text on red or dark overlays.
- **Surface Grey** (`#f8f8f8`): Cool-grey tint for utility pills and segmented blocks.
- **Surface Alt** (`#efefef`): Firmer grey for inset fields and alternating bands.
- **Surface Grey (JP reference)** (`#f2f2f2`): Tinted surface for Japanese chips and panels.
- **Hairline** (`#e0e0e0`): Thin borders, dividers, and card outlines.

### Secondary Accents (service / section theming)

- **Reference eShop Green** (`#468254`): Optional, subordinate service/status accent from the verified reference.
- **Reference Accent Blue** (`#4b5cce`): Optional, subordinate service/section accent from the verified reference.
- **Reference Accent Navy** (`#27455c`): Optional deep band or immersive section accent from the verified reference.
- **On-Primary White** (`#ffffff`): Text and iconography on red or dark backgrounds.
- **Roulette segment palette:** `[FILL IN: product-specific color decision]`. Do not introduce additional saturated values before this is decided.

## 3. Typography Rules

### Font Family

- **Latin / US reference:** `Geologica Variable`, with fallback `-apple-system, "system-ui", sans-serif`.
- **Japanese reference:** `YakuHanJPs, Roboto, Hiragino Kaku Gothic ProN, "ヒラギノ角ゴ ProN W3", Arial, nc3Jp, sans-serif`.
- **Korean and Simplified Chinese:** `[FILL IN: product-specific font choice]`. Do not assume the Japanese stack is correct for these locales.
- **Mono:** `system-ui` only where a technical value genuinely requires it.

### Hierarchy

| Role | Font | Size | Weight | Line Height | Notes |
|------|------|------|--------|-------------|-------|
| Feature Headline (H2) | Geologica | 28px (1.75rem) | 600 | 1.35 (37.8px) | Wheel/result feature title |
| Panel Heading (H2) | Geologica | 21px (1.31rem) | 600 | 1.40 (29.4px) | Participant, preset, or result panel head |
| Section Label | Geologica | 16px (1.00rem) | 600 | 1.40 (22.4px) | Section label, nav, eyebrow |
| Body | Geologica | 16px (1.00rem) | 400 | 1.40 (22.4px) | Standard reading text, Latin |
| Body (JP) | CJK stack | 16px (1.00rem) | 400 | 2.00 (32px) | Standard Japanese reading text |
| Primary Button | Geologica | 18px (1.13rem) | 600 | 1.00 | Primary spin CTA label |
| Nav Item | Geologica | 14px (0.88rem) | 600 | 1.00 | Top navigation or utility item |
| Nav Item (JP) | CJK stack | 14px (0.88rem) | 700 | 1.00 | Japanese navigation item |
| Caption / Input | Geologica | 14px (0.88rem) | 400 | 1.40 | Input, metadata, small labels |

### Principles

- **Weight 600 carries headings; 400 carries prose.** Keep the reference contrast: semibold headings, regular body copy.
- **Regional font discipline.** Do not swap the verified Western and Japanese reference stacks. Korean and Simplified Chinese remain unresolved until a product font decision is supplied.
- **Generous Japanese line-height.** Use the verified 32px line-height on 16px Japanese body text where that reference stack is used.
- **No display heroics.** Keep feature headlines at or below the verified 28px reference size; let the wheel and result state carry the drama.

## 4. Component Stylings

### Buttons

**Primary CTA**
- Background: `#e60012`
- Text: `#ffffff`
- Radius: 8px
- Padding: `0px 24px`
- Height: 48px
- Font: 18px Geologica weight 600
- Use: Primary spin or confirm action. Product-specific label: `[FILL IN: approved CTA copy]`.

**Play Pill**
- Background: `#e60012`
- Text: `#ffffff`
- Radius: 48px
- Padding: `0px 16px`
- Height: 32px
- Font: 16px Geologica weight 600
- Use: Compact replay or play affordance where a pill is appropriate.

**Utility Pill**
- Background: `#f8f8f8`
- Text: `#484848`
- Radius: 20px
- Padding: `8px 12px`
- Height: 32px
- Font: 14px Geologica weight 600
- Use: Secondary utility actions such as list management or history access.

**Red Inline Link**
- Text: `#e60012`
- Font: 16px Geologica weight 600
- Use: Direct navigational or supporting action link on a transparent background.

**Carousel Arrow**
- Background: `rgba(0,0,0,0.3)`
- Text: `#dadada`
- Radius: 8px
- Padding: 16px
- Use: Rotating content or media navigation only. Do not use this as an unapproved roulette pointer style.

### Inputs & Forms

**Participant Input**
- Background: `#ffffff`
- Text: `#484848`
- Radius: 0px
- Font: 14px Geologica weight 400
- Use: Participant entry field, adapted from the verified reference input treatment. The final field label and helper copy remain product copy decisions.

### Cards & Containers

**Media Tile**
- Background: `#ffffff`
- Radius: 12px
- Shadow: `rgba(0,0,0,0.07) 0px 2px 8px`
- Use: Participant, preset, history, or supporting content tile where a card is needed.

**Featured Card**
- Background: `#ffffff`
- Radius: 12px
- Shadow: `rgba(72,72,72,0.15) 0px 4px 16px`
- Use: Featured winner or highlighted result tile. Keep the wheel itself outside this card treatment unless explicitly decided.

### Badges

**Red Status Pill**
- Background: `#e60012`
- Text: `#ffffff`
- Radius: 48px
- Font: 14px Geologica weight 600
- Use: Compact result/status emphasis. Approved status vocabulary is unresolved.

### Navigation

- Background: `#ffffff`
- Text: `#484848`
- Font: 14px Geologica weight 600
- Height: 48px nav row / 72px Japanese header reference
- Active: `#e60012` text or indicator
- Use: Top-level app navigation and utility access. Do not add product destinations that have not been confirmed.

**Verified reference source:** Nintendo US and JP surfaces, verified 2026-06-17. The component values above are reference values; they are not claims about Nintendo's endorsement of 복불복룰렛.

## 5. Layout Principles

### Spacing System

- Base unit: 8px
- Scale: 4px, 8px, 12px, 16px, 24px, 32px, 48px
- Notable: primary CTAs use 24px horizontal padding with zero vertical padding at 48px height; utility pills use 8px/12px padding.

### Grid & Container

- Keep the roulette stage as the visual focal area inside an orderly single-column mobile surface.
- Place participant entry and supporting controls in calm, clearly separated sections around the stage.
- Use white and cool-grey bands separated by `#e0e0e0` hairlines rather than heavy elevation.
- Use 12px media-tile geometry for supporting lists and result content.
- Wheel size, pointer shape, and stage decoration are unresolved product decisions.

### Whitespace Philosophy

- **Calm, breathable rhythm:** keep controls easy to scan before and after a spin.
- **Flat segmentation:** separate entry, wheel, and result areas with tint and hairline before adding shadow.
- **The wheel carries the energy:** keep chrome quiet so the spin and winner state remain legible.

### Border Radius Scale

- Extra-small (2px): fine inset elements
- Small (4px): small containers and inline chips
- Medium (8px): primary buttons and compact control chips
- Large (12px): participant, result, and supporting cards
- Pill (20px): utility pills
- Full (48px / 9999px): play and status pills; circular icon chips remain 50%

## 6. Depth & Elevation

| Level | Treatment | Use |
|-------|-----------|-----|
| Flat (Level 0) | No shadow | Page background, inline text, most surfaces |
| Tint (Level 1) | `#f8f8f8` / `#f2f2f2` background shift | Section separation without elevation |
| Hairline (Level 2) | `1px solid #e0e0e0` border | Card outlines and dividers |
| Soft (Level 3) | `rgba(0,0,0,0.07) 0px 2px 8px` | Standard content tiles |
| Card (Level 4) | `rgba(72,72,72,0.15) 0px 4px 16px` | Featured winner or promoted content |

**Shadow Philosophy:** Keep the interface near-shadowless. Use tint and hairlines for most separation. Use the soft reference shadow for ordinary tiles and the card shadow only for a featured result. The spin itself should not rely on a heavy glow until a product-specific motion and celebration decision is made.

## 7. Do's and Don'ts

### Do

- Reserve `#e60012` for the primary spin/confirm action and direct action links.
- Use warm dark grey for text instead of pure black.
- Keep the verified reference typography and locale discipline.
- Separate areas with `#f8f8f8`/`#f2f2f2` tint and `#e0e0e0` hairlines.
- Keep elevation whisper-soft.
- Use 12px cards, 8px primary buttons, 20px utility pills, and 48px action/status pills.
- Let the roulette outcome carry the visual energy while controls remain calm.
- Keep copy clear and welcoming to friends, families, and coworkers.

### Don't

- Spread red across every element; it dilutes the action signal.
- Use pure black for body text.
- Swap the verified regional font stacks without a product decision.
- Reach for heavy drop shadows or hard elevation.
- Introduce a competing saturated chrome color before the wheel palette is approved.
- Use oversized display headlines.
- Use sharp square corners on cards or pills.
- Copy Nintendo logos, assets, names, or product copy.
- Invent a roulette color, pointer, spin duration, tagline, or positioning claim.

## 8. Responsive Behavior

### Breakpoints

| Name | Width | Key Changes |
|---|---:|---|
| Mobile | <640px | Single-column roulette stage; supporting rows become swipe or stacked content |
| Tablet | 640-1024px | Two-up supporting content where it improves scanning; moderate padding |
| Desktop | 1024-1440px | Centered stage with multi-column supporting content and generous margins |

### Touch Targets

- Primary CTA height: 48px reference value.
- Header utility pills: 32px reference value with 8px/12px padding.
- Navigation items stay within the 48px US / 72px JP reference header.
- Carousel or rotating-content arrows use 16px reference padding.
- Any product-specific touch-target adjustment must be validated for the target platform before implementation.

### Collapsing Strategy

- Keep the roulette stage prominent at every breakpoint; reduce internal padding on mobile.
- Collapse supporting media-tile rows into a single-column swipe or stacked list.
- Collapse top-level navigation into a compact menu on mobile.
- Preserve white/tinted section bands across breakpoints.

### Image Behavior

- Any approved key art or result imagery uses the 12px reference radius across breakpoints.
- Card shadows stay whisper-soft at all sizes.
- Do not assume product artwork, avatars, or illustrations until assets are approved.

## 9. Agent Prompt Guide

### Quick Color Reference

- Primary spin CTA / direct action: `#e60012`
- Heading / body text (US reference): `#484848`
- Heading / body text (JP reference): `#3c3c3c`
- Secondary text: `#727272`
- Disabled: `#c8c8c8`
- Background: `#ffffff`
- Tinted surface: `#f8f8f8` / `#f2f2f2` (JP reference)
- Hairline: `#e0e0e0`
- Optional subordinate accents: `#468254`, `#4b5cce`, `#27455c`
- Wheel palette: `[FILL IN: product-specific decision]`

### Example Component Prompts

- "Create a roulette stage on a white canvas with calm grey chrome. Use one primary CTA: `#e60012` background, white text, 8px radius, 48px height, 18px weight 600. Leave wheel segment colors and pointer styling unresolved."
- "Design a result tile with white background, 12px radius, and soft shadow `rgba(0,0,0,0.07) 0px 2px 8px`. Use warm grey text and a restrained red status pill. Do not invent winner copy."
- "Build a utility control using `#f8f8f8` background, `#484848` text, 20px radius, 32px height, 14px weight 600. Keep the label product-neutral until approved."
- "Use the Japanese reference stack only for Japanese text. Keep Korean and Simplified Chinese font choices unresolved until product approval."

### Iteration Guide

1. Keep the reference action red (`#e60012`) singular and intentional.
2. Use warm grey text instead of pure black.
3. Keep elevation whisper-soft and use tint plus hairlines for separation.
4. Use 12px cards, 8px primary buttons, 20px utility pills, and 48px action/status pills.
5. Keep headings at weight 600 and body at 400; feature headlines top out at 28px.
6. Let the wheel and result state carry energy without turning the entire chrome into a saturated palette.
7. Ask before adding any product-specific color, voice, asset, or motion token that is not listed here.

## 10. Voice & Tone

The reference voice is **warm, inviting, family-friendly, and benefit-first** — playful where it persuades, plain and orderly where it informs. For 복불복룰렛, use that reference register for the confirmed audience segments without inventing a thesis, tagline, or market position.

| Context | Tone |
|---|---|
| Roulette stage | Inviting and experiential; product copy pending |
| Primary CTA | Gentle imperative; approved label pending |
| Participant entry | Plain, helpful, and non-judgmental |
| Winner result | Warm celebration without pressure or exclusion |
| Support / error | Calm, reassuring, and specific about the next step |

**Product voice samples:** none supplied. Do not copy Nintendo's live-site wording into product UI.

**Forbidden register:** fear-based or urgency-manipulation marketing, dense unexplained jargon, edgy or exclusionary humor, condescension toward any confirmed audience segment, and stacked exclamation-mark hype. Product-specific forbidden categories remain `[FILL IN: user decision]`.

## 11. Brand Narrative

<!-- omd:limitation Reference §11 requires project-specific thesis and positioning facts. Replace the FILL IN markers before shipping; do not fabricate. -->

**복불복룰렛** is a roulette app that, according to the user's supplied information, has been launched for about one year. The confirmed audience segments are friends, families, and coworkers.

Core thesis: `[FILL IN: one-sentence product thesis]`

Official tagline: `[FILL IN: approved tagline, or “none”]`

Positioning / categories to avoid: `[FILL IN: approved exclusions, or “none specified”]`

The visual direction is inspired by Nintendo's verified design reference: calm, legible chrome around a playful central experience. This sentence describes the selected design direction, not a historical claim about the product.

## 12. Principles

<!-- omd:limitation Reference §12 can use the supplied audience segments, but the product thesis and positioning are unresolved. -->

1. **One clear action signal.** Use reference red (`#e60012`) for the primary spin/confirm path; do not dilute it across the whole interface.
2. **Calm chrome, playful outcome.** Keep controls composed so the roulette result can carry the emotional energy.
3. **Legibility before decoration.** Participant names, actions, and the selected result must remain easy to read before adding visual effects.
4. **Welcome the supplied audience segments.** The system must feel clear and comfortable for friends, families, and coworkers without assuming an age, region, or skill level not provided.
5. **Product-specific thesis.** `[FILL IN: principle derived from the approved thesis]`

## 13. Personas

<!-- omd:limitation Reference §13 requires segment-specific needs, ages, locations, and contexts. Only segment names were supplied; do not invent personal profiles. -->

**Friends:** confirmed target segment. Needs, context, and decision criteria: `[FILL IN]`.

**Families:** confirmed target segment. Needs, context, and decision criteria: `[FILL IN]`.

**Coworkers:** confirmed target segment. Needs, context, and decision criteria: `[FILL IN]`.

No named, aged, or location-specific personas are asserted in this file.

## 14. States

| State | Treatment |
|---|---|
| **Empty (participants)** | White canvas or `#f8f8f8` tint. One Ink Grey (`#484848`) instruction and one red CTA to add participants. Exact copy pending. |
| **Empty (supporting list)** | Muted Grey (`#727272`) explanation with a clear next step. Do not add a product-specific empty-state illustration without approval. |
| **Loading (spin)** | Keep the stage visible; use a restrained red activity affordance without blocking context. Spin duration is unresolved. |
| **Loading (in-place refresh)** | Keep previous content visible and signal activity with a subtle reference-red affordance. |
| **Error (selection / network)** | Friendly Ink Grey explanation and retry action. No raw error code; state what to do next. |
| **Error (participant input)** | Field-level message describing the valid input. Do not use only a generic “Required” message. |
| **Success (winner selected)** | Clear winner name and next-step actions in a featured white tile or dialog. Celebration intensity and copy are unresolved. |
| **Skeleton** | `#f8f8f8` blocks at final dimensions, 12px radius, flat soft pulse, no shimmer-heavy elevation. |
| **Disabled** | Disabled Grey (`#c8c8c8`) text on a reduced-emphasis surface; reference-red actions fade rather than changing to an unapproved foreign color. |

## 15. Motion & Easing

**Durations:**

| Token | Value | Use |
|---|---:|---|
| `motion-fast` | 120ms | Hover, button press, focus |
| `motion-standard` | 220ms | Card/section reveal, sheet, dropdown, supporting transition |
| `motion-slow` | 360ms | Page-level transition, result reveal, hero/banner reveal |

**Easings:**

| Token | Curve | Use |
|---|---|---|
| `ease-enter` | `cubic-bezier(0.2, 0.6, 0.25, 1)` | Arriving cards, sheets, and result content |
| `ease-exit` | `cubic-bezier(0.4, 0.0, 1, 1)` | Dismissals |
| `ease-standard` | `cubic-bezier(0.25, 0.1, 0.25, 1)` | Two-way transitions |

**Motion rules:** Motion is friendly but composed. Supporting cards and sheets use the reference durations and curves. A tasteful bounce may be used for a playful result moment, but the exact wheel spin duration, spin easing, pointer behavior, haptic/audio timing, and celebration sequence are intentionally unresolved and must be decided before implementation. Under `prefers-reduced-motion: reduce`, reveals and celebratory motion collapse to instant while the result remains fully understandable.

<!--
Reference attribution:
- Base reference: Nintendo, id nintendo, local OMD reference DESIGN.md.
- Verified: 2026-06-17.
- Tier 1 sources: https://www.nintendo.com/us/ and https://www.nintendo.com/jp/.
- Confirmed reference values retained exactly: #e60012, #484848, #3c3c3c, #727272,
  #8c8c8c, #c8c8c8, #ffffff, #f8f8f8, #efefef, #f2f2f2, #e0e0e0, #468254,
  #4b5cce, #27455c, typography sizes/weights, spacing scale, radius scale,
  shadow values, breakpoints, and motion tokens.
- Product-specific information is limited to the user-provided name, approximate
  one-year age, and three audience segments. Missing thesis/tagline/positioning,
  locale font decisions, wheel palette, pointer, and spin/celebration behavior are
  marked FILL IN rather than fabricated.
-->
