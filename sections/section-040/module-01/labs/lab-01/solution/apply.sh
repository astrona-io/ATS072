#!/usr/bin/env bash
# Applies the reference solution: replaces the broken files with the working versions.
# Used only by `astrona test`.
set -eu

APP=/home/candidate/backstage-app
sudo mkdir -p "$APP"
sudo chown -R "$(whoami):$(whoami)" /home/candidate

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

sudo chown -R "$(whoami):$(whoami)" /home/candidate
echo "backstage-app written to $APP"
