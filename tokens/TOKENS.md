# DellKit Tokens

Token foundation for **DellKit**, a native iOS design system study modeled on the MyDell Mobile app. It's a code-first workflow: tokens live here as the single source of truth, and SwiftUI, the web twin, and Figma are all generated from them.

> Unofficial portfolio study. Not affiliated with Dell. The palette is a placeholder, not Dell brand values.

## Structure

```
tokens/
  primitive/      raw values: color ramps, 4pt spacing, radius, type scale
  semantic/       meaning: bg, text, border, action, status, order-state (LIGHT)
  themes/dark.json  dark overrides, same paths as semantic
  component/      button, statusBadge, listRow, card. Alias semantic only.
scripts/
  build.mjs       generates all outputs
  contrast.mjs    WCAG AA check on fg/bg pairs, both modes
build/            generated. Don't hand-edit.
  ios/DellKitTokens.swift
  web/tokens.css
  figma/variables.json
```

**Three tiers, one rule:** components reference semantic tokens, and semantic tokens reference primitives. Primitives are left out of the Swift output on purpose, so nobody can reach for `blue600` in a view.

## Commands

```bash
npm install
npm run build   # tokens -> Swift, CSS, Figma variables
npm run check   # WCAG AA contrast, light + dark (exits 1 on failure)
```

## Outputs

| Output | Used by | Notes |
|---|---|---|
| `DellKitTokens.swift` | SwiftUI package | `DK.Color.*` resolves light/dark at runtime through a dynamic `UIColor`. `DK.Typography.*` maps to Apple text styles, so Dynamic Type works for free. `DK.Metric.*` holds spacing, radius, and sizes. |
| `tokens.css` | Web twin (Code Layers / "send to Figma") | `--dk-*` custom properties, with dark mode via `prefers-color-scheme` or `data-theme`. |
| `variables.json` | Figma, via the Figma MCP (`use_figma`) | Three collections: **Primitives** (Value), **Semantic** (Light / Dark), and **Components** (Value). Aliases are preserved, scopes are set, and code syntax is filled in for iOS and Web. |

## Workflow

1. Edit tokens here, never in Figma first.
2. `npm run build && npm run check`
3. Ask Claude Code to push `build/figma/variables.json` into the Figma file as variables (it needs the `figma-use` and `figma-generate-library` skills).
4. Refine in Figma. If a value changes there, bring it back into `tokens/*.json` and rebuild. Code stays the source of truth.

## Decisions worth noting

- **Order-state tokens** (`color.order.delivered`, `.delayed`, …) map product language to status meanings, so an order state can be re-themed without touching any component.
- **The contrast check runs in the build loop.** The first run caught 5 failing pairs (tertiary text, borders, success and error badges). They were fixed by tuning the ramps, not by lowering the bar.
- **The 44pt touch target** is a token (`size.touchTarget`), and both button height and list-row min height alias it.
