# Solution: Register The scout-status Plugin In The App

Work in `/home/candidate/backstage-app`. After each step, run `astrona submit` to see which checks now pass.

## 1. Export a routable extension from the plugin

A plugin object alone does not put any page in the app. A routable extension wraps a React component, loads it lazily and ties it to a route reference. Open `plugins/scout-status/src/plugin.ts` with `nano` and replace its content with:

```ts
import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const scoutStatusPlugin = createPlugin({
  id: 'scout-status',
  routes: {
    root: rootRouteRef,
  },
});

export const ScoutStatusPage = scoutStatusPlugin.provide(
  createRoutableExtension({
    name: 'ScoutStatusPage',
    component: () =>
      import('./components/ScoutStatusPage').then(m => m.ScoutStatusPage),
    mountPoint: rootRouteRef,
  }),
);
```

## 2. Export it from the package entry point

The app imports from the package name, and the package entry point is `src/index.ts`. Replace the file with:

```ts
export { scoutStatusPlugin, ScoutStatusPage } from './plugin';
```

## 3. Add the package to the app dependencies

In `packages/app/package.json`, add this line inside `dependencies`, and keep the commas correct:

```json
"@internal/plugin-scout-status": "workspace:^",
```

Check that the file is still valid JSON with `python3 -m json.tool packages/app/package.json`.

## 4. Import the page in App.tsx

Add this line after the `@backstage/plugin-catalog` import:

```tsx
import { ScoutStatusPage } from '@internal/plugin-scout-status';
```

## 5. Add the route

Replace the commented-out line inside `FlatRoutes` with a real route:

```tsx
<Route path="/scout-status" element={<ScoutStatusPage />} />
```

The finished `FlatRoutes` block has the `/catalog` route and the `/scout-status` route.

## Why the checks look like this

The checks read the files and ignore comments. The comment `{/* <Route ... /> */}` in the starting file looked like a route but never rendered anything, so it does not pass. The route must be inside `FlatRoutes`, because that component picks the route that matches the address.
