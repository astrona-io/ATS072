# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. File contents are shown in full, because they are what the graders read.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/capstone/labs/lab-01
```

Go to the repository in the virtual machine:

```sh
cd ~/backstage-app
```

`astrona submit` right after the start fails all twelve checks. Work through the steps and submit after each one.

## Step 1: Substitute the secret and the endpoint

In `app-config.yaml`, replace the two literal values in the `probeReport` block:

```yaml
probeReport:
  endpoint: ${PROBE_ENDPOINT:-http://localhost:9191/report}
  apiKey: ${PROBE_API_KEY}
  refreshSeconds: 45
  annotation: outpost.example/probe-report
```

A secret has no default. Submit. `config-from-environment` passes.

## Step 2: Fix the production layer

Objects merge, so the production file needs only the key that changes. Replace `app-config.production.yaml` with:

```yaml
probeReport:
  refreshSeconds: 120
```

Open `packages/backend/package.json`. The `start:production` script names only the production file, and `--config` turns off the default files. List both files, base first:

```json
    "start:production": "node dist/index.cjs --config ../../app-config.yaml --config ../../app-config.production.yaml"
```

Submit. `production-layering` passes.

## Step 3: Tag and register the schema

In `plugins/probe-report/config.d.ts`, add the tags above the two keys:

```ts
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
```

In `plugins/probe-report/package.json`, add the schema and publish the file:

```json
  "files": ["dist", "config.d.ts"],
  "configSchema": "config.d.ts",
```

Check the JSON with `python3 -m json.tool plugins/probe-report/package.json`. Submit. `schema-registered` passes.

## Step 4: Read configuration through rootConfig

In `plugins/probe-report-backend/src/plugin.ts`, add `config: coreServices.rootConfig` to `deps` and receive `config` in `init`. Replace the three lines that use `process.env` and the fixed number:

```ts
        const endpoint = config.getString('probeReport.endpoint');
        const apiKey = config.getString('probeReport.apiKey');
        const refreshSeconds =
          config.getOptionalNumber('probeReport.refreshSeconds') ?? 60;
```

The file must not contain `process.env`. The module comes next, in step 6, because it needs the same service. Submit now to see `config-read-through-rootconfig` still fail on the module. It passes after step 6.

## Step 5: Remove the secret read from the card

Delete the line `const apiKey = config.getString('probeReport.apiKey');` from `ProbeReportCard.tsx`. The key is `secret`, so the browser configuration does not contain it. Submit. `frontend-reads-no-secret` passes.

## Step 6: Rewrite the catalog module

Replace `plugins/catalog-backend-module-probe/src/module.ts` with:

```ts
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
```

Change `src/index.ts` of the module package to the default export:

```ts
export { catalogModuleProbeProcessor as default } from './module';
```

Submit. `module-extends-catalog`, `module-default-export` and `config-read-through-rootconfig` pass.

## Step 7: Add the modules to the backend

In `packages/backend/src/index.ts`, remove the `//` in front of the two internal module lines. Check with `grep -n 'backend.add' packages/backend/src/index.ts`. Submit. `modules-registered` passes.

## Step 8: Write and register the policy

In `plugins/permission-backend-module-outpost-policy/src/policy.ts`, add `isPermission` to the first import, import `catalogEntityDeletePermission` from `@backstage/plugin-catalog-common/alpha`, and replace the body of `handle`:

```ts
    if (isPermission(request.permission, catalogEntityDeletePermission)) {
      const refs = user?.info.ownershipEntityRefs ?? [];
      if (refs.includes('group:default/outpost-admins')) {
        return { result: AuthorizeResult.ALLOW };
      }
      return { result: AuthorizeResult.DENY };
    }
    return { result: AuthorizeResult.ALLOW };
```

In `src/module.ts` of the same package, replace the `TODO` comment with:

```ts
        policy.setPolicy(new OutpostPolicy());
```

Submit. `policy-denies-delete` and `policy-module-sets-policy` pass.

## Step 9: Move the page and align versions

In `app-config.yaml`, the extension block must read:

```yaml
  extensions:
    - page:probe-report:
        config:
          path: /outpost-probes
```

Find the version difference with `grep -rn 'backend-plugin-api' plugins/*/package.json` and change `^1.0.0` to `^1.4.0` in the catalog module package. Submit. All twelve checks pass.
