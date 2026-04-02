# Design System Document

## 1. Overview & Creative North Star: "The Financial Atelier"

This design system moves away from the sterile, rigid nature of traditional banking apps to embrace **The Financial Atelier**. This Creative North Star envisions the interface not as a spreadsheet, but as a curated editorial space where financial decisions feel intentional, calm, and high-end.

We break the "template" look through **intentional tonal depth**. Instead of defining sections with harsh lines, we use a sophisticated layering of whites, soft greys, and deep blues. Asymmetry is used sparingly in header layouts and credit gauges to provide a bespoke feel, while the generous use of the `xl` (1.5rem) roundedness scale ensures every interaction feels approachable and "soft-touch."

---

## 2. Colors

The palette is rooted in a core of deep architectural blues and functional greens, supported by a vast range of surface tones to create an "atmospheric" hierarchy.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning or containment. Boundaries must be defined solely through:
*   **Background Shifts:** Placing a `surface-container-low` section against a `surface` background.
*   **Tonal Transitions:** Using the hierarchy of surfaces (Lowest to Highest) to denote nested logic.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, physical layers.
*   **Base:** `surface` (#f5f6f9)
*   **Secondary Content:** `surface-container` (#e6e8ec)
*   **Elevated Cards:** `surface-container-lowest` (#ffffff) sitting on `surface-container-low`.

### The "Glass & Gradient" Rule
To elevate the experience, use **Glassmorphism** for floating headers or navigation bars. Use semi-transparent `surface` tokens with a `backdrop-blur` of 20px to allow the deep `primary` backgrounds to bleed through softly. 

### Signature Textures
Main CTAs and high-impact indicators (like the credit score gauge) should utilize a subtle linear gradient from `primary` (#383eef) to `primary-container` (#9197ff) at a 135-degree angle. This provides a "soul" and professional polish that flat fills cannot achieve.

---

## 3. Typography

The typography strategy employs a high-contrast scale to create an editorial feel, pairing the geometric authority of **Manrope** with the clinical precision of **Inter**.

*   **Display & Headline (Manrope):** These are the "Hero" elements. Use `display-lg` and `headline-md` for loan amounts and credit scores. The wider character set of Manrope communicates stability and modern luxury.
*   **Title & Body (Inter):** Used for structured forms and data points. Inter's high x-height ensures maximum legibility in complex "Step-by-Step" application flows.
*   **Labels (Inter):** All micro-copy and helper text must use `label-md` or `label-sm` with increased letter-spacing (+0.02em) to maintain an premium, airy feel.

---

## 4. Elevation & Depth

We convey hierarchy through **Tonal Layering** rather than structural geometry.

*   **The Layering Principle:** Depth is achieved by "stacking." A loan status indicator (`Active` using `secondary-container`) should sit on a `surface-container-lowest` card, which in turn sits on a `surface` background. This creates a natural "lift."
*   **Ambient Shadows:** If a card must float, use an extra-diffused shadow: `box-shadow: 0 20px 40px rgba(12, 15, 17, 0.06);`. The shadow color is derived from `on-surface` at a very low opacity to mimic natural light.
*   **The "Ghost Border" Fallback:** If accessibility requires a border, use the `outline-variant` token at 15% opacity. Never use 100% opaque borders.
*   **Glassmorphism:** Use for floating notifications or "sticky" bottom bars. This ensures the app feels integrated and deep, rather than flat and "pasted."

---

## 5. Components

### Buttons
*   **Primary:** Uses the "Signature Texture" gradient. `xl` (1.5rem) corner radius. Internal padding: `spacing-4` (vertical) and `spacing-12` (horizontal).
*   **Secondary:** `surface-container-highest` background with `on-surface` text. No border.

### Credit Score Gauge
*   A custom semi-circular track using `primary` for the active range and `surface-variant` for the remaining track. The needle should be a soft-tapered shape with a subtle `primary_dim` drop shadow.

### Status Indicators (Active/Pending)
*   **Active:** Use `secondary-container` (#72fcb1) with `on-secondary-container` (#005e38) text.
*   **Pending:** Use `tertiary-container` (#fe9d00) with `on-tertiary-container` (#4c2b00) text.
*   Style as a "Pill" using `rounded-full` and `label-md` typography.

### Structured Forms & Multi-Step Indicators
*   **Inputs:** `surface-container-low` background. No border. On focus, shift background to `surface-container-lowest` and apply a 2px "Ghost Border" using `primary`.
*   **Progress Indicators:** Use a horizontal "Breadcrumb-Pill" hybrid. Active steps use `primary` gradients; incomplete steps use `outline-variant` at 20% opacity.

### Cards & Lists
*   **Strict Rule:** No dividers. Use `spacing-6` vertical gaps to separate list items. Use background color shifts (`surface-container-lowest` vs `surface-container-low`) to group related financial data.

---

## 6. Do's and Don'ts

### Do
*   **Do** use `spacing-10` and `spacing-12` for page margins to create "Breathing Room." High-end finance requires space to think.
*   **Do** use `surface-tint` sparingly to highlight active navigation states.
*   **Do** lean on the `xl` (1.5rem) roundedness for large containers and `md` (0.75rem) for smaller nested elements.

### Don't
*   **Don't** use pure black (#000000) for text. Always use `on-surface` (#2c2f31) to maintain a soft, premium contrast.
*   **Don't** use standard "drop-shadow" presets. If it looks like a default shadow, it’s too heavy.
*   **Don't** use 1px dividers to separate form fields. Use whitespace or subtle tonal shifts between `surface` tiers.