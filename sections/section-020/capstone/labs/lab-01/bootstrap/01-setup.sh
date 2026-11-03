#!/usr/bin/env bash
# Bootstrap: creates the probe-report repository with configuration, schema, extension and permission mistakes across the whole customization.
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
  title: Outpost Developer Portal
  baseUrl: http://localhost:3000
  extensions:
    - page:probe-report:
        config:
          path: /probe-report

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

probeReport:
  endpoint: http://localhost:9191/report
  apiKey: probe-key-77
  refreshSeconds: 45
  annotation: outpost.example/probe-report
EOF_FILE

mkdir -p "$(dirname "$APP/packages/app/src/App.tsx")"
cat > "$APP/packages/app/src/App.tsx" <<'EOF_FILE'
import React from 'react';
import { createApp } from '@backstage/frontend-defaults';

const app = createApp();

export default app.createRoot();
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'EOF_FILE'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-catalog-backend'));
// backend.add(import('@internal/backstage-plugin-catalog-backend-module-probe'));
backend.add(import('@backstage/plugin-permission-backend'));
backend.add(import('@internal/backstage-plugin-probe-report-backend'));
// backend.add(import('@internal/backstage-plugin-permission-backend-module-outpost-policy'));

backend.start();
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/package.json")"
cat > "$APP/plugins/catalog-backend-module-probe/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-catalog-backend-module-probe",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.0.0",
    "@backstage/plugin-catalog-node": "^1.17.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-outpost-policy/package.json")"
cat > "$APP/plugins/permission-backend-module-outpost-policy/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-permission-backend-module-outpost-policy",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0",
    "@backstage/plugin-permission-node": "^0.10.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/src/ProbeProcessor.ts")"
cat > "$APP/plugins/catalog-backend-module-probe/src/ProbeProcessor.ts" <<'EOF_FILE'
import type { Entity } from '@backstage/catalog-model';
import type { CatalogProcessor } from '@backstage/plugin-catalog-node';
import type { LoggerService } from '@backstage/backend-plugin-api';

export class ProbeProcessor implements CatalogProcessor {
  constructor(
    private readonly logger: LoggerService,
    private readonly annotation: string,
  ) {}

  getProcessorName(): string {
    return 'ProbeProcessor';
  }

  async preProcessEntity(entity: Entity): Promise<Entity> {
    if (!entity.metadata.annotations?.[this.annotation]) {
      this.logger.debug(`${entity.metadata.name} has no ${this.annotation}`);
    }
    return entity;
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/src/module.ts")"
cat > "$APP/plugins/catalog-backend-module-probe/src/module.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';

export const catalogModuleProbeProcessor = createBackendModule({
  pluginId: 'probe-report',
  moduleId: 'probe-processor',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
      },
      async init({ logger }) {
        logger.info('probe-processor started');
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/src/index.ts")"
cat > "$APP/plugins/catalog-backend-module-probe/src/index.ts" <<'EOF_FILE'
export { catalogModuleProbeProcessor } from './module';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-outpost-policy/src/policy.ts")"
cat > "$APP/plugins/permission-backend-module-outpost-policy/src/policy.ts" <<'EOF_FILE'
import { AuthorizeResult } from '@backstage/plugin-permission-common';
import type { PolicyDecision } from '@backstage/plugin-permission-common';
import type {
  PermissionPolicy,
  PolicyQuery,
  PolicyQueryUser,
} from '@backstage/plugin-permission-node';

export class OutpostPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: PolicyQueryUser,
  ): Promise<PolicyDecision> {
    return { result: AuthorizeResult.ALLOW };
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-outpost-policy/src/module.ts")"
cat > "$APP/plugins/permission-backend-module-outpost-policy/src/module.ts" <<'EOF_FILE'
import { createBackendModule } from '@backstage/backend-plugin-api';
import { policyExtensionPoint } from '@backstage/plugin-permission-node/alpha';
import { OutpostPolicy } from './policy';

export const permissionModuleOutpostPolicy = createBackendModule({
  pluginId: 'permission',
  moduleId: 'outpost-policy',
  register(env) {
    env.registerInit({
      deps: { policy: policyExtensionPoint },
      async init({ policy }) {
        // TODO: register the policy
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-outpost-policy/src/index.ts")"
cat > "$APP/plugins/permission-backend-module-outpost-policy/src/index.ts" <<'EOF_FILE'
export { permissionModuleOutpostPolicy as default } from './module';
EOF_FILE

mkdir -p "$(dirname "$APP/app-config.production.yaml")"
cat > "$APP/app-config.production.yaml" <<'EOF_FILE'
probeReport:
  apiKey: probe-key-77
  refreshSeconds: 120
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/package.json")"
cat > "$APP/packages/backend/package.json" <<'EOF_FILE'
{
  "name": "backend",
  "version": "0.1.0",
  "scripts": {
    "start": "backstage-cli package start --config ../../app-config.yaml",
    "start:production": "node dist/index.cjs --config ../../app-config.production.yaml"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/package.json")"
cat > "$APP/plugins/probe-report/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-probe-report",
  "version": "0.1.0",
  "main": "src/index.ts",
  "files": ["dist"],
  "dependencies": {
    "@backstage/core-plugin-api": "^1.10.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/config.d.ts")"
cat > "$APP/plugins/probe-report/config.d.ts" <<'EOF_FILE'
export interface Config {
  probeReport?: {
    /** Base URL of the probe report API. */
    endpoint: string;
    /**
     * Key for the probe report API.
     */
    apiKey: string;
    /**
     * Seconds between refreshes.
     */
    refreshSeconds?: number;
    /** Entity annotation that the catalog processor checks. */
    annotation?: string;
  };
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/src/index.ts")"
cat > "$APP/plugins/probe-report/src/index.ts" <<'EOF_FILE'
export { ProbeReportCard } from './components/ProbeReportCard';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/src/components/ProbeReportCard.tsx")"
cat > "$APP/plugins/probe-report/src/components/ProbeReportCard.tsx" <<'EOF_FILE'
import React from 'react';
import { configApiRef, useApi } from '@backstage/core-plugin-api';

export const ProbeReportCard = () => {
  const config = useApi(configApiRef);
  const apiKey = config.getString('probeReport.apiKey');
  const refreshSeconds =
    config.getOptionalNumber('probeReport.refreshSeconds') ?? 60;
  return <div>Probe report refreshes every {refreshSeconds}s</div>;
};
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report-backend/package.json")"
cat > "$APP/plugins/probe-report-backend/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-probe-report-backend",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report-backend/src/index.ts")"
cat > "$APP/plugins/probe-report-backend/src/index.ts" <<'EOF_FILE'
export { probeReportPlugin as default } from './plugin';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report-backend/src/plugin.ts")"
cat > "$APP/plugins/probe-report-backend/src/plugin.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';

export const probeReportPlugin = createBackendPlugin({
  pluginId: 'probe-report',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
      },
      async init({ logger }) {
        const endpoint = process.env.PROBE_ENDPOINT ?? 'http://localhost:9191/report';
        const apiKey = process.env.PROBE_API_KEY ?? '';
        const refreshSeconds = 60;
        logger.info(`probe-report polls ${endpoint} every ${refreshSeconds}s`);
        logger.debug(`key length ${apiKey.length}`);
      },
    });
  },
});
EOF_FILE

sudo chown -R "$(whoami):$(whoami)" /home/candidate
