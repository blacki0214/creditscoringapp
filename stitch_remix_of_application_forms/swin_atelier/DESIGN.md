# Design System Strategy: Swin Credit

## 1. Overview & Creative North Star
### Creative North Star: "The Financial Atelier"
This design system moves beyond the utilitarian nature of fintech to embrace the craftsmanship of a high-end atelier. Swin Credit is not just a digital tool; it is a bespoke financial environment. Our visual strategy rejects the "template" look of modern SaaS in favor of **Intentional Asymmetry** and **Editorial Precision**.

By leveraging high-contrast typography scales (Manrope for high-impact display and Inter for technical clarity) and a philosophy of **Tonal Layering**, we create a space that feels curated, authoritative, and premium. We do not use borders to define space; we use light, depth, and sophisticated color transitions to guide the user's eye.

## 2. Colors & The Surface Philosophy
The palette is anchored by the deep, authoritative `#4A52FF` (Primary Container), balanced against a sophisticated range of cool-toned neutrals that provide a sense of expansive space.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning or containment. Boundaries must be defined solely through background color shifts.
*   **Method:** Use `surface-container-low` for secondary sections sitting on a `background` or `surface` base. This creates a soft, architectural division that feels integrated rather than walled off.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine vellum or frosted glass. 
*   **Base:** `surface` (#f8f9ff)
*   **Tier 1 (Sections):** `surface-container-low` (#f2f3f9)
*   **Tier 2 (Cards/Interaction):** `surface-container-lowest` (#ffffff)
*   **Tier 3 (Modals/Overlays):** `surface-bright` (#f8f9ff) with high elevation.

### The "Glass & Gradient" Rule
To elevate the "Financial Atelier" concept, use **Glassmorphism** for floating elements (Navigation bars, Action drawers). Apply `surface` color tokens at 80% opacity with a `20px` backdrop-blur. 
*   **Signature Textures:** Main CTAs or Hero sections should utilize a subtle linear gradient transitioning from `primary` (#2d32e7) to `primary-container` (#4a52ff). This provides a "glow" that flat colors cannot replicate.

## 3. Typography
Typography is the voice of the Atelier. We use a dual-font strategy to balance character with technical precision.

*   **Display & Headlines (Manrope):** These are our "Editorial" levels. Use `display-lg` to `headline-sm` for high-impact messaging. The tight kerning and geometric structure of Manrope convey a modern, confident brand personality.
*   **Body & Titles (Inter):** These are our "Technical" levels. Inter provides unmatched legibility for complex financial data.
*   **Scale Intent:** 
    *   **Authoritative:** Large `display-lg` headings paired with significant `spacing-20` (5rem) margins create a high-end magazine feel.
    *   **Precision:** Use `label-md` for data-heavy labels to ensure even the smallest details feel intentional and engineered.

## 4. Elevation & Depth
Hierarchy is conveyed through **Tonal Layering** rather than traditional structural lines.

*   **The Layering Principle:** Place a `surface-container-lowest` card (Pure White) on a `surface-container-low` background to create a soft, natural lift. This mimics how light hits different planes of high-quality paper.
*   **Ambient Shadows:** If a "floating" effect is required (e.g., for a premium credit card component), shadows must be extra-diffused. 
    *   **Shadow Specs:** Blur: 32px to 64px | Opacity: 4%-6% | Color: `on-surface` (#191c20).
*   **The "Ghost Border" Fallback:** If accessibility requires a border (e.g., in high-contrast modes), use `outline-variant` at **15% opacity**. Never use 100% opaque borders.
*   **Glassmorphism:** Use for persistent elements like bottom sheets or navigation bars. It allows the rich content of the Atelier to bleed through, making the layout feel fluid.

## 5. Components

### The "Swin" Signature Logo Integration
The mascot robot and "Swin Credit" logo should be treated as a watermark of quality. 
*   **Mascot Usage:** Use the mascot in "Success" states or empty states as a friendly, premium concierge.
*   **Logo Treatment:** Place the logo prominently in the top-left or centered in the top-nav, ensuring it is always surrounded by a minimum of `spacing-8` (2rem) of clear space.

### Primitive Styling
*   **Buttons:** 
    *   *Primary:* `primary-container` background, `on-primary` text. Use `roundedness-full` for a "pill" shape that feels modern and approachable.
    *   *Secondary:* `surface-container-high` background with no border.
*   **Input Fields:** Use `surface-container-low` backgrounds. No borders. On focus, transition the background to `surface-container-lowest` and add a subtle `primary` glow.
*   **Cards & Lists:** **Strictly forbid divider lines.** Use `spacing-4` or `spacing-6` vertical white space to separate list items. For visual grouping, wrap items in a `surface-container-low` container.
*   **Financial Atelier Cards:** High-value cards (e.g., Credit Limits) should use the signature gradient (`primary` to `primary-container`) with the Swin logo subtly embossed in the background at 5% opacity.

## 6. Do's and Don'ts

### Do
*   **Do** embrace white space. Use the `spacing-16` and `spacing-20` tokens frequently to give content room to breathe.
*   **Do** use intentional asymmetry. For example, align text to the left but place supporting imagery or data points slightly off-center to create a bespoke, non-grid feel.
*   **Do** use `roundedness-xl` (1.5rem) for main content containers to maintain a soft, premium feel.

### Don't
*   **Don't** use 1px solid lines to separate content. This is the hallmark of "cheap" UI.
*   **Don't** use standard "drop shadows" (small blur, high opacity). They create visual clutter.
*   **Don't** clutter the screen with icons. Use typography and color shifts to define hierarchy first; icons are secondary accents.
*   **Don't** use pure black for text. Always use `on-surface` (#191c20) to maintain tonal depth.