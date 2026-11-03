# Overview: Extending And Overriding Plugins Safely (Playground)

This is a **playground**, not a lab. It starts a virtual machine with a small Backstage-style repository and then waits. There is no task, no `astrona submit` and no pass or fail. Read the files, change them, break them and read them again.

## What is in the box

- A virtual machine with Ubuntu, `bash`, `grep`, `sed`, `python3`, `nano` and `vim`. It has no Node.js and no Yarn.
- The repository `/home/candidate/backstage-app`. It has no `node_modules` and it does not start Backstage. It only holds the files that the module reads and edits. Everything in it works as written.

| Path | Purpose |
| --- | --- |
| `packages/backend/src/index.ts` | Adds the catalog, the permission backend and both modules with `backend.add(import(...))` |
| `plugins/catalog-backend-module-scout/src/module.ts` | Catalog module that adds `ScoutProcessor` through `catalogProcessingExtensionPoint` |
| `plugins/catalog-backend-module-scout/src/index.ts` | Exports the module as `default` |
| `plugins/permission-backend-module-fleet-policy/src/policy.ts` | `FleetPolicy`, which denies entity deletion unless the user owns `group:default/starfleet-admins` |
| `plugins/permission-backend-module-fleet-policy/src/module.ts` | Registers the policy with `policy.setPolicy` |
| `app-config.yaml` | `app.extensions` entry that moves `page:scout-status` to `/fleet-status` |

## Practice tasks

- Comment out one `backend.add` line and explain what stops working. Then change `pluginId: 'catalog'` to another value and explain the effect.
- Remove `as default` from the module `index.ts` and write down why `backend.add(import(...))` then has nothing to load.
- Change `FleetPolicy` so that it also refuses `catalogEntityCreatePermission` (import it from `@backstage/plugin-catalog-common/alpha`) for users who are not administrators.
- Change the last `return` of the policy to `DENY`, then list what users could no longer do.
- Edit the `app.extensions` entry to use another path, and add a second entry that ends with `: false` to disable an extension. Check that the list still has a dash in front of every entry.
- Make the `@backstage/backend-plugin-api` version differ between the two `package.json` files and find the difference with `grep -rn 'backend-plugin-api' plugins/*/package.json`.
