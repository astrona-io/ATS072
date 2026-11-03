#!/usr/bin/env bash
# Bootstrap: writes the working scout-status project. No task, no grading.
set -eu

APP=/home/candidate/backstage-app
sudo mkdir -p "$APP"
sudo chown -R "$(whoami):$(whoami)" /home/candidate

mkdir -p "$(dirname "$APP/app-config.yaml")"
cat > "$APP/app-config.yaml" <<'EOF'
app:
  title: Starfleet Outpost Portal
  baseUrl: http://localhost:3000

organization:
  name: Starfleet

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

catalog:
  locations: []
EOF

mkdir -p "$(dirname "$APP/package.json")"
cat > "$APP/package.json" <<'EOF'
{
  "name": "root",
  "private": true,
  "workspaces": {
    "packages": ["packages/*", "plugins/*"]
  }
}
EOF

mkdir -p "$(dirname "$APP/packages/app/package.json")"
cat > "$APP/packages/app/package.json" <<'EOF'
{
  "name": "app",
  "version": "0.0.0",
  "private": true,
  "dependencies": {
    "@backstage/app-defaults": "^1.5.0",
    "@backstage/core-app-api": "^1.15.0",
    "@backstage/core-components": "^0.17.0",
    "@backstage/theme": "^0.6.0",
    "@internal/plugin-scout-status": "*",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-router-dom": "^6.0.0"
  }
}
EOF

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'EOF'
import React from 'react';
import { Route } from 'react-router-dom';
import { createApp } from '@backstage/app-defaults';
import { FlatRoutes } from '@backstage/core-app-api';
import { UnifiedThemeProvider } from '@backstage/theme';
import { ScoutStatusPage } from '@internal/plugin-scout-status';
import { scoutTheme } from './theme/scoutTheme';

const app = createApp({
  themes: [
    {
      id: 'scout-light',
      title: 'Scout Light',
      variant: 'light',
      Provider: ({ children }) => (
        <UnifiedThemeProvider theme={scoutTheme} children={children} />
      ),
    },
  ],
});

const AppRouter = app.getRouter();

const routes = (
  <FlatRoutes>
    <Route path="/scout-status" element={<ScoutStatusPage />} />
  </FlatRoutes>
);

export default app.createRoot(<AppRouter>{routes}</AppRouter>);
EOF

mkdir -p "$(dirname "$APP/packages/app/src/theme/scoutTheme.ts")"
cat > "$APP/packages/app/src/theme/scoutTheme.ts" <<'EOF'
import { createUnifiedTheme, palettes } from '@backstage/theme';

export const scoutTheme = createUnifiedTheme({
  palette: {
    ...palettes.light,
    primary: {
      main: '#1f6feb',
    },
  },
  defaultPageTheme: 'home',
});
EOF

mkdir -p "$(dirname "$APP/packages/backend/package.json")"
cat > "$APP/packages/backend/package.json" <<'EOF'
{
  "name": "backend",
  "version": "0.0.0",
  "private": true,
  "dependencies": {
    "@backstage/backend-defaults": "^0.8.0",
    "@backstage/plugin-app-backend": "^0.5.0",
    "@backstage/plugin-catalog-backend": "^1.30.0"
  }
}
EOF

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'EOF'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();
backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-catalog-backend'));
backend.start();
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/package.json")"
cat > "$APP/plugins/scout-status/package.json" <<'EOF'
{
  "name": "@internal/plugin-scout-status",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/core-components": "^0.17.0",
    "@backstage/core-plugin-api": "^1.10.0",
    "@backstage/errors": "^1.2.0",
    "@material-ui/core": "^4.12.4",
    "@material-ui/icons": "^4.11.3",
    "react-use": "^17.5.0"
  },
  "peerDependencies": {
    "react": "^17.0.0 || ^18.0.0",
    "react-router-dom": "^6.0.0"
  }
}
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutList.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutList.tsx" <<'EOF'
import React from 'react';
import Grid from '@material-ui/core/Grid';
import { Scout } from '../types';
import { ScoutStatusCard } from './ScoutStatusCard';

export const ScoutList = (props: { scouts: Scout[] }) => (
  <Grid container spacing={3}>
    {props.scouts.map(scout => (
      <Grid item xs={12} md={6} key={scout.name}>
        <ScoutStatusCard scout={scout} />
      </Grid>
    ))}
  </Grid>
);
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutPanel.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutPanel.tsx" <<'EOF'
import React from 'react';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles(theme => ({
  root: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: theme.spacing(1, 2),
    marginBottom: theme.spacing(2),
    border: `1px solid ${theme.palette.divider}`,
    color: theme.palette.text.primary,
  },
}));

export const ScoutPanel = (props: { children: React.ReactNode }) => {
  const classes = useStyles();
  return <div className={classes.root}>{props.children}</div>;
};
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusBadge.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusBadge.tsx" <<'EOF'
import React from 'react';
import {
  StatusError,
  StatusOK,
  StatusPending,
  StatusWarning,
} from '@backstage/core-components';
import { ScoutState } from '../types';

