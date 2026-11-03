# Question

Solve this question on: `terminal`

The platform team extends Backstage with two backend modules and one frontend setting. The work is in `/home/candidate/backstage-app`, a repository without `node_modules`. You do not run Backstage. You change the files with `nano` or `vim`. Seven things are wrong or missing.

1. The catalog module in `plugins/catalog-backend-module-scout` must extend the `catalog` plugin. It must receive the catalog processing extension point from `@backstage/plugin-catalog-node` and add a `ScoutProcessor` (built with the `logger`) to the catalog.

2. The package entry point `src/index.ts` of that module must export the module as the default export.

3. In `packages/backend/src/index.ts`, the backend must load both internal modules with `backend.add(import(...))`. The catalog and the permission backend lines must stay.

4. The permission policy `FleetPolicy` in `plugins/permission-backend-module-fleet-policy/src/policy.ts` allows everything. It must refuse `catalogEntityDeletePermission` (from `@backstage/plugin-catalog-common/alpha`) unless the user's `ownershipEntityRefs` include `group:default/starfleet-admins`. Every decision is an object with a `result` field.

5. The policy module must register the policy with the policy extension point of the `permission` plugin.

6. In `app-config.yaml`, move the extension `page:scout-status` to the path `/fleet-status` using its `config`.

7. The two module `package.json` files ask for different versions of `@backstage/backend-plugin-api`. Use one version in both.
