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
mkdir -p "$APP/plugins/scout-status/src/components/CrewCounter"
cat > "$APP/plugins/scout-status/src/components/CrewCounter/CrewCounter.tsx" <<'ASTRONA_FILE_EOF'
import React, { useEffect, useState } from 'react';

export const CrewCounter = ({ outpost }: { outpost: string }) => {
  const [count, setCount] = useState(0);

  useEffect(() => {
    document.title = `${outpost}: ${count} on duty`;
  }, [outpost, count]);

  return (
    <button type="button" onClick={() => setCount(count + 1)}>
      On duty at {outpost}: {count}
    </button>
  );
};
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/OutpostCard"
cat > "$APP/plugins/scout-status/src/components/OutpostCard/OutpostCard.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';

export interface OutpostCardProps {
  name: string;
  crew?: number;
}

export const OutpostCard = ({ name, crew }: OutpostCardProps) => {
  return (
    <div>
      <h3>{name}</h3>
      <p>{crew === undefined ? 'Crew not recorded' : `Crew: ${crew}`}</p>
    </div>
  );
};
ASTRONA_FILE_EOF
mkdir -p "$APP/plugins/scout-status/src/components/ScoutStatusPage"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage/ScoutStatusPage.tsx" <<'ASTRONA_FILE_EOF'
import React from 'react';
import { Content, Header, Page } from '@backstage/core-components';
import { OutpostCard } from '../OutpostCard';
import { CrewCounter } from '../CrewCounter';

export const ScoutStatusPage = () => (
  <Page themeId="tool">
    <Header title="Scout status" />
    <Content>
      <OutpostCard name="outpost-alpha" crew={12} />
      <CrewCounter outpost="outpost-alpha" />
    </Content>
  </Page>
);
ASTRONA_FILE_EOF

echo "[solution] Applied."
