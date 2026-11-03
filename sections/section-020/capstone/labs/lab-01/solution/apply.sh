#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`: writes every corrected file.
set -eu

APP=/home/candidate/backstage-app

mkdir -p "$(dirname "$APP/app-config.yaml")"
cat > "$APP/app-config.yaml" <<'EOF_FILE'
app:
  title: Outpost Developer Portal
  baseUrl: http://localhost:3000
  extensions:
    - page:probe-report:
        config:
          path: /outpost-probes

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

probeReport:
  endpoint: ${PROBE_ENDPOINT:-http://localhost:9191/report}
  apiKey: ${PROBE_API_KEY}
  refreshSeconds: 45
  annotation: outpost.example/probe-report
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'EOF_FILE'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(import('@internal/backstage-plugin-catalog-backend-module-probe'));
backend.add(import('@backstage/plugin-permission-backend'));
backend.add(import('@internal/backstage-plugin-probe-report-backend'));
backend.add(import('@internal/backstage-plugin-permission-backend-module-outpost-policy'));

backend.start();
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/package.json")"
cat > "$APP/plugins/catalog-backend-module-probe/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-catalog-backend-module-probe",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0",
    "@backstage/plugin-catalog-node": "^1.17.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/src/module.ts")"
cat > "$APP/plugins/catalog-backend-module-probe/src/module.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';
import { catalogProcessingExtensionPoint } from '@backstage/plugin-catalog-node';
import { ProbeProcessor } from './ProbeProcessor';

export const catalogModuleProbeProcessor = createBackendModule({
  pluginId: 'catalog',
  moduleId: 'probe-processor',
  register(env) {
    env.registerInit({
      deps: {
        catalog: catalogProcessingExtensionPoint,
        logger: coreServices.logger,
        config: coreServices.rootConfig,
      },
      async init({ catalog, logger, config }) {
        const annotation =
          config.getOptionalString('probeReport.annotation') ??
          'outpost.example/probe-report';
        catalog.addProcessor(new ProbeProcessor(logger, annotation));
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-probe/src/index.ts")"
cat > "$APP/plugins/catalog-backend-module-probe/src/index.ts" <<'EOF_FILE'
export { catalogModuleProbeProcessor as default } from './module';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-outpost-policy/src/policy.ts")"
cat > "$APP/plugins/permission-backend-module-outpost-policy/src/policy.ts" <<'EOF_FILE'
import {
  AuthorizeResult,
  isPermission,
} from '@backstage/plugin-permission-common';
import type { PolicyDecision } from '@backstage/plugin-permission-common';
import type {
  PermissionPolicy,
  PolicyQuery,
  PolicyQueryUser,
} from '@backstage/plugin-permission-node';
import { catalogEntityDeletePermission } from '@backstage/plugin-catalog-common/alpha';

export class OutpostPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: PolicyQueryUser,
  ): Promise<PolicyDecision> {
    if (isPermission(request.permission, catalogEntityDeletePermission)) {
      const refs = user?.info.ownershipEntityRefs ?? [];
      if (refs.includes('group:default/outpost-admins')) {
        return { result: AuthorizeResult.ALLOW };
      }
      return { result: AuthorizeResult.DENY };
    }
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
        policy.setPolicy(new OutpostPolicy());
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/app-config.production.yaml")"
cat > "$APP/app-config.production.yaml" <<'EOF_FILE'
probeReport:
  refreshSeconds: 120
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/package.json")"
cat > "$APP/packages/backend/package.json" <<'EOF_FILE'
{
  "name": "backend",
  "version": "0.1.0",
  "scripts": {
    "start": "backstage-cli package start --config ../../app-config.yaml",
    "start:production": "node dist/index.cjs --config ../../app-config.yaml --config ../../app-config.production.yaml"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/package.json")"
cat > "$APP/plugins/probe-report/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-probe-report",
  "version": "0.1.0",
  "main": "src/index.ts",
  "files": ["dist", "config.d.ts"],
  "configSchema": "config.d.ts",
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
     * @visibility secret
     */
    apiKey: string;
    /**
     * Seconds between refreshes.
     * @visibility frontend
     */
    refreshSeconds?: number;
    /** Entity annotation that the catalog processor checks. */
    annotation?: string;
  };
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/probe-report/src/components/ProbeReportCard.tsx")"
cat > "$APP/plugins/probe-report/src/components/ProbeReportCard.tsx" <<'EOF_FILE'
import React from 'react';
import { configApiRef, useApi } from '@backstage/core-plugin-api';

export const ProbeReportCard = () => {
  const config = useApi(configApiRef);
  const refreshSeconds =
    config.getOptionalNumber('probeReport.refreshSeconds') ?? 60;
  return <div>Probe report refreshes every {refreshSeconds}s</div>;
};
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
        config: coreServices.rootConfig,
      },
      async init({ logger, config }) {
        const endpoint = config.getString('probeReport.endpoint');
        const apiKey = config.getString('probeReport.apiKey');
        const refreshSeconds =
          config.getOptionalNumber('probeReport.refreshSeconds') ?? 60;
        logger.info(`probe-report polls ${endpoint} every ${refreshSeconds}s`);
        logger.debug(`key length ${apiKey.length}`);
      },
    });
  },
});
EOF_FILE

