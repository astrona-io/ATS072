---
draft: true
exam_objectives:
- Using Material UI components
---
# Summary

A Backstage theme is created with `createUnifiedTheme` from `@backstage/theme`, usually by spreading `palettes.light` or `palettes.dark` and changing a few values. It reaches components only when the application lists it in the `themes` option of `createApp` with a `Provider` that renders `UnifiedThemeProvider`. That provider supplies the same theme to Material UI v4 and v5 components.

Plugins read colors and spacing from theme tokens such as `theme.palette.text.primary` and `theme.spacing()`. A hard-coded color or pixel value ignores the active appearance and can become unreadable in a dark theme. Color codes belong in the theme file.

Controls use semantic elements: a button for an action and a link for navigation. An icon-only control needs an `aria-label` that names its action. Status uses `StatusOK`, `StatusWarning`, `StatusError` and `StatusPending` with words, so the state does not depend on color. Unknown or stale data must not look healthy. A page keeps loading, error and empty states apart with `Progress`, `ResponseErrorPanel` and `EmptyState`, checked in that order. These components present data; they do not validate it or enforce permissions.

<!-- astrona:playground:destroy -->
