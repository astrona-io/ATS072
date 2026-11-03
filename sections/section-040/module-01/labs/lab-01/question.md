# Question

Solve this question on: `terminal`

The `scout-status` plugin in `/home/candidate/backstage-app/plugins/scout-status` shows the state of the scouts of the outpost. Its `package.json` declares Material UI v4 (`@material-ui/core`) and nothing else from the Material UI family. Two files were copied from an example written for Material UI v5 and now import `@mui` packages. A build with both generations would load two copies of the library with separate style engines.

1. In `src/components/ScoutStatusCard.tsx`, import `Typography` and `Button` from `@material-ui/core` and `makeStyles` from `@material-ui/core/styles`. Keep the `theme.spacing` call in the styles.
2. In the same file, replace the Material UI `Card`, `CardHeader` and `CardContent` with `InfoCard` from `@backstage/core-components`, titled with the scout name.
3. In `src/components/ScoutList.tsx`, import `Grid` from `@material-ui/core`, keep one `Grid container` with `Grid item xs={12}` children, and remove the `Box` that uses the `sx` prop (it exists only in Material UI v5).
4. Do not add `@mui` packages to any `package.json` and do not remove `@material-ui/core` or `@backstage/core-components`. Do not delete a component.
