# Question

Solve this question on: `terminal`

The portal of the outpost must show scout health in a custom light theme, and the health must be readable without colour. The project is in `/home/candidate/backstage-app`.

1. In `packages/app/src/theme/scoutTheme.ts`, export `scoutTheme`, created with `createUnifiedTheme` from `@backstage/theme`. Spread `palettes.light`, set the `primary` colour `main` to `#1f6feb` and set `defaultPageTheme` to `'home'`.
2. In `packages/app/src/App.tsx`, give `createApp` a `themes` list with one entry: an `id`, a `title`, `variant: 'light'` and a `Provider` that renders `UnifiedThemeProvider` with `scoutTheme`.
3. In `plugins/scout-status/src/components/ScoutStatusBadge.tsx`, replace the coloured dot with `StatusOK`, `StatusWarning` and `StatusError` (and `StatusPending` for an unknown state) from `@backstage/core-components`. Each one must contain words that say the state, such as "is operational".
4. In `ScoutPanel.tsx`, replace the fixed colours and pixel values with values from the theme: `theme.palette` for colours and `theme.spacing()` for padding and margin.
5. In `ScoutToolbar.tsx`, give the icon-only refresh button an accessible name with `aria-label`.
6. No hex, `rgb` or `hsl` colour may remain anywhere in `plugins/scout-status/src`. Do not delete a component.
