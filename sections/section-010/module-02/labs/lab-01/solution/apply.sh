#!/usr/bin/env bash
# Lab: the backend plugin and module are not installed
# Runs only under `astrona test`: writes the reference solution files.
set -eu

APP=/home/candidate/backstage-app

mkdir -p "$(dirname "$APP/packages/backend/package.json")"
cat > "$APP/packages/backend/package.json" <<'__ASTRONA_EOF__'
{
  "name": "backend",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-defaults": "backstage:^",
    "@backstage/plugin-app-backend": "backstage:^",
    "@backstage/plugin-catalog-backend": "backstage:^",
    "@internal/plugin-scout-status-backend": "workspace:^",
    "@internal/plugin-catalog-backend-module-outpost": "workspace:^"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'__ASTRONA_EOF__'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(import('@internal/plugin-scout-status-backend'));
backend.add(import('@internal/plugin-catalog-backend-module-outpost'));

backend.start();
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-outpost/src/module.ts")"
cat > "$APP/plugins/catalog-backend-module-outpost/src/module.ts" <<'__ASTRONA_EOF__'
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
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/src/plugin.ts")"
cat > "$APP/plugins/scout-status-backend/src/plugin.ts" <<'__ASTRONA_EOF__'
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
__ASTRONA_EOF__

echo "[testing] reference solution applied"
