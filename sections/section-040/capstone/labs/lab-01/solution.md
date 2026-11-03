# Solution

Edit the files in `/home/candidate/backstage-app` with `nano` or `vim`. Run `astrona submit` after each step to see which checks now pass.

## Step 1

Make the card and the list use v4 imports, `InfoCard` and the `Grid` layout.

Replace `src/components/ScoutStatusCard.tsx` with:

```tsx
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
```

Replace `src/components/ScoutList.tsx` with:

```tsx
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
```

Run `astrona submit`.

## Step 2

Create and register the theme.

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

Use status components with text and theme tokens.

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

## Step 4

Name the icon button.

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

## Step 5

Show loading, error and empty states and wire the refresh button.

Replace `src/components/ScoutStatusPage.tsx` with:

```tsx
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
```

Run `astrona submit`.

