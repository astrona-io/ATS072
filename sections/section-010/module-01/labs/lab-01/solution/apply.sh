#!/usr/bin/env bash
# Lab: the scout-status plugin is not registered in the app
# Runs only under `astrona test`: writes the reference solution files.
set -eu

APP=/home/candidate/backstage-app

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

echo "[testing] reference solution applied"
