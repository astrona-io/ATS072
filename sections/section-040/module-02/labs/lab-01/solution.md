# Solution

Edit the files in `/home/candidate/backstage-app` with `nano` or `vim`. Run `astrona submit` after each step to see which checks now pass.

## Step 1

Create the theme.

Replace `packages/app/src/theme/scoutTheme.ts` with:

```ts
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
```

Run `astrona submit`.

## Step 2

Register it in the app.

Replace `packages/app/src/App.tsx` with:

```tsx
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
```

Run `astrona submit`.

## Step 3

Show status with a Backstage status component and a text label.

Replace `src/components/ScoutStatusBadge.tsx` with:

```tsx
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
```

Run `astrona submit`.

## Step 4

Take colours and spacing from the theme.

Replace `src/components/ScoutPanel.tsx` with:

```tsx
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
```

Run `astrona submit`.

## Step 5

Name the icon-only button.

Replace `src/components/ScoutToolbar.tsx` with:

```tsx
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
```

Run `astrona submit`.

Check that no colour literal is left:

```sh
grep -rnE "#[0-9a-fA-F]{3,8}" plugins
```

The command prints nothing when the plugin is clean. The `#1f6feb` value belongs in the theme file under `packages/app`, which this search does not cover.
