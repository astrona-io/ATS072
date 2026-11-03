#!/usr/bin/env bash
# Capstone: the beacon feature on the current frontend and backend systems
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
  title: Starfleet Beacon Portal
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

# Read by the backend only. The value comes from the environment of the
# backend process.
beacon:
  token: ${BEACON_TOKEN}
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
    "@backstage/frontend-defaults": "backstage:^",
    "@backstage/frontend-plugin-api": "backstage:^",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'__ASTRONA_EOF__'
import ReactDOM from 'react-dom/client';
import { createApp } from '@backstage/frontend-defaults';

const app = createApp({
  features: [],
});

ReactDOM.createRoot(document.getElementById('root')!).render(app.createRoot());
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
    "@internal/plugin-beacon-backend": "workspace:^",
    "@internal/plugin-beacon-backend-module-ground-station": "workspace:^"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'__ASTRONA_EOF__'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));

backend.start();
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend-module-ground-station/package.json")"
cat > "$APP/plugins/beacon-backend-module-ground-station/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-beacon-backend-module-ground-station",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "backend-plugin-module",
    "pluginId": "beacon",
    "pluginPackage": "@internal/plugin-beacon-backend"
  },
  "dependencies": {
    "@backstage/backend-plugin-api": "backstage:^",
    "@internal/plugin-beacon-node": "workspace:^"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend-module-ground-station/src/index.ts")"
cat > "$APP/plugins/beacon-backend-module-ground-station/src/index.ts" <<'__ASTRONA_EOF__'
export { beaconModuleGroundStation as default } from './module';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend-module-ground-station/src/module.ts")"
cat > "$APP/plugins/beacon-backend-module-ground-station/src/module.ts" <<'__ASTRONA_EOF__'
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';

export const beaconModuleGroundStation = createBackendModule({
  pluginId: 'beacon',
  moduleId: 'ground-station',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
      },
      async init({ logger }) {
        logger.info('Ground station module loaded');
      },
    });
  },
});
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend-module-ground-station/src/sources.ts")"
cat > "$APP/plugins/beacon-backend-module-ground-station/src/sources.ts" <<'__ASTRONA_EOF__'
import { BeaconSource } from '@internal/plugin-beacon-node';

export const groundStationSource: BeaconSource = {
  name: 'ground-station',
  async read(_token: string) {
    return [
      { id: 'beacon-alpha', state: 'transmitting' },
      { id: 'beacon-bravo', state: 'silent' },
    ];
  },
};
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend/package.json")"
cat > "$APP/plugins/beacon-backend/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-beacon-backend",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "backend-plugin",
    "pluginId": "beacon",
    "pluginPackages": [
      "@internal/plugin-beacon",
      "@internal/plugin-beacon-backend",
      "@internal/plugin-beacon-node"
    ]
  },
  "dependencies": {
    "@backstage/backend-plugin-api": "backstage:^",
    "@internal/plugin-beacon-node": "workspace:^",
    "express": "^4.17.1",
    "express-promise-router": "^4.1.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend/src/index.ts")"
cat > "$APP/plugins/beacon-backend/src/index.ts" <<'__ASTRONA_EOF__'
export { beaconPlugin as default } from './plugin';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend/src/plugin.ts")"
cat > "$APP/plugins/beacon-backend/src/plugin.ts" <<'__ASTRONA_EOF__'
import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';
import { BeaconSource } from '@internal/plugin-beacon-node';
import { createRouter } from './router';

export const beaconPlugin = createBackendPlugin({
  pluginId: 'beacon',
  register(env) {
    const sources: BeaconSource[] = [];

    env.registerInit({
      deps: {
        logger: coreServices.logger,
        httpRouter: coreServices.httpRouter,
      },
      async init({ logger, httpRouter }) {
        const token = 'lantern-7f3a';
        httpRouter.use(await createRouter({ logger, sources, token }));
      },
    });
  },
});
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend/src/router.ts")"
cat > "$APP/plugins/beacon-backend/src/router.ts" <<'__ASTRONA_EOF__'
import { LoggerService } from '@backstage/backend-plugin-api';
import { BeaconSource } from '@internal/plugin-beacon-node';
import express from 'express';
import Router from 'express-promise-router';

export interface RouterOptions {
  logger: LoggerService;
  sources: BeaconSource[];
  token: string;
}

export async function createRouter(
  options: RouterOptions,
): Promise<express.Router> {
  const { logger, sources, token } = options;
  const router = Router();

  router.get('/beacons', async (_req, res) => {
    logger.info('Beacon list requested');
    const lists = await Promise.all(sources.map(source => source.read(token)));
    res.json({ beacons: lists.flat() });
  });

  return router;
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-node/package.json")"
cat > "$APP/plugins/beacon-node/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-beacon-node",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "node-library",
    "pluginId": "beacon"
  },
  "dependencies": {
    "@backstage/backend-plugin-api": "backstage:^"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-node/src/extensions.ts")"
cat > "$APP/plugins/beacon-node/src/extensions.ts" <<'__ASTRONA_EOF__'
import { createExtensionPoint } from '@backstage/backend-plugin-api';

export interface BeaconSource {
  name: string;
  read(token: string): Promise<Array<{ id: string; state: string }>>;
}

export interface BeaconSourcesExtensionPoint {
  addSource(source: BeaconSource): void;
}

export const beaconSourcesExtensionPoint =
  createExtensionPoint<BeaconSourcesExtensionPoint>({
    id: 'beacon.sources',
  });
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-node/src/index.ts")"
cat > "$APP/plugins/beacon-node/src/index.ts" <<'__ASTRONA_EOF__'
export * from './extensions';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/package.json")"
cat > "$APP/plugins/beacon/package.json" <<'__ASTRONA_EOF__'
{
  "name": "@internal/plugin-beacon",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "backstage": {
    "role": "frontend-plugin",
    "pluginId": "beacon",
    "pluginPackages": [
      "@internal/plugin-beacon",
      "@internal/plugin-beacon-backend",
      "@internal/plugin-beacon-node"
    ]
  },
  "dependencies": {
    "@backstage/core-components": "backstage:^",
    "@backstage/core-plugin-api": "backstage:^",
    "@backstage/frontend-plugin-api": "backstage:^",
    "react": "^18.0.0",
    "react-use": "^17.0.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/src/components/BeaconPage.tsx")"
cat > "$APP/plugins/beacon/src/components/BeaconPage.tsx" <<'__ASTRONA_EOF__'
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import { Progress, ResponseErrorPanel } from '@backstage/core-components';
import {
  discoveryApiRef,
  fetchApiRef,
  useApi,
} from '@backstage/core-plugin-api';

type Beacon = { id: string; state: string };

export const BeaconPage = () => {
  const discoveryApi = useApi(discoveryApiRef);
  const fetchApi = useApi(fetchApiRef);

  const { value, loading, error } = useAsync(async (): Promise<Beacon[]> => {
    const baseUrl = await discoveryApi.getBaseUrl('beacon');
    const response = await fetchApi.fetch(`${baseUrl}/beacons`, {
      headers: { Authorization: 'Bearer lantern-7f3a' },
    });
    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`);
    }
    return (await response.json()).beacons;
  }, []);

  if (loading) {
    return <Progress />;
  }
  if (error) {
    return <ResponseErrorPanel error={error} />;
  }
  return (
    <ul>
      {(value ?? []).map(beacon => (
        <li key={beacon.id}>
          {beacon.id}: {beacon.state}
        </li>
      ))}
    </ul>
  );
};
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/src/index.ts")"
cat > "$APP/plugins/beacon/src/index.ts" <<'__ASTRONA_EOF__'
export { beaconPlugin, BeaconPage } from './plugin';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/src/plugin.ts")"
cat > "$APP/plugins/beacon/src/plugin.ts" <<'__ASTRONA_EOF__'
import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const beaconPlugin = createPlugin({
  id: 'beacon',
});

export const BeaconPage = beaconPlugin.provide(
  createRoutableExtension({
    name: 'BeaconPage',
    component: () => import('./components/BeaconPage').then(m => m.BeaconPage),
    mountPoint: rootRouteRef,
  }),
);
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/src/routes.ts")"
cat > "$APP/plugins/beacon/src/routes.ts" <<'__ASTRONA_EOF__'
import { createRouteRef } from '@backstage/frontend-plugin-api';

export const rootRouteRef = createRouteRef();
__ASTRONA_EOF__

chown -R "$(whoami):$(whoami)" /home/candidate 2>/dev/null || sudo chown -R "$(whoami):$(whoami)" /home/candidate
echo "[bootstrap] project written to $APP"
