---
draft: true
exam_objectives:
- Using Material UI components
---
# Summary

Material UI is the component library under most Backstage interfaces, and it exists in two incompatible generations. Version 4 uses the `@material-ui` packages, JSS and `makeStyles`. Version 5 uses the `@mui` packages, Emotion, `styled` and the `sx` prop. The scope in an import path identifies the generation, and every import must match a dependency that the plugin declares in its `package.json`. A hoisted package that happens to work locally is not a declaration.

`Grid` lays out content in a twelve-column row with `container`, `item`, breakpoint props and `spacing`. `Typography` applies a theme text style, and the `component` prop chooses the HTML element. `Button` renders a `button` for an action and an anchor when it has `href`. `InfoCard` from `@backstage/core-components` replaces a plain Material UI card when the portal look and error handling are needed.

`makeStyles` with a theme callback and `styled` with a theme argument both read spacing and palette values from the portal theme. Pixel values and color codes typed into a component do not follow the theme. A plugin picks one generation and keeps it for imports, dependencies and styles. The application provides the theme to both generations through `UnifiedThemeProvider`.

<!-- astrona:playground:destroy -->
