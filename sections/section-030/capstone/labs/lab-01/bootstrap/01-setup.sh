#!/usr/bin/env bash
# Bootstrap for React Changes In A Backstage App Capstone: writes the starting Backstage app with deliberate gaps.
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
import { Root } from './components/Root';

const app = createApp({});

const routes = (
  <FlatRoutes>
    <Route path="/" element={<Navigate to="catalog" />} />
    <Route path="/catalog" element={<CatalogIndexPage />} />
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
mkdir -p "$APP/plugins/scout-status/src/components/FleetPage"
cat > "$APP/plugins/scout-status/src/components/FleetPage/FleetPage.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import { Content, Header, Page } from '@backstage/core-components';
import { FleetPanel } from '../FleetPanel';

export const FleetPage = () => (
  <Page themeId="tool">
    <Header title="Fleet status" />
    <Content>
      <FleetPanel />
    </Content>
  </Page>
);
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetPage"
cat > "$APP/plugins/scout-status/src/components/FleetPage/index.ts" <<'ASTRONA_FILE_EOF'
export { FleetPage } from './FleetPage';
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetPanel"
cat > "$APP/plugins/scout-status/src/components/FleetPanel/FleetPanel.tsx" <<'ASTRONA_FILE_EOF'
import React, { useState } from 'react';
import { Entity } from '@backstage/catalog-model';
import { FleetRow } from '../FleetRow';

// Loads data while it renders, has no loading or error state and keys by position.
export const FleetPanel = () => {
  const [ships, setShips] = useState<Entity[]>([]);

  fetch('/api/catalog/entities')
    .then(response => response.json())
    .then(items => setShips(items));

  return (
    <ul>
      {ships.map((entity, index) => (
        <FleetRow
          key={index}
          name={entity.metadata.name}
          owner={entity.spec?.owner as string}
        />
      ))}
    </ul>
  );
};
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetPanel"
cat > "$APP/plugins/scout-status/src/components/FleetPanel/index.ts" <<'ASTRONA_FILE_EOF'
export { FleetPanel } from './FleetPanel';
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetRow"
cat > "$APP/plugins/scout-status/src/components/FleetRow/FleetRow.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';

export interface FleetRowProps {
  name: string;
  owner: string;
}

export const FleetRow = ({ name, owner }: FleetRowProps) => (
  <li>
    {name}: {owner.toUpperCase()}
  </li>
);
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetRow"
cat > "$APP/plugins/scout-status/src/components/FleetRow/index.ts" <<'ASTRONA_FILE_EOF'
export { FleetRow } from './FleetRow';
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src"
cat > "$APP/plugins/scout-status/src/index.ts" <<'ASTRONA_FILE_EOF'
export { FleetPage } from './components/FleetPage';
ASTRONA_FILE_EOF

echo "[setup] Wrote the Backstage app to $APP"
