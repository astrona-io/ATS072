#!/usr/bin/env bash
# Playground: a working Backstage-style project with a backend plugin and a module
# Writes a small Backstage-style monorepo to /home/candidate/backstage-app.
# There is no node_modules directory: nothing here installs or runs Backstage.

set -eu

APP=/home/candidate/backstage-app

sudo mkdir -p /home/candidate
sudo chown -R "$(whoami):$(whoami)" /home/candidate

rm -rf "$APP"
mkdir -p "$APP"

mkdir -p "$(dirname "$APP/app-config.yaml")"
cat > "$APP/app-config.yaml" <<'__ASTRONA_EOF__'
app:
  title: Starfleet Scout Portal
  baseUrl: http://localhost:3000

organization:
  name: Starfleet

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  database:
    client: better-sqlite3
    connection: ':memory:'

catalog:
  rules:
    - allow: [Component, System, API, Resource, Location]

scoutStatus:
  statusUrl: http://outpost-scout.local/status
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/package.json")"
cat > "$APP/package.json" <<'__ASTRONA_EOF__'
{
  "name": "root",
  "version": "1.0.0",
  "private": true,
  "workspaces": {
    "packages": [
      "packages/*",
      "plugins/*"
    ]
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/app/package.json")"
cat > "$APP/packages/app/package.json" <<'__ASTRONA_EOF__'
{
  "name": "app",
  "version": "0.1.0",
  "private": true,
  "main": "src/App.tsx",
  "dependencies": {
    "@backstage/app-defaults": "backstage:^",
    "@backstage/core-app-api": "backstage:^",
    "@backstage/core-components": "backstage:^",
    "@backstage/core-plugin-api": "backstage:^",
    "@backstage/plugin-catalog": "backstage:^",
    "@internal/plugin-scout-status": "workspace:^",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-router-dom": "^6.0.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'__ASTRONA_EOF__'
import React from 'react';
import { Route } from 'react-router-dom';
import { createApp } from '@backstage/app-defaults';
import { AppRouter, FlatRoutes } from '@backstage/core-app-api';
import { CatalogIndexPage } from '@backstage/plugin-catalog';
import { ScoutStatusPage } from '@internal/plugin-scout-status';

const app = createApp({});

export default app.createRoot(
  <>
    <AppRouter>
      <FlatRoutes>
        <Route path="/catalog" element={<CatalogIndexPage />} />
        <Route path="/scout-status" element={<ScoutStatusPage />} />
      </FlatRoutes>
    </AppRouter>
  </>,
);
__ASTRONA_EOF__

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

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-outpost/package.json")"
cat > "$APP/plugins/catalog-backend-module-outpost/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-catalog-backend-module-outpost",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "backend-plugin-module",
    "pluginId": "catalog",
    "pluginPackage": "@backstage/plugin-catalog-backend"
  },
  "dependencies": {
    "@backstage/backend-plugin-api": "backstage:^",
    "@backstage/catalog-model": "backstage:^",
    "@backstage/plugin-catalog-node": "backstage:^"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-outpost/src/OutpostProcessor.ts")"
cat > "$APP/plugins/catalog-backend-module-outpost/src/OutpostProcessor.ts" <<'__ASTRONA_EOF__'
import { Entity } from '@backstage/catalog-model';
import { CatalogProcessor } from '@backstage/plugin-catalog-node';

export class OutpostProcessor implements CatalogProcessor {
  getProcessorName(): string {
    return 'OutpostProcessor';
  }

  async preProcessEntity(entity: Entity): Promise<Entity> {
    if (entity.kind === 'Component' && entity.metadata.namespace === 'outpost') {
      return {
        ...entity,
        metadata: {
          ...entity.metadata,
          labels: { ...entity.metadata.labels, 'starfleet.example/zone': 'outpost' },
        },
      };
    }
    return entity;
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-outpost/src/index.ts")"
cat > "$APP/plugins/catalog-backend-module-outpost/src/index.ts" <<'__ASTRONA_EOF__'
export { catalogModuleOutpostEntities as default } from './module';
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

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/package.json")"
cat > "$APP/plugins/scout-status-backend/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-scout-status-backend",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "backend-plugin",
    "pluginId": "scout-status",
    "pluginPackages": [
      "@internal/plugin-scout-status",
      "@internal/plugin-scout-status-backend"
    ]
  },
  "dependencies": {
    "@backstage/backend-plugin-api": "backstage:^",
    "express": "^4.17.1",
    "express-promise-router": "^4.1.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/src/index.ts")"
cat > "$APP/plugins/scout-status-backend/src/index.ts" <<'__ASTRONA_EOF__'
export { scoutStatusPlugin as default } from './plugin';
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

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/src/router.ts")"
cat > "$APP/plugins/scout-status-backend/src/router.ts" <<'__ASTRONA_EOF__'
import { LoggerService } from '@backstage/backend-plugin-api';
import express from 'express';
import Router from 'express-promise-router';

export interface RouterOptions {
  logger: LoggerService;
}

export async function createRouter(
  options: RouterOptions,
): Promise<express.Router> {
  const { logger } = options;
  const router = Router();
  router.use(express.json());

  router.get('/status', (_req, res) => {
    logger.info('Scout status requested');
    res.json({
      scouts: [
        { name: 'scout-1', state: 'ready' },
        { name: 'scout-2', state: 'docked' },
      ],
    });
  });

  return router;
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/package.json")"
cat > "$APP/plugins/scout-status/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-scout-status",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "frontend-plugin",
    "pluginId": "scout-status",
    "pluginPackages": [
      "@internal/plugin-scout-status",
      "@internal/plugin-scout-status-backend"
    ]
  },
  "dependencies": {
    "@backstage/core-components": "backstage:^",
    "@backstage/core-plugin-api": "backstage:^",
    "react": "^18.0.0",
    "react-use": "^17.0.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusPage/ScoutStatusPage.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage/ScoutStatusPage.tsx" <<'__ASTRONA_EOF__'
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import {
  Content,
  Header,
  Page,
  Progress,
  ResponseErrorPanel,
} from '@backstage/core-components';
import {
  discoveryApiRef,
  fetchApiRef,
  useApi,
} from '@backstage/core-plugin-api';

type Scout = { name: string; state: string };

export const ScoutStatusPage = () => {
  const discoveryApi = useApi(discoveryApiRef);
  const fetchApi = useApi(fetchApiRef);

  const { value, loading, error } = useAsync(async (): Promise<Scout[]> => {
    const baseUrl = await discoveryApi.getBaseUrl('scout-status');
    const response = await fetchApi.fetch(`${baseUrl}/status`);
    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`);
    }
    const body = await response.json();
    return body.scouts;
  }, []);

  if (loading) {
    return <Progress />;
  }
  if (error) {
    return <ResponseErrorPanel error={error} />;
  }

  return (
    <Page themeId="tool">
      <Header title="Scout status" />
      <Content>
        <ul>
          {(value ?? []).map(scout => (
            <li key={scout.name}>
              {scout.name}: {scout.state}
            </li>
          ))}
        </ul>
      </Content>
    </Page>
  );
};
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusPage/index.ts")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage/index.ts" <<'__ASTRONA_EOF__'
export { ScoutStatusPage } from './ScoutStatusPage';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/src/index.ts")"
cat > "$APP/plugins/scout-status/src/index.ts" <<'__ASTRONA_EOF__'
export { scoutStatusPlugin, ScoutStatusPage } from './plugin';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/src/plugin.ts")"
cat > "$APP/plugins/scout-status/src/plugin.ts" <<'__ASTRONA_EOF__'
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
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/scout-status/src/routes.ts")"
cat > "$APP/plugins/scout-status/src/routes.ts" <<'__ASTRONA_EOF__'
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: 'scout-status',
});
__ASTRONA_EOF__

chown -R "$(whoami):$(whoami)" /home/candidate 2>/dev/null || sudo chown -R "$(whoami):$(whoami)" /home/candidate
echo "[bootstrap] project written to $APP"
