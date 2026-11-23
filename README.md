# DellKit

A native iOS design system study modeled on the MyDell Mobile app, built **code-first**:
tokens and SwiftUI are the source of truth, and the Figma library is generated from them.

> Unofficial portfolio study. Not affiliated with Dell. Placeholder palette, original icons.

```
tokens/   W3C DTCG token source + build (Swift, CSS, Figma variables) + WCAG check
ios/      DellKit Swift package (iOS 16+): tokens, icons, 20 components, catalog
```

## The loop

1. Change a token in `tokens/tokens/**.json`
2. `cd tokens && npm run build && npm run check`
   - writes `ios/Sources/DellKit/Tokens/DellKitTokens.swift` directly
   - writes `build/figma/variables.json`, which Claude Code pushes into the Figma library
3. Refine details in Figma; bring decisions back as token or view changes. Code stays the source of truth.

## Using the package

Add `ios/` as a local package in Xcode (File → Add Package Dependencies → Add Local), then:

```swift
import DellKit

DKCatalog()   // the three review screens from Figma: Dashboard, Create Account, Virtual Assistant
```

## Figma ↔ SwiftUI map

| Figma component | SwiftUI |
|---|---|
| Button (Primary / Outline / Text) | `DKButton(_:style:icon:action:)`, `DKButtonStyle` |
| Text Field, Search Field | `DKTextField`, `DKSearchField` |
| Code Cell, Code Input | `DKCodeCell`, `DKCodeInput` (one-time-code autofill) |
| Status Badge | `DKStatusBadge`, `DKStatusBadge(order:)` |
| Avatar, Product Media | `DKAvatar`, `DKProductMedia` |
| Section Header, List Row, Timeline Item | `DKSectionHeader`, `DKListRow`, `DKTimelineItem` |
| Device Card, Device List Item, Device Select Tile, Tip Card | `DKDeviceCard`, `DKDeviceListItem`, `DKDeviceSelectTile`, `DKTipCard` |
| Navigation Bar | `.dkNavigationBar(_:subtitle:)` on system `NavigationStack` |
| Tab Bar, Tab Item | `.dkTabBarStyle()` on system `TabView`, `DKTabLabel` |
| Chat Message, Quick Replies, Chat Product Option, Article Card, Feedback Button | `DKChatMessage`, `DKQuickReplies`, `DKChatProductOption`, `DKArticleCard`, `DKFeedbackButton` / `DKFeedbackPrompt` |
| Icon/* | `DKIcon` (SF Symbols, same names in camelCase) |

Each Figma component's description carries its SwiftUI call, so Dev Mode shows the code.
Code Connect (Organization/Enterprise plans) can replace those descriptions later.

## Decisions worth noting

- **System chrome over custom chrome.** Navigation Bar and Tab Bar map to `NavigationStack` and `TabView`,
  so back gestures, safe areas and VoiceOver stay native.
- **States come from the platform.** Pressed comes from `ButtonStyle.isPressed`, Disabled from `.disabled()`,
  Focused from `@FocusState`. Figma variants describe them; the code doesn't fake them.
- **Icons are SF Symbols in code** so they track Dynamic Type; Figma uses matching original glyphs.
- **Inter in Figma, SF Pro on device.** SF Pro can't render in Figma's cloud; text styles use Inter as a stand-in,
  SwiftUI uses `.system()` text styles.
- **Accessibility.** Contrast checked on every build; rows and badges combine for VoiceOver;
  selection exposed with `.isSelected`; 44pt minimum touch targets via `size/touchTarget`.

## Status

Builds in Xcode 15+ for iOS 16+ (verified on the iPhone 16 Pro simulator) and renders in SwiftUI Previews.
Every token and icon reference is checked against the generated tokens, and `npm run check` passes WCAG AA for all pairs.
