#!/usr/bin/env bash
# Bootstrap: creates the repository with seven extension mistakes: a catalog module with the wrong pluginId and no extension point, no default export, commented-out backend.add lines, an allow-all policy, a policy module that never calls setPolicy, an unchanged page path and mixed @backstage versions.
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
  extensions:
    - page:scout-status:
        config:
          path: /scout-status

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
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
// backend.add(import('@internal/backstage-plugin-catalog-backend-module-scout'));
backend.add(import('@backstage/plugin-permission-backend'));
// backend.add(import('@internal/backstage-plugin-permission-backend-module-fleet-policy'));

backend.start();
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/package.json")"
cat > "$APP/plugins/catalog-backend-module-scout/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-catalog-backend-module-scout",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.0.0",
    "@backstage/plugin-catalog-node": "^1.17.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-fleet-policy/package.json")"
cat > "$APP/plugins/permission-backend-module-fleet-policy/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-permission-backend-module-fleet-policy",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0",
    "@backstage/plugin-permission-node": "^0.10.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/src/ScoutProcessor.ts")"
cat > "$APP/plugins/catalog-backend-module-scout/src/ScoutProcessor.ts" <<'EOF_FILE'
import type { Entity } from '@backstage/catalog-model';
import type { CatalogProcessor } from '@backstage/plugin-catalog-node';
import type { LoggerService } from '@backstage/backend-plugin-api';

export class ScoutProcessor implements CatalogProcessor {
  constructor(private readonly logger: LoggerService) {}

  getProcessorName(): string {
    return 'ScoutProcessor';
  }

  async preProcessEntity(entity: Entity): Promise<Entity> {
    this.logger.debug(`checked ${entity.metadata.name}`);
    return entity;
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/src/module.ts")"
cat > "$APP/plugins/catalog-backend-module-scout/src/module.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';

export const catalogModuleScoutProcessor = createBackendModule({
  pluginId: 'scout-status',
  moduleId: 'scout-processor',
  register(env) {
    env.registerInit({
      deps: {
        logger: coreServices.logger,
      },
      async init({ logger }) {
        logger.info('scout-processor started');
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/src/index.ts")"
cat > "$APP/plugins/catalog-backend-module-scout/src/index.ts" <<'EOF_FILE'
export { catalogModuleScoutProcessor } from './module';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-fleet-policy/src/policy.ts")"
cat > "$APP/plugins/permission-backend-module-fleet-policy/src/policy.ts" <<'EOF_FILE'
import { AuthorizeResult } from '@backstage/plugin-permission-common';
import type { PolicyDecision } from '@backstage/plugin-permission-common';
import type {
  PermissionPolicy,
  PolicyQuery,
  PolicyQueryUser,
} from '@backstage/plugin-permission-node';

export class FleetPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: PolicyQueryUser,
  ): Promise<PolicyDecision> {
    return { result: AuthorizeResult.ALLOW };
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-fleet-policy/src/module.ts")"
cat > "$APP/plugins/permission-backend-module-fleet-policy/src/module.ts" <<'EOF_FILE'
import { createBackendModule } from '@backstage/backend-plugin-api';
import { policyExtensionPoint } from '@backstage/plugin-permission-node/alpha';
import { FleetPolicy } from './policy';

export const permissionModuleFleetPolicy = createBackendModule({
  pluginId: 'permission',
  moduleId: 'fleet-policy',
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

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-fleet-policy/src/index.ts")"
cat > "$APP/plugins/permission-backend-module-fleet-policy/src/index.ts" <<'EOF_FILE'
export { permissionModuleFleetPolicy as default } from './module';
EOF_FILE

sudo chown -R "$(whoami):$(whoami)" /home/candidate
