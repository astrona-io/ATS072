# Solution

Edit the files in `/home/candidate/backstage-app` with `nano` or `vim`. Run `astrona submit` after each step to see which checks now pass.

## Step 1

Change the imports of the card, switch to `InfoCard` and keep the theme-based spacing.

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

Run `astrona submit`.

## Step 2

Use only the v4 `Grid` in the list and remove the `Box` with the `sx` prop.

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

Check that nothing from v5 is left:

```sh
grep -rn "@mui" plugins/scout-status
```

The command prints nothing when the plugin is clean.
