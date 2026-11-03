#!/usr/bin/env bash
# Bootstrap: creates the scout-status Backstage-style repository in /home/candidate/backstage-app with working configuration, schema and plugin code. No task.
set -eu

sudo mkdir -p /home/candidate
sudo chown -R "$(whoami):$(whoami)" /home/candidate

APP=/home/candidate/backstage-app
rm -rf "$APP"
mkdir -p "$APP"

mkdir -p "$(dirname "$APP/package.json")"
cat > "$APP/package.json" <<'EOF_FILE'
{
  "name": "root",
  "private": true,
  "workspaces": ["packages/*", "plugins/*"]
}
EOF_FILE

mkdir -p "$(dirname "$APP/app-config.yaml")"
cat > "$APP/app-config.yaml" <<'EOF_FILE'
app:
  title: Starfleet Developer Portal
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

scoutStatus:
  apiUrl: ${SCOUT_API_URL:-http://localhost:9090/status}
  apiToken: ${SCOUT_API_TOKEN}
  refreshSeconds: 30
  title: Scout Status
EOF_FILE

mkdir -p "$(dirname "$APP/app-config.production.yaml")"
cat > "$APP/app-config.production.yaml" <<'EOF_FILE'
app:
  baseUrl: https://portal.starfleet.example

scoutStatus:
  refreshSeconds: 60
EOF_FILE

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'EOF_FILE'
import React from 'react';
import { createApp } from '@backstage/app-defaults';

const app = createApp({});

export default app.createRoot(<div>Starfleet Developer Portal</div>);
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'EOF_FILE'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@internal/backstage-plugin-scout-status-backend'));

backend.start();
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status/package.json")"
cat > "$APP/plugins/scout-status/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-scout-status",
  "version": "0.1.0",
  "main": "src/index.ts",
  "files": ["dist", "config.d.ts"],
  "configSchema": "config.d.ts",
  "dependencies": {
    "@backstage/core-plugin-api": "^1.10.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status/config.d.ts")"
cat > "$APP/plugins/scout-status/config.d.ts" <<'EOF_FILE'
export interface Config {
  scoutStatus?: {
    /** Base URL of the scout status API. */
    apiUrl: string;
    /**
     * Token for the scout status API.
     * @visibility secret
     */
    apiToken: string;
    /**
     * Seconds between refreshes.
     * @visibility frontend
     */
    refreshSeconds?: number;
    /**
     * Card title.
     * @visibility frontend
     */
    title?: string;
  };
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status/src/index.ts")"
cat > "$APP/plugins/scout-status/src/index.ts" <<'EOF_FILE'
export { ScoutStatusCard } from './components/ScoutStatusCard';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status/src/components/ScoutStatusCard.tsx")"
cat > "$APP/plugins/scout-status/src/components/ScoutStatusCard.tsx" <<'EOF_FILE'
import React from 'react';
import { configApiRef, useApi } from '@backstage/core-plugin-api';

export const ScoutStatusCard = () => {
  const config = useApi(configApiRef);
  const title = config.getOptionalString('scoutStatus.title') ?? 'Scout Status';
  const refreshSeconds =
    config.getOptionalNumber('scoutStatus.refreshSeconds') ?? 30;
  return (
    <div>
      {title} refreshes every {refreshSeconds}s
    </div>
  );
};
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/package.json")"
cat > "$APP/plugins/scout-status-backend/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-scout-status-backend",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/src/index.ts")"
cat > "$APP/plugins/scout-status-backend/src/index.ts" <<'EOF_FILE'
export { scoutStatusPlugin as default } from './plugin';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/scout-status-backend/src/plugin.ts")"
cat > "$APP/plugins/scout-status-backend/src/plugin.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';

export const scoutStatusPlugin = createBackendPlugin({
  pluginId: 'scout-status',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
        config: coreServices.rootConfig,
      },
      async init({ logger, config }) {
        const apiUrl = config.getString('scoutStatus.apiUrl');
        const apiToken = config.getString('scoutStatus.apiToken');
        const refreshSeconds =
          config.getOptionalNumber('scoutStatus.refreshSeconds') ?? 30;
        logger.info(`scout-status polls ${apiUrl} every ${refreshSeconds}s`);
        logger.debug(`token length ${apiToken.length}`);
      },
    });
  },
});
EOF_FILE

sudo chown -R "$(whoami):$(whoami)" /home/candidate