export const ScoutStatusBadge = (props: { state: ScoutState; name: string }) => {
  const { state, name } = props;
  switch (state) {
    case 'ok':
      return <StatusOK>{name} is operational</StatusOK>;
    case 'degraded':
      return <StatusWarning>{name} is degraded</StatusWarning>;
    case 'down':
      return <StatusError>{name} is down</StatusError>;
    default:
      return <StatusPending>{name} status is unknown</StatusPending>;
  }
};
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusCard.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusCard.tsx" <<'EOF'
import React from 'react';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';
import { InfoCard } from '@backstage/core-components';
import { Scout } from '../types';
import { ScoutStatusBadge } from './ScoutStatusBadge';

const useStyles = makeStyles(theme => ({
  detail: {
    margin: theme.spacing(2, 0),
  },
}));

export const ScoutStatusCard = (props: { scout: Scout }) => {
  const classes = useStyles();
  const { scout } = props;
  return (
    <InfoCard title={scout.name}>
      <ScoutStatusBadge state={scout.state} name={scout.name} />
      <Typography variant="body2" className={classes.detail}>
        Last report: {scout.lastReport}
      </Typography>
      <Button
        variant="outlined"
        color="primary"
        href={`/catalog/default/component/${scout.name}`}
      >
        Open in catalog
      </Button>
    </InfoCard>
  );
};
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusPage.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusPage.tsx" <<'EOF'
import React from 'react';
import {
  Content,
  EmptyState,
  Header,
  Page,
  Progress,
  ResponseErrorPanel,
} from '@backstage/core-components';
import { useScoutStatus } from '../hooks/useScoutStatus';
import { ScoutList } from './ScoutList';
import { ScoutToolbar } from './ScoutToolbar';

export const ScoutStatusPage = () => {
  const { value, loading, error, retry } = useScoutStatus();

  let body: React.ReactNode;
  if (loading) {
    body = <Progress />;
  } else if (error) {
    body = <ResponseErrorPanel error={error} />;
  } else if (!value || value.length === 0) {
    body = (
      <EmptyState
        missing="data"
        title="No scouts reported"
        description="No scout has sent a status yet."
      />
    );
  } else {
    body = <ScoutList scouts={value} />;
  }

  return (
    <Page themeId="tool">
      <Header title="Scout status" subtitle="Scouts of the outpost" />
      <Content>
        <ScoutToolbar onRefresh={retry} />
        {body}
      </Content>
    </Page>
  );
};
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutToolbar.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutToolbar.tsx" <<'EOF'
import React from 'react';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import RefreshIcon from '@material-ui/icons/Refresh';
import { ScoutPanel } from './ScoutPanel';

export const ScoutToolbar = (props: { onRefresh: () => void }) => (
  <ScoutPanel>
    <Typography variant="subtitle1">Scouts in the outpost</Typography>
    <IconButton aria-label="Refresh scout status" onClick={props.onRefresh}>
      <RefreshIcon />
    </IconButton>
  </ScoutPanel>
);
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/hooks/useScoutStatus.ts")"
cat > "$APP/plugins/scout-status/src/hooks/useScoutStatus.ts" <<'EOF'
import useAsyncRetry from 'react-use/lib/useAsyncRetry';
import {
  discoveryApiRef,
  fetchApiRef,
  useApi,
} from '@backstage/core-plugin-api';
import { ResponseError } from '@backstage/errors';
import { Scout } from '../types';

export function useScoutStatus() {
  const discoveryApi = useApi(discoveryApiRef);
  const fetchApi = useApi(fetchApiRef);

  return useAsyncRetry(async () => {
    const baseUrl = await discoveryApi.getBaseUrl('scout-status');
    const response = await fetchApi.fetch(`${baseUrl}/scouts`);
    if (!response.ok) {
      throw await ResponseError.fromResponse(response);
    }
    return (await response.json()) as Scout[];
  }, []);
}
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/index.ts")"
cat > "$APP/plugins/scout-status/src/index.ts" <<'EOF'
export { scoutStatusPlugin, ScoutStatusPage } from './plugin';
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/plugin.ts")"
cat > "$APP/plugins/scout-status/src/plugin.ts" <<'EOF'
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
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/routes.ts")"
cat > "$APP/plugins/scout-status/src/routes.ts" <<'EOF'
import { createRouteRef } from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({ id: 'scout-status' });
EOF

mkdir -p "$(dirname "$APP/plugins/scout-status/src/types.ts")"
cat > "$APP/plugins/scout-status/src/types.ts" <<'EOF'
export type ScoutState = 'ok' | 'degraded' | 'down' | 'unknown';

export type Scout = {
  name: string;
  state: ScoutState;
  lastReport: string;
};
EOF

sudo chown -R "$(whoami):$(whoami)" /home/candidate
echo "backstage-app written to $APP"
