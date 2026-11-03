# Solution: Install A Backend Plugin And A Module

Work in `/home/candidate/backstage-app`. After each step, run `astrona submit` to see which checks pass.

## 1. Fix the plugin id and mount the router

The plugin id decides the URL path of the plugin: the HTTP router service serves the plugin under `/api/<pluginId>`. The frontend asks the discovery API for `scout-status`, so the id must be exactly that. The `-backend` suffix belongs to the package name only. Replace `plugins/scout-status-backend/src/plugin.ts` with:

```ts
import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';
import { createRouter } from './router';

export const scoutStatusPlugin = createBackendPlugin({
  pluginId: 'scout-status',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
        httpRouter: coreServices.httpRouter,
      },
      async init({ logger, httpRouter }) {
        httpRouter.use(await createRouter({ logger }));
      },
    });
  },
});
```

## 2. Fix the module

The file imported the extension point from a private path inside the catalog backend package. A private path is not a supported contract and can change in any release. The supported extension point is exported by `@backstage/plugin-catalog-node`. Replace `plugins/catalog-backend-module-outpost/src/module.ts` with:

```ts
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';
import { catalogProcessingExtensionPoint } from '@backstage/plugin-catalog-node';
import { OutpostProcessor } from './OutpostProcessor';

export const catalogModuleOutpostEntities = createBackendModule({
  pluginId: 'catalog',
  moduleId: 'outpost-entities',
  register(env) {
    env.registerInit({
      deps: {
        catalog: catalogProcessingExtensionPoint,
        logger: coreServices.logger,
      },
      async init({ catalog, logger }) {
        logger.info('Registering the outpost processor');
        catalog.addProcessor(new OutpostProcessor());
      },
    });
  },
});
```

## 3. Add both packages to the backend

In `packages/backend/src/index.ts`, the plugin line was commented out and the module line was missing. The file becomes:

```ts
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(import('@internal/plugin-scout-status-backend'));
backend.add(import('@internal/plugin-catalog-backend-module-outpost'));

backend.start();
```

## 4. Add the dependencies

In `packages/backend/package.json`, the `dependencies` object gets these two entries (keep the commas correct):

```json
"@internal/plugin-scout-status-backend": "workspace:^",
"@internal/plugin-catalog-backend-module-outpost": "workspace:^"
```

Check the JSON with `python3 -m json.tool packages/backend/package.json`.

## Why the checks look like this

A package that is installed but not passed to `backend.add` never starts. The checks ignore comments, so the commented `backend.add` line in the starting file does not count. The module is loaded in the same backend as the catalog plugin, and Backstage initializes it before the catalog plugin starts.
