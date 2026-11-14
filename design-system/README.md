# BNOS UI Design System (`bnos-ui`)

A native Qt 6 QML component library inspired by the **shadcn/ui** design system, tailored for BNOS (BlazeNeuro Operating System).

## Architecture

- **Single Source of Truth:** `Theme.qml` singleton contains all design tokens:
  - Neutral zinc/slate color palette (`background`, `foreground`, `card`, `popover`, `primary`, `secondary`, `muted`, `accent`, `destructive`, `border`, `inputBorder`, `ring`)
  - Dynamic Light & Dark mode support
  - 1px border styling & subtle shadows
  - Focus ring tokens
  - Radii scale (`radiusSm`, `radiusMd`, `radiusLg`, `radiusXl`, `radiusFull`)
  - Typography scale & font tokens

- **Components:**
  - `BButton`: Variants (`default`, `secondary`, `outline`, `ghost`, `destructive`, `link`), sizes (`sm`, `default`, `lg`, `icon`), active press physics, focus rings.
  - `BInput`: Text input with placeholder, clean 1px border, focus ring, leading/trailing icon support.
  - `BCard`: Container with header, title, description, content slot, and border.
  - `BSwitch`: Smooth animated pill switch.
  - `BCheckbox`: Animated checkbox with check icon.
  - `BBadge`: Status badge with multiple variants.
  - `BTabs`: Segmented tab bar with selection pill.
  - `BIcon`: Recolor-aware SVG icon renderer utilizing the Solar Icon set.
  - `BDialog`: Modal dialog with backdrop scrim and animations.
  - `BToast`: Floating notification toast.
  - `BSeparator`: 1px border separator line.

## Icons

Solar Icons by 480 Design (CC BY 4.0).
Exposed through `BIcon` with dynamic currentColor tinting following the theme tokens.
