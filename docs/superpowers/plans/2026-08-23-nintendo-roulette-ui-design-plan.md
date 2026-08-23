# Nintendo-Inspired Roulette UI Design Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Apply the verified Nintendo-inspired visual system to the existing roulette app while preserving all roulette, persistence, localization, ads, purchase, audio, haptic, and confetti behavior.

**Architecture:** Keep the existing single-file Flutter architecture and state flow. Update only visual tokens, `ThemeData`, widget decoration, text hierarchy, and custom shared widgets in `lib/main.dart`; do not change `PlayerProvider`, roulette selection logic, callbacks, persistence keys, localization APIs, or service lifecycles.

**Tech Stack:** Flutter/Dart, Material theme, Provider, `flutter_fortune_wheel`, existing localization and service dependencies.

## Global Constraints

- Read and apply the project-root `DESIGN.md` before every UI edit.
- Use only the confirmed reference values in `DESIGN.md`: `#e60012`, `#484848`, `#727272`, `#c8c8c8`, `#ffffff`, `#f8f8f8`, `#efefef`, `#e0e0e0`, `#468254`, `#4b5cce`, `#27455c`, the documented typography sizes/weights, spacing scale, radius scale, shadows, and motion tokens.
- Keep the existing `_kWheelColors` segment list unchanged because the product-specific roulette palette is unresolved in `DESIGN.md`.
- Do not change roulette state transitions, random selection, participant/preset/history persistence, AdMob/IAP calls, localization keys, audio assets, haptic calls, or confetti calls.
- Do not add a font asset or external dependency; retain the platform fallback while applying the documented type sizes and weights.
- Preserve existing user-visible labels and localization behavior; only style their widgets.

---

### Task 1: Replace the visual token layer and app theme

**Files:**
- Modify: `lib/main.dart:16-149`
- Test: `test/widget_test.dart` (existing suite only; no business-logic test changes)

**Interfaces:**
- Consumes: current color constants and `MaterialApp` theme.
- Produces: the same constant names where practical, with Nintendo-inspired values available to every existing widget.

- [ ] **Step 1: Snapshot the current token and theme diff surface**

Run:

```powershell
rg -n "^const Color|ThemeData|ColorScheme|appBarTheme|cardTheme|elevatedButtonTheme|inputDecorationTheme|textButtonTheme" lib/main.dart
```

Expected: the token block and root `ThemeData` are the only declarations changed in this task.

- [ ] **Step 2: Replace the token values with documented reference roles**

Use this mapping in `lib/main.dart`:

```dart
const Color _kBg = Color(0xFFFFFFFF);
const Color _kSurface = Color(0xFFF8F8F8);
const Color _kCard = Color(0xFFFFFFFF);
const Color _kBorder = Color(0xFFE0E0E0);
const Color _kText = Color(0xFF484848);
const Color _kTextSub = Color(0xFF727272);
const Color _kAction = Color(0xFFE60012);
const Color _kSuccess = Color(0xFF468254);
```

Rename `_kBlue` to `_kAction` and `_kEmerald` to `_kSuccess` at all use sites so the code names match their visual roles. Leave `_kWheelColors` and `_kWheelTextColors` unchanged.

- [ ] **Step 3: Apply the documented light Material theme**

Configure `ThemeData` with a light `ColorScheme`, white scaffold/app-bar surfaces, warm-grey foregrounds, red primary buttons, 48px primary-button minimum height, 8px primary-button radius, 12px card radius, underline-style input borders, and red `TextButton` foregrounds. Keep the current localization delegates, supported locales, provider tree, and `HomeScreen` home unchanged.

- [ ] **Step 4: Run static analysis after the token/theme edit**

Run:

```powershell
flutter analyze
```

Expected: no new analyzer errors from the token rename or theme changes.

### Task 2: Restyle the home screen without changing its state flow

**Files:**
- Modify: `lib/main.dart:586-1199`

**Interfaces:**
- Consumes: existing `provider`, `p`, `_selected.stream`, `_isSpinning`, `_showPresetSheet`, `_showHistorySheet`, and `_startSpinning` callbacks.
- Produces: the same home screen interactions with light surfaces and a single red primary action.

- [ ] **Step 1: Restyle app-bar actions and title**

Keep the existing title, restore-purchase callback, ad-free purchase callback, tooltip, and localized label. Replace the blue/green purchase gradient with a solid reference-red action pill or a documented neutral utility treatment. Keep the verified 20px utility-pill geometry and remove only the unapproved gradient.

- [ ] **Step 2: Restyle participant entry and controls**

Use white input surfaces, `#e0e0e0` hairlines, 0px input radius where the reference input treatment applies, 12px cards for the winner-count control, 16px body labels, and `#e60012` only for the primary action signal. Preserve `onSubmitted`, add-player callbacks, stepper bounds, and `_resetGame()` calls byte-for-byte in behavior.

- [ ] **Step 3: Restyle participant rows and secondary actions**

