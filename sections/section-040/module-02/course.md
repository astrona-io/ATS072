---
draft: true
exam_objectives:
- Using Material UI components
---
# Themes, Layout And Accessible Status States

This lesson explains how a Backstage portal gets its look from one theme, how a plugin should use that theme instead of fixed colors, and how to present status, loading, error and empty states so that every user can read them. It continues with the `scout-status` plugin of an outpost.

## Learning Goals

- Create a theme with `createUnifiedTheme` and register it with `UnifiedThemeProvider` and `createApp`.
- Replace hard-coded colors and spacing with theme tokens.
- Choose semantic controls and give icon-only controls an accessible name with `aria-label`.
- Show health with `StatusOK`, `StatusWarning` and `StatusError` plus text, and keep loading, error and empty states apart.

## Before You Start

You should know what a React component and a Material UI component are. The hands-on steps use a playground virtual machine with a small Backstage-style project, `grep`, `cat` and an editor such as `nano`. No Node.js, build or network access is needed. Technical terms are defined where they first appear.

## Reading Order

1. Creating And Registering A Theme
2. Theme Tokens And Semantic Controls
3. Accessible Status And Loading States
4. Summary

<!-- astrona:playground -->
