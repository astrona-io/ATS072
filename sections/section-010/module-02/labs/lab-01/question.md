# Install A Backend Plugin And A Module

The Starfleet portal needs a backend for the `scout-status` page. The backend plugin and the catalog module exist as packages, but the backend does not load them. The page asks the discovery API for the base URL of `scout-status` and gets no answer. The project is in `/home/candidate/backstage-app`. It has no `node_modules` directory and you do not run a build; you only edit files.

## Task

1. In `plugins/scout-status-backend/src/plugin.ts`, give the plugin the id `scout-status`.
2. In the same file, add `httpRouter: coreServices.httpRouter` to `deps`. In `init`, mount the router with `httpRouter.use(await createRouter({ logger }))`.
3. In `plugins/catalog-backend-module-outpost/src/module.ts`, import `catalogProcessingExtensionPoint` from the public package `@backstage/plugin-catalog-node` instead of the private path that is used now.
4. In the same file, add `catalog: catalogProcessingExtensionPoint` to `deps` and call `catalog.addProcessor(new OutpostProcessor())` in `init`. Keep `pluginId: 'catalog'` and `moduleId: 'outpost-entities'`.
5. In `packages/backend/src/index.ts`, add the plugin `@internal/plugin-scout-status-backend` and the module `@internal/plugin-catalog-backend-module-outpost` with `backend.add(import('...'))`. Keep the existing `backend.add` lines for the app and catalog backends.
6. In `packages/backend/package.json`, add both internal packages to `dependencies` with the version `workspace:^`.

## Check your work

Use `grep -n` to look at the files you changed. When you are ready, run `astrona submit`. Each check prints `OK:` or `FAIL:` with the reason.
