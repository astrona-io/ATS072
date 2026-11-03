# Question

Solve this question on: `terminal`

The `scout-status` page of the outpost portal in `/home/candidate/backstage-app` was assembled from three examples. It is hard to read in a second theme, shows scout health only as coloured dots and shows a blank page while it loads. Make it consistent and accessible without removing any feature.

1. The application and the plugin must use one Material UI generation. The plugin declares Material UI v4 (`@material-ui/core`). Remove every `@mui` import and keep the dependencies as they are.
2. `ScoutStatusCard` must render each scout in an `InfoCard` from `@backstage/core-components`. `ScoutList` must use a `Grid` with `container spacing={3}` and `Grid item xs={12}` children, without the `sx` prop.
3. Create `scoutTheme` in `packages/app/src/theme/scoutTheme.ts` with `createUnifiedTheme` from `@backstage/theme` (start from `palettes.light`, `primary.main` of `#1f6feb`, `defaultPageTheme` of `'home'`) and register it in `createApp` with `variant: 'light'` and a `UnifiedThemeProvider`.
4. No colour literal may remain in `plugins/scout-status/src`. `ScoutPanel` must read colours from `theme.palette` and spacing from `theme.spacing()`.
5. Replace the coloured dot with `StatusOK`, `StatusWarning`, `StatusError` and `StatusPending` from `@backstage/core-components`, each with words that name the state.
6. Give the icon-only refresh button an `aria-label`, and make it call `retry` from `useScoutStatus`.
7. `ScoutStatusPage` must show `Progress` while loading, `ResponseErrorPanel` with the error when the request failed, and `EmptyState` (with a title and a description) when the list is empty. Check them in that order. Do not return `null` while loading.
