---
draft: true
exam_objectives:
- Using Material UI components
---
# Using Material UI components

This section covers using Material UI components in Backstage. It has two lessons. The first explains which Material UI generation a plugin uses and how to build a page with `Grid`, `Typography`, `Button`, `InfoCard` and theme-aware styles. The second explains how a theme is created and registered, how plugins use theme tokens, and how to present controls and status states accessibly.

Each lesson has its own playground, a virtual machine with a small Backstage-style project, and a graded lab that you solve by editing files. Read the lessons in order. The section ends with a capstone lab and a quiz.

## Learning Outcomes

- Tell Material UI v4 from v5 by import path and `package.json`, and keep imports aligned with declared dependencies.
- Build page layout with `Grid`, `Typography`, `Button` and `InfoCard`, and write styles with `makeStyles` or `styled`.
- Create a theme with `createUnifiedTheme` and register it through `UnifiedThemeProvider` and `createApp`.
- Replace hard-coded colors with theme tokens and give controls accessible names.
- Present status with text as well as color, and keep loading, error and empty states distinct.
