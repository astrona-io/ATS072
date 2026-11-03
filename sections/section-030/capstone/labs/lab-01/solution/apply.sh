#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -eu

APP=/home/candidate/backstage-app

mkdir -p "$APP/packages/app/src"
cat > "$APP/packages/app/src/App.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import { Navigate, Route } from 'react-router-dom';
import { createApp } from '@backstage/app-defaults';
import { FlatRoutes } from '@backstage/core-app-api';
import { CatalogIndexPage } from '@backstage/plugin-catalog';
import { FleetPage } from '@internal/plugin-scout-status';
import { Root } from './components/Root';

const app = createApp({});

const routes = (
  <FlatRoutes>
    <Route path="/" element={<Navigate to="catalog" />} />
    <Route path="/catalog" element={<CatalogIndexPage />} />
    <Route path="/fleet" element={<FleetPage />} />
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
        <SidebarItem icon={ExtensionIcon} to="fleet" text="Fleet status" />
      </SidebarGroup>
      <SidebarSpace />
    </Sidebar>
    {children}
  </SidebarPage>
);
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetPanel"
cat > "$APP/plugins/scout-status/src/components/FleetPanel/FleetPanel.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import { Progress, ResponseErrorPanel } from '@backstage/core-components';
import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { stringifyEntityRef } from '@backstage/catalog-model';
import { FleetRow } from '../FleetRow';

export const FleetPanel = () => {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const response = await catalogApi.getEntities({
      filter: { kind: 'Component' },
    });
    return response.items;
  }, [catalogApi]);

  const ships = value ?? [];

  return (
    <div aria-live="polite" aria-busy={loading}>
      {loading && <Progress />}
      {error && <ResponseErrorPanel error={error} />}
      {!loading && !error && ships.length === 0 && (
        <p>No ships found in the catalog.</p>
      )}
      {!loading && !error && ships.length > 0 && (
        <ul aria-label="Fleet">
          {ships.map(entity => (
            <FleetRow
              key={stringifyEntityRef(entity)}
              name={entity.metadata.name}
              owner={
                typeof entity.spec?.owner === 'string'
                  ? entity.spec.owner
                  : undefined
              }
            />
          ))}
        </ul>
      )}
    </div>
  );
};
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/FleetRow"
cat > "$APP/plugins/scout-status/src/components/FleetRow/FleetRow.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';

export interface FleetRowProps {
  name: string;
  owner?: string;
}

export const FleetRow = ({ name, owner }: FleetRowProps) => (
  <li>
    {name}: {owner ?? 'Owner not recorded'}
  </li>
);
ASTRONA_FILE_EOF

echo "[solution] Applied."
