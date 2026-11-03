# Capstone: Move The beacon Feature To The Current Systems

The Starfleet portal gets a new feature, `beacon`, that lists beacon states. Its code was written for the legacy frontend system, and the backend plugin was started but never finished. The portal app uses the new frontend system (`createApp` from `@backstage/frontend-defaults`) and the new backend system. The project is in `/home/candidate/backstage-app`. It has no `node_modules` directory and you do not run a build; you only edit files.

The feature has four packages: a frontend plugin (`plugins/beacon`), a backend plugin (`plugins/beacon-backend`), a node library with an extension point (`plugins/beacon-node`) and a backend module (`plugins/beacon-backend-module-ground-station`). A token (`lantern-7f3a`) is written in two source files today. It must come from the configuration key `beacon.token`, which `app-config.yaml` reads from the environment variable `BEACON_TOKEN`.

## Task

1. Frontend plugin. Replace `plugins/beacon/src/plugin.ts` with a file `plugins/beacon/src/plugin.tsx` that exports `beaconPlugin`, created with `createFrontendPlugin` from `@backstage/frontend-plugin-api`. It has `pluginId: 'beacon'`, one page extension made with `PageBlueprint.make` (path `/beacon`, the `rootRouteRef` route reference from `./routes`, and a loader that lazily imports `./components/BeaconPage`) and `routes: { root: rootRouteRef }`. Delete the legacy `plugin.ts`.
2. Make `plugins/beacon/src/index.ts` export `beaconPlugin` as the default export.
3. App. In `packages/app/src/App.tsx`, import the default export as `beaconPlugin` from `@internal/plugin-beacon` and pass it in the `features` array. Add the package to `dependencies` in `packages/app/package.json` (`workspace:^`).
4. Backend plugin. In `plugins/beacon-backend/src/plugin.ts`, register `beaconSourcesExtensionPoint` (from `@internal/plugin-beacon-node`) with `env.registerExtensionPoint`. Its `addSource(source)` method pushes into the `sources` array. Add `coreServices.rootConfig` to `deps` and read the token with `getString('beacon.token')`. Remove the literal token.
5. Backend module. In `plugins/beacon-backend-module-ground-station/src/module.ts`, depend on `beaconSourcesExtensionPoint` and call `addSource(groundStationSource)` (from `./sources`) in `init`.
6. Backend. In `packages/backend/src/index.ts`, add the beacon backend plugin and the ground-station module with `backend.add(import('...'))`. Do not add the node library: it holds only the extension point.
7. Secret. Remove the `Authorization` header and the literal token from `plugins/beacon/src/components/BeaconPage.tsx`. The browser calls the backend through the discovery API and the backend uses the token.

## Check your work

Use `grep -rn lantern plugins` to find the literal token. When you are ready, run `astrona submit`. Each check prints `OK:` or `FAIL:` with the reason.
