#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`: writes the corrected configuration, schema, package file, backend plugin and card.
set -eu

APP=/home/candidate/backstage-app

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

