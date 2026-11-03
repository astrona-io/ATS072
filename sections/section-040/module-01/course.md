---
draft: true
exam_objectives:
- Using Material UI components
---
# Material UI Components In Backstage

This lesson explains which Material UI library a Backstage plugin uses, how the import path tells you, and how to build a plugin page from `Grid`, `Typography`, `Button`, `InfoCard` and a small amount of theme-aware styling. It follows one example plugin, `scout-status`, which lists the state of the scouts of an outpost.

## Learning Goals

- Tell Material UI v4 (`@material-ui/core`) from Material UI v5 (`@mui/material`) by import path and by `package.json`.
- Explain why imports must match declared dependencies and what goes wrong when two generations are mixed.
- Lay out a page with `Grid`, `Typography`, `Button` and `InfoCard` from `@backstage/core-components`.
- Write styles with `makeStyles` (v4) or `styled` and `sx` (v5) that read spacing and colors from the theme.

## Before You Start

You should know what a React component, a prop and an import statement are. The hands-on steps use a playground virtual machine with a small Backstage-style project, `grep`, `cat` and an editor such as `nano`. No Node.js, build or network access is needed, because the steps read and edit source files only. Technical terms are defined where they first appear.

## Reading Order

1. Material UI Versions And Import Paths
2. Layout And Content Components: Grid, Typography, Button And Card
3. Styling With makeStyles And styled
4. Summary

<!-- astrona:playground -->
