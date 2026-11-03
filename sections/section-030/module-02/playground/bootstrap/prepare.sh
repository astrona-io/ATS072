#!/usr/bin/env bash
# Playground bootstrap for Asynchronous Catalog Data In React: writes the example Backstage app. No task.
set -eu

APP=/home/candidate/backstage-app

sudo mkdir -p /home/candidate
sudo chown -R "$(whoami):$(whoami)" /home/candidate
rm -rf "$APP"
mkdir -p "$APP"

cat > "$APP/app-config.yaml" <<'ASTRONA_FILE_EOF'
app:
  title: Starfleet Portal
  baseUrl: http://localhost:3000

organization:
  name: Starfleet

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

catalog:
  rules:
    - allow: [Component, System, API, Resource, Location]
  locations:
    - type: file
      target: ../../catalog/outposts.yaml
ASTRONA_FILE_EOF
mkdir -p "$APP/catalog"
cat > "$APP/catalog/outposts.yaml" <<'ASTRONA_FILE_EOF'
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: outpost-alpha
  title: Outpost Alpha
spec:
  type: outpost
  lifecycle: production
  owner: group:default/starfleet-ops
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: outpost-beta
spec:
  type: outpost
  lifecycle: production
  owner: group:default/starfleet-ops
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: outpost-gamma
spec:
  type: outpost
  lifecycle: experimental
  owner: group:default/starfleet-ops
ASTRONA_FILE_EOF
cat > "$APP/package.json" <<'ASTRONA_FILE_EOF'
{
  "name": "root",
  "private": true,
  "version": "1.0.0",
  "workspaces": {
    "packages": ["packages/*", "plugins/*"]
  },
  "scripts": {
    "start": "backstage-cli repo start",
    "tsc": "tsc",
    "lint": "backstage-cli repo lint"
  }
}
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/app"
cat > "$APP/packages/app/package.json" <<'ASTRONA_FILE_EOF'
{
  "name": "app",
  "version": "0.0.0",
  "private": true,
  "dependencies": {
    "@backstage/app-defaults": "^1.5.0",
    "@backstage/catalog-model": "^1.7.0",
    "@backstage/core-app-api": "^1.15.0",
    "@backstage/core-components": "^0.15.0",
    "@backstage/core-plugin-api": "^1.10.0",
    "@backstage/plugin-catalog": "^1.25.0",
    "@backstage/plugin-catalog-react": "^1.14.0",
    "@internal/plugin-scout-status": "workspace:^",
    "@material-ui/core": "^4.12.2",
    "@material-ui/icons": "^4.9.1",
    "react": "^18.0.2",
    "react-dom": "^18.0.2",
    "react-router-dom": "^6.3.0",
    "react-use": "^17.2.4"
  }
}
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/app/src"
cat > "$APP/packages/app/src/App.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import { Navigate, Route } from 'react-router-dom';
import { createApp } from '@backstage/app-defaults';
import { FlatRoutes } from '@backstage/core-app-api';
import { CatalogIndexPage } from '@backstage/plugin-catalog';
import { ScoutStatusPage } from '@internal/plugin-scout-status';
import { Root } from './components/Root';

const app = createApp({});

const routes = (
  <FlatRoutes>
    <Route path="/" element={<Navigate to="catalog" />} />
    <Route path="/catalog" element={<CatalogIndexPage />} />
    <Route path="/scout-status" element={<ScoutStatusPage />} />
  </FlatRoutes>
);

export default app.createRoot(
  <>
    <Root>{routes}</Root>
  </>,
);
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/app/src/components/Root"
cat > "$APP/packages/app/src/components/Root/Root.tsx" <<'ASTRONA_FILE_EOF'
import React, { PropsWithChildren } from 'react';
import {
  Sidebar,
  SidebarGroup,
  SidebarItem,
  SidebarPage,
  SidebarSpace,
} from '@backstage/core-components';
import HomeIcon from '@material-ui/icons/Home';
import ExtensionIcon from '@material-ui/icons/Extension';

export const Root = ({ children }: PropsWithChildren<{}>) => (
  <SidebarPage>
    <Sidebar>
      <SidebarGroup label="Menu">
        <SidebarItem icon={HomeIcon} to="catalog" text="Home" />
        <SidebarItem icon={ExtensionIcon} to="scout-status" text="Scout status" />
      </SidebarGroup>
      <SidebarSpace />
    </Sidebar>
    {children}
  </SidebarPage>
);
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/app/src/components/Root"
cat > "$APP/packages/app/src/components/Root/index.ts" <<'ASTRONA_FILE_EOF'
export { Root } from './Root';
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/backend"
cat > "$APP/packages/backend/package.json" <<'ASTRONA_FILE_EOF'
{
  "name": "backend",
  "version": "0.0.0",
  "private": true,
  "dependencies": {
    "@backstage/backend-defaults": "^0.5.0",
    "@backstage/plugin-catalog-backend": "^1.27.0"
  }
}
ASTRONA_FILE_EOF
mkdir -p "$APP/packages/backend/src"
cat > "$APP/packages/backend/src/index.ts" <<'ASTRONA_FILE_EOF'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-catalog-backend'));

backend.start();
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status"
cat > "$APP/plugins/scout-status/package.json" <<'ASTRONA_FILE_EOF'
{
  "name": "@internal/plugin-scout-status",
  "version": "0.1.0",
  "main": "src/index.ts",
  "private": true,
  "dependencies": {
    "@backstage/catalog-model": "^1.7.0",
    "@backstage/core-components": "^0.15.0",
    "@backstage/core-plugin-api": "^1.10.0",
    "@backstage/plugin-catalog-react": "^1.14.0",
    "react-use": "^17.2.4"
  }
}
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/OutpostStatusCard"
cat > "$APP/plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import { Progress, ResponseErrorPanel } from '@backstage/core-components';
import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { stringifyEntityRef } from '@backstage/catalog-model';

export const OutpostStatusCard = () => {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const response = await catalogApi.getEntities({
      filter: { kind: 'Component', 'spec.type': 'outpost' },
    });
    return response.items;
  }, [catalogApi]);

  const outposts = value ?? [];

  return (
    <div aria-live="polite" aria-busy={loading}>
      {loading && <Progress />}
      {error && <ResponseErrorPanel error={error} />}
      {!loading && !error && outposts.length === 0 && (
        <p>No outposts found in the catalog.</p>
      )}
      {!loading && !error && outposts.length > 0 && (
        <ul aria-label="Outposts">
          {outposts.map(entity => (
            <li key={stringifyEntityRef(entity)}>
              {entity.metadata.title ?? entity.metadata.name}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/OutpostStatusCard"
cat > "$APP/plugins/scout-status/src/components/OutpostStatusCard/index.ts" <<'ASTRONA_FILE_EOF'
export { OutpostStatusCard } from './OutpostStatusCard';
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/ScoutStatusPage"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage/ScoutStatusPage.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import { Content, Header, Page } from '@backstage/core-components';
import { OutpostStatusCard } from '../OutpostStatusCard';

export const ScoutStatusPage = () => (
  <Page themeId="tool">
    <Header title="Scout status" />
    <Content>
      <OutpostStatusCard />
    </Content>
  </Page>
);
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/ScoutStatusPage"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage/index.ts" <<'ASTRONA_FILE_EOF'
export { ScoutStatusPage } from './ScoutStatusPage';
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src"
cat > "$APP/plugins/scout-status/src/index.ts" <<'ASTRONA_FILE_EOF'
export { ScoutStatusPage } from './components/ScoutStatusPage';
ASTRONA_FILE_EOF

echo "[setup] Wrote the Backstage app to $APP"