Use white cards with the documented 12px radius and soft shadow only where a tile needs lift. Keep the existing wheel segment colors in avatars, the same remove callbacks, the same list order, and the same 44px remove hit box. Use warm-grey text and hairlines instead of the current dark surfaces.

- [ ] **Step 4: Restyle the wheel frame without changing the wheel**

Keep `FortuneWheel`, its stream, physics, item construction, `onAnimationEnd`, winner history writes, haptics, audio, confetti, and delays unchanged. Remove the blue glow from the surrounding rim, use the documented white/grey flat treatment and soft reference shadow, and leave the segment colors, pointer color, and labels unchanged because those product-specific values are unresolved.

- [ ] **Step 5: Restyle the primary spin control**

Keep `_GradientSpinButton`’s label, focus node, `onPressed`, and conditional rendering unchanged. Replace its gradient and 50px radius with a solid `#e60012` fill, white text, 8px radius, 48px minimum height, 18px weight-600 label, and no heavy shadow. Keep the existing progress indicator and status text behavior.

- [ ] **Step 6: Run the widget test suite after home-screen changes**

Run:

```powershell
flutter test
```

Expected: all existing tests pass; no new test should be needed because this task changes presentation only.

### Task 3: Restyle sheets, dialogs, and shared widgets

**Files:**
- Modify: `lib/main.dart:552-1950`

**Interfaces:**
- Consumes: existing bottom-sheet builders, dialog callbacks, provider methods, localization strings, and shared widget constructors.
- Produces: consistent Nintendo-inspired surfaces for history, presets, save/delete dialogs, winner dialog, and shared buttons.

- [ ] **Step 1: Restyle history and preset sheets**

Keep sheet sizes, scroll controllers, provider reads/writes, dialog launches, snackbars, list ordering, and callbacks unchanged. Use white sheet surfaces, a 12px top radius, `#e0e0e0` divider, 12px content tiles, warm-grey text, and red direct-action labels. Replace gradient section headings with plain warm-grey or reference-red typography; do not alter localized text.

- [ ] **Step 2: Restyle save/delete/reset dialogs**

Keep every `showDialog` callback, validation branch, provider call, `Navigator.pop`, and snackbar unchanged. Use white dialog surfaces, 12px radius, hairline borders, warm-grey text, red destructive/primary text where already semantically appropriate, and the documented soft/card shadow treatment.

- [ ] **Step 3: Convert shared gradient text into restrained reference typography**

Keep `_GradientText`’s constructor and call sites intact to minimize behavior risk, but replace `ShaderMask` with a plain `Text` using the supplied style color or `_kText`. This removes the unapproved blue/green gradient without changing layout semantics.

- [ ] **Step 4: Restyle `_StepperButton` without changing its disabled logic**

Keep the `onPressed` null behavior and 44px dimensions. Use white/card surfaces, `#e0e0e0` borders, warm-grey enabled icons, and disabled grey `#c8c8c8` icons. Do not add new state logic.

- [ ] **Step 5: Restyle `_WinnerDialog` and preserve result actions**

Keep winner mapping, list bounds, close callback, spin-again callback, localized title/button labels, and navigation behavior unchanged. Use a white 12px dialog, red status/primary treatment, the existing wheel colors for winner index markers, warm-grey text, and only the documented soft/card shadows.

- [ ] **Step 6: Run analysis and tests after all component changes**

Run:

```powershell
flutter analyze
flutter test
```

Expected: both commands exit successfully with no new errors or test failures.

### Task 4: Review the final diff for behavior preservation

**Files:**
- Inspect: `lib/main.dart`
- Inspect: `DESIGN.md`, `.omd/sync.lock.json`, `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/omd-design.mdc`

**Interfaces:**
- Consumes: the completed visual-only diff and existing repository state.
- Produces: a verified handoff with no unintended source or configuration changes.

- [ ] **Step 1: Check the diff for logic and data-flow changes**

Run:

```powershell
git diff --check
git diff --stat
git diff -U0 -- lib/main.dart
```

Review that changed lines are limited to color names/values, theme properties, widget decoration, text style values, and gradient/shadow presentation. Confirm no changes to provider methods, persistence keys, random selection, ad/IAP calls, audio/haptic calls, confetti calls, or localization keys.

- [ ] **Step 2: Check design-token compliance**

Run:

```powershell
rg -n "Color\(0x|Colors\.|borderRadius:|padding:|fontSize:|fontWeight:|BoxShadow|LinearGradient|ShaderMask" lib/main.dart
```

Review every changed literal against `DESIGN.md`. Existing roulette segment colors are the only intentionally retained product palette outside the reference chrome.

- [ ] **Step 3: Verify generated design-system metadata**

Run:

```powershell
Get-Content -Raw -Encoding utf8 .omd/sync.lock.json | ConvertFrom-Json | Out-Null
git status --short
```

Expected: design-system files and the intended `lib/main.dart` edit are visible; unrelated pre-existing localization changes remain untouched.
