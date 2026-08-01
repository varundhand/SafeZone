---
name: SafeZone
colors:
  surface: '#fbf9f9'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e3e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#504536'
  inverse-surface: '#303031'
  inverse-on-surface: '#f2f0f0'
  outline: '#827563'
  outline-variant: '#d4c4b0'
  surface-tint: '#7f5700'
  primary: '#7f5700'
  on-primary: '#ffffff'
  primary-container: '#e5a93d'
  on-primary-container: '#5e4000'
  inverse-primary: '#fabc4e'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#5d5f5f'
  on-tertiary: '#ffffff'
  tertiary-container: '#b3b4b4'
  on-tertiary-container: '#444646'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdead'
  primary-fixed-dim: '#fabc4e'
  on-primary-fixed: '#281900'
  on-primary-fixed-variant: '#604100'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e2e2e2'
  tertiary-fixed-dim: '#c6c6c7'
  on-tertiary-fixed: '#1a1c1c'
  on-tertiary-fixed-variant: '#454747'
  background: '#fbf9f9'
  on-background: '#1b1c1c'
  surface-variant: '#e3e2e2'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm-mobile:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 12px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  edge-margin: 20px
  gutter: 12px
---

## Brand & Style

The design system is centered on the principles of **Precision, Clarity, and Calm**. As a safety-critical application, the interface must minimize cognitive load while providing immediate reassurance. 

The style is **Refined Minimalism**. It utilizes thin, purposeful lines (0.5pt to 1pt) and generous whitespace to create an airy, focused environment. By avoiding heavy fills and aggressive shadows, the UI feels lightweight and fast. The aesthetic prioritizes "glanceability," ensuring that users can understand their safety status or a dependent's location in under a second. High-contrast typography is paired with a strictly functional color application to ensure accessibility for all age groups.

## Colors

The palette is designed for high functional contrast. The **Primary Golden Yellow** is reserved exclusively for action-oriented elements and active safety states, serving as a beacon against the neutral backdrop.

- **Primary (#E5A93D):** Used for primary buttons, active geofence boundaries, and high-priority status indicators.
- **Surface (#FFFFFF):** The primary background for all cards, sheets, and modals to maintain a clean, professional "paper" feel.
- **Typography (#1A1A1A):** Used for all headers and primary body text to ensure maximum legibility.
- **Functional States:** Success (#2E7D32) and Alert (#D32F2F) are used sparingly for status chips and critical notifications.
- **Neutral Accents:** Soft greys (e.g., #EEEEEE, #BDBDBD) are used for map boundaries, inactive states, and divider lines.

## Typography

This design system utilizes **Inter** for its exceptional readability on mobile displays and its neutral, professional tone. 

Typography is organized into a strict hierarchy to facilitate quick scanning of data. Headlines use a slightly tighter letter-spacing and heavier weights to anchor sections, while body text maintains a generous line height to prevent visual crowding. Labels are used for metadata like timestamps, coordinates, and distance markers. For mobile devices, headlines are capped at 24px-28px to ensure long location names do not wrap awkwardly.

## Layout & Spacing

The design system employs a **fluid-width, fixed-margin layout**. Content is primarily housed within bottom sheets and floating cards that sit above a full-screen map interface.

- **Margins:** A consistent 20px margin is maintained from the screen edges.
- **Vertical Rhythm:** A 4px baseline grid governs all spacing. Vertical gaps between related elements (e.g., a header and its description) should be 8px (sm), while gaps between distinct sections should be 24px (lg).
- **Safe Areas:** Interactive elements must be kept clear of the system's home indicator and status bar areas, typically requiring a 44px top offset and 34px bottom offset on modern mobile devices.

## Elevation & Depth

To maintain a thin and light aesthetic, this design system avoids heavy shadows. Depth is communicated through **Low-Contrast Outlines** and **Ambient Shadows**.

- **Level 0 (Map/Base):** The bottom-most layer.
- **Level 1 (Cards/Lists):** Uses a subtle 1px border (#EEEEEE) to define boundaries without adding weight. No shadow is used if the card is on a plain background.
- **Level 2 (Floating Elements):** For buttons or sheets floating over the map, use an extra-diffused ambient shadow: `0px 4px 20px rgba(0, 0, 0, 0.06)`. This creates a soft lift that ensures the map remains visible underneath while clearly separating the UI.
- **Level 3 (Modals/Critical Alerts):** Uses a slightly deeper shadow: `0px 8px 32px rgba(0, 0, 0, 0.12)`.

## Shapes

The shape language is **Softly Geometric**. 

- **Standard Containers:** Cards, input fields, and notification banners use a 12px (`rounded-lg`) corner radius.
- **Interactive Elements:** Primary buttons use a 12px radius to match containers. Small buttons or chips may use a 8px (`rounded-md`) radius.
- **Map Pins:** Utilize a teardrop or circular shape to distinguish them from standard UI containers.
- **Lines:** All icons and divider lines should use a "round" cap and join style to mirror the soft corner radius of the components.

## Components

### Buttons
- **Primary:** Solid #E5A93D fill with #1A1A1A text. 12px corner radius. No shadow.
- **Secondary/Outline:** 1px #1A1A1A border, transparent background.
- **Ghost:** No border or fill, primary color text. Used for less frequent actions like "View History."

### Input Fields
- Outlined style with a 1px #BDBDBD border. When focused, the border changes to #E5A93D. Labels sit above the field in `label-md` style.

### Cards
- White background, 1px #EEEEEE border, 12px corner radius. Used for "Recent Activity," "Member Profiles," and "Saved Zones."

### Chips/Badges
- Small 8px rounded elements used for status (e.g., "Safe," "Away," "Low Battery"). Use a 10% opacity version of the status color for the background and 100% opacity for the text.

### Bottom Sheets
- Large 24px top-corner radius. Includes a thin "grabber" handle at the top. Used for detailed location information and settings.

### Map Markers
- Minimalist circular avatars with a 2px white border and the primary shadow style. An outer "Halo" ring in #E5A93D indicates the accuracy of the GPS signal.