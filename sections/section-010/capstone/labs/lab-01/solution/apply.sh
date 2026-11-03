#!/usr/bin/env bash
# Capstone: the beacon feature on the current frontend and backend systems
# Runs only under `astrona test`: writes the reference solution files.
set -eu

APP=/home/candidate/backstage-app

rm -f "$APP/plugins/beacon/src/plugin.ts"
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
    "@internal/plugin-beacon": "workspace:^",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'__ASTRONA_EOF__'
import ReactDOM from 'react-dom/client';
import { createApp } from '@backstage/frontend-defaults';
import beaconPlugin from '@internal/plugin-beacon';

const app = createApp({
  features: [beaconPlugin],
});

ReactDOM.createRoot(document.getElementById('root')!).render(app.createRoot());
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'__ASTRONA_EOF__'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@internal/plugin-beacon-backend'));
backend.add(import('@internal/plugin-beacon-backend-module-ground-station'));

backend.start();
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend-module-ground-station/src/module.ts")"
cat > "$APP/plugins/beacon-backend-module-ground-station/src/module.ts" <<'__ASTRONA_EOF__'
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
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon-backend/src/plugin.ts")"
cat > "$APP/plugins/beacon-backend/src/plugin.ts" <<'__ASTRONA_EOF__'
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
    const response = await fetchApi.fetch(`${baseUrl}/beacons`);
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
export { beaconPlugin as default } from './plugin';
__ASTRONA_EOF__

mkdir -p "$(dirname "$APP/plugins/beacon/src/plugin.tsx")"
cat > "$APP/plugins/beacon/src/plugin.tsx" <<'__ASTRONA_EOF__'
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
__ASTRONA_EOF__

echo "[testing] reference solution applied"
