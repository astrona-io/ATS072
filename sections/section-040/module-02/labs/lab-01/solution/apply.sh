#!/usr/bin/env bash
# Applies the reference solution: replaces the broken files with the working versions.
# Used only by `astrona test`.
set -eu

APP=/home/candidate/backstage-app
sudo mkdir -p "$APP"
sudo chown -R "$(whoami):$(whoami)" /home/candidate

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

sudo chown -R "$(whoami):$(whoami)" /home/candidate
echo "backstage-app written to $APP"
