# Question

Solve this question on: `terminal`

The `probe-report` feature of the outpost portal is half finished. The repository `/home/candidate/backstage-app` has no `node_modules`, and you do not run Backstage. You change files with `nano` or `vim`. The feature has a backend plugin, a card, a catalog module and a permission policy module. Fix the configuration first and the extensions second.

Configuration:

1. In `app-config.yaml`, `probeReport.apiKey` must come from the environment variable `PROBE_API_KEY` with no default. `probeReport.endpoint` must come from `PROBE_ENDPOINT` and fall back to `http://localhost:9191/report`.

2. `app-config.production.yaml` must override only `probeReport.refreshSeconds` (value `120`) and must not repeat the key. The `start:production` script in `packages/backend/package.json` must load `app-config.yaml` first and `app-config.production.yaml` second.

3. In `plugins/probe-report`, the schema `config.d.ts` must keep the key visible to the backend only and marked as sensitive, and must let the browser read `refreshSeconds`. The package must register the schema and publish the file.

4. The backend plugin `plugins/probe-report-backend/src/plugin.ts` and the catalog module must read configuration through the configuration service of the backend system. The plugin reads `endpoint` and `apiKey` as required values and `refreshSeconds` as an optional number with the default `60`. The module reads the optional string `probeReport.annotation` with the default `outpost.example/probe-report`.

5. The card in `plugins/probe-report/src/components/ProbeReportCard.tsx` reads a value that the browser can never see. Remove that read.

Extensions:

6. The catalog module in `plugins/catalog-backend-module-probe` must extend the `catalog` plugin, receive the catalog processing extension point and add a `ProbeProcessor` built with the `logger` and the annotation. Its package entry point must export the module as the default export.

7. `packages/backend/src/index.ts` must load both internal modules with `backend.add(import(...))`. All other `backend.add` lines stay.

8. The `OutpostPolicy` must refuse `catalogEntityDeletePermission` (from `@backstage/plugin-catalog-common/alpha`) unless the user's `ownershipEntityRefs` include `group:default/outpost-admins`. The policy module must register the policy with the policy extension point of the `permission` plugin.

9. In `app-config.yaml`, move the extension `page:probe-report` to `/outpost-probes` using its `config`.

10. The two module `package.json` files ask for different versions of `@backstage/backend-plugin-api`. Use one version everywhere.
