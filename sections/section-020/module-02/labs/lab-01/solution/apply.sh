#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`: writes the corrected module, entry point, backend index, policy, policy module, app-config.yaml and package.json.
set -eu

APP=/home/candidate/backstage-app

mkdir -p "$(dirname "$APP/app-config.yaml")"
cat > "$APP/app-config.yaml" <<'EOF_FILE'
app:
  title: Starfleet Developer Portal
  baseUrl: http://localhost:3000
  extensions:
    - page:scout-status:
        config:
          path: /fleet-status

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
EOF_FILE

mkdir -p "$(dirname "$APP/packages/backend/src/index.ts")"
cat > "$APP/packages/backend/src/index.ts" <<'EOF_FILE'
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(import('@internal/backstage-plugin-catalog-backend-module-scout'));
backend.add(import('@backstage/plugin-permission-backend'));
backend.add(import('@internal/backstage-plugin-permission-backend-module-fleet-policy'));

backend.start();
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/package.json")"
cat > "$APP/plugins/catalog-backend-module-scout/package.json" <<'EOF_FILE'
{
  "name": "@internal/backstage-plugin-catalog-backend-module-scout",
  "version": "0.1.0",
  "main": "src/index.ts",
  "dependencies": {
    "@backstage/backend-plugin-api": "^1.4.0",
    "@backstage/plugin-catalog-node": "^1.17.0"
  }
}
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/src/module.ts")"
cat > "$APP/plugins/catalog-backend-module-scout/src/module.ts" <<'EOF_FILE'
import {
  coreServices,
  createBackendModule,
} from '@backstage/backend-plugin-api';
import { catalogProcessingExtensionPoint } from '@backstage/plugin-catalog-node';
import { ScoutProcessor } from './ScoutProcessor';

export const catalogModuleScoutProcessor = createBackendModule({
  pluginId: 'catalog',
  moduleId: 'scout-processor',
  register(env) {
    env.registerInit({
      deps: {
        catalog: catalogProcessingExtensionPoint,
        logger: coreServices.logger,
      },
      async init({ catalog, logger }) {
        catalog.addProcessor(new ScoutProcessor(logger));
      },
    });
  },
});
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/catalog-backend-module-scout/src/index.ts")"
cat > "$APP/plugins/catalog-backend-module-scout/src/index.ts" <<'EOF_FILE'
export { catalogModuleScoutProcessor as default } from './module';
EOF_FILE

mkdir -p "$(dirname "$APP/plugins/permission-backend-module-fleet-policy/src/policy.ts")"
cat > "$APP/plugins/permission-backend-module-fleet-policy/src/policy.ts" <<'EOF_FILE'
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

export class FleetPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: PolicyQueryUser,
  ): Promise<PolicyDecision> {
    if (isPermission(request.permission, catalogEntityDeletePermission)) {
      const refs = user?.info.ownershipEntityRefs ?? [];
      if (refs.includes('group:default/starfleet-admins')) {
        return { result: AuthorizeResult.ALLOW };
      }
      return { result: AuthorizeResult.DENY };
    }
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
        policy.setPolicy(new FleetPolicy());
      },
    });
  },
});
EOF_FILE

