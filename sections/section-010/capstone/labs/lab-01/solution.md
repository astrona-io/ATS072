# Solution: Move The beacon Feature To The Current Systems

Work in `/home/candidate/backstage-app`. After each step, run `astrona submit` to see which checks pass.

## 1. Rewrite the frontend plugin for the new frontend system

The legacy `createPlugin` and `createRoutableExtension` belong to the legacy frontend system. The app uses `createApp` from `@backstage/frontend-defaults`, which only knows plugins made with `createFrontendPlugin`. Create `plugins/beacon/src/plugin.tsx` (the loader returns JSX, so the extension must be `.tsx`):

```tsx
import {
  createFrontendPlugin,
  PageBlueprint,
} from '@backstage/frontend-plugin-api';
import { rootRouteRef } from './routes';

const beaconPage = PageBlueprint.make({
  params: {
    routeRef: rootRouteRef,
    path: '/beacon',
    loader: () => import('./components/BeaconPage').then(m => <m.BeaconPage />),
  },
});

export const beaconPlugin = createFrontendPlugin({
  pluginId: 'beacon',
  extensions: [beaconPage],
  routes: {
    root: rootRouteRef,
  },
});
```

Delete the old file with `rm plugins/beacon/src/plugin.ts`. Then replace `plugins/beacon/src/index.ts` with:

```ts
export { beaconPlugin as default } from './plugin';
```

## 2. Register the plugin in the app

In `packages/app/src/App.tsx`, import the plugin and pass it in `features`:

```tsx
import beaconPlugin from '@internal/plugin-beacon';

const app = createApp({
  features: [beaconPlugin],
});
```

Add `"@internal/plugin-beacon": "workspace:^"` to `dependencies` in `packages/app/package.json`.

## 3. Finish the backend plugin

The plugin owns the extension point. It must register it in `register`, before `registerInit`. Modules that extend the plugin are initialized before the plugin `init` runs, so `sources` already holds their sources when the router is created. The token comes from the root configuration service. Replace `plugins/beacon-backend/src/plugin.ts` with:

```ts
import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';
import {
  BeaconSource,
  beaconSourcesExtensionPoint,
} from '@internal/plugin-beacon-node';
import { createRouter } from './router';

export const beaconPlugin = createBackendPlugin({
  pluginId: 'beacon',
  register(env) {
    const sources: BeaconSource[] = [];

    env.registerExtensionPoint(beaconSourcesExtensionPoint, {
      addSource(source) {
        sources.push(source);
      },
    });

    env.registerInit({
      deps: {
        logger: coreServices.logger,
        httpRouter: coreServices.httpRouter,
        config: coreServices.rootConfig,
      },
      async init({ logger, httpRouter, config }) {
        const token = config.getString('beacon.token');
        httpRouter.use(await createRouter({ logger, sources, token }));
      },
    });
  },
});
```

## 4. Use the extension point in the module

Replace `plugins/beacon-backend-module-ground-station/src/module.ts` with:

```ts
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';
import { beaconSourcesExtensionPoint } from '@internal/plugin-beacon-node';
import { groundStationSource } from './sources';

export const beaconModuleGroundStation = createBackendModule({
  pluginId: 'beacon',
  moduleId: 'ground-station',
  register(env) {
    env.registerInit({
      deps: {
        beacons: beaconSourcesExtensionPoint,
        logger: coreServices.logger,
      },
      async init({ beacons, logger }) {
        logger.info('Ground station module loaded');
        beacons.addSource(groundStationSource);
      },
    });
  },
});
```

## 5. Add the packages to the backend

In `packages/backend/src/index.ts`, add the two packages and keep the app backend:

```ts
backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@internal/plugin-beacon-backend'));
backend.add(import('@internal/plugin-beacon-backend-module-ground-station'));
```

The node library `@internal/plugin-beacon-node` is only imported by the plugin and the module. It is not a plugin or a module, so it never goes in `backend.add`.

## 6. Remove the token from the browser code

In `plugins/beacon/src/components/BeaconPage.tsx`, change the request to `await fetchApi.fetch(`${baseUrl}/beacons`)` and remove the `headers` object. Check that no source file contains the token any more with `grep -rn lantern plugins`. The command prints nothing when you are done.

## Why the checks look like this

Every check ignores comments. The frontend check rejects a file that still imports the legacy API, because the new `createApp` does not load legacy plugins as features. The backend checks follow the lifecycle: the plugin registers its extension point, the module fills it, and the backend loads both packages. A token in browser code is visible to every user, so the last check also looks at the browser file.
