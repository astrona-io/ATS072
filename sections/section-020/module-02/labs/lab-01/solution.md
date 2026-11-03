# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. File contents are shown in full, because they are what the graders read.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-02/labs/lab-01
```

Go to the repository in the virtual machine:

```sh
cd ~/backstage-app
```

`astrona submit` right after the start fails all seven checks. Work through the steps and submit after each one.

## Step 1: Make the module extend the catalog

Open `plugins/catalog-backend-module-scout/src/module.ts`. The module has the wrong `pluginId` and never asks for the extension point. Replace the file with this content:

```ts
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
```

Submit. `module-extends-catalog` passes.

## Step 2: Export the module as default

The backend loads a package through its default export. Change `src/index.ts` of the module package to:

```ts
export { catalogModuleScoutProcessor as default } from './module';
```

Submit. `module-default-export` passes.

## Step 3: Add the modules to the backend

Open `packages/backend/src/index.ts`. Two `backend.add` lines start with `//`, which makes them comments. Remove the two slashes and the space after them. Check the result:

```sh
grep -n 'backend.add' packages/backend/src/index.ts
```

Four lines print and none of them starts with `//`. Submit. `modules-registered` passes.

## Step 4: Write the policy

Open `plugins/permission-backend-module-fleet-policy/src/policy.ts`. Add `isPermission` to the first import, add the import of `catalogEntityDeletePermission` from `@backstage/plugin-catalog-common/alpha`, and replace the body of `handle`:

```ts
    if (isPermission(request.permission, catalogEntityDeletePermission)) {
      const refs = user?.info.ownershipEntityRefs ?? [];
      if (refs.includes('group:default/starfleet-admins')) {
        return { result: AuthorizeResult.ALLOW };
      }
      return { result: AuthorizeResult.DENY };
    }
    return { result: AuthorizeResult.ALLOW };
```

Submit. `policy-denies-delete` passes.

## Step 5: Register the policy

Open `plugins/permission-backend-module-fleet-policy/src/module.ts`. Replace the `TODO` comment in `init` with this line:

```ts
        policy.setPolicy(new FleetPolicy());
```

Submit. `policy-module-sets-policy` passes.

## Step 6: Configure the page path

Open `app-config.yaml`. Change the path under the `page:scout-status` entry so that the block reads:

```yaml
  extensions:
    - page:scout-status:
        config:
          path: /fleet-status
```

Keep the dash in front of `page:scout-status`. Submit. `page-path-configured` passes.

## Step 7: Align the versions

Find the difference:

```sh
grep -rn 'backend-plugin-api' plugins/*/package.json
```

One file asks for `^1.0.0` and the other for `^1.4.0`. Change `^1.0.0` to `^1.4.0` in `plugins/catalog-backend-module-scout/package.json`. Submit. All seven checks pass.
