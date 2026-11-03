# Register The scout-status Plugin In The App

The Starfleet portal team wrote a frontend plugin that shows the state of the scouts. The plugin package builds, but the page does not exist in the portal: opening `/scout-status` shows the not-found page. The project is in `/home/candidate/backstage-app`. It has no `node_modules` directory and you do not run a build; you only edit files.

The portal uses the legacy frontend system: the plugin is created with `createPlugin` and the app package lists routes inside `FlatRoutes` in `packages/app/src/App.tsx`.

## Task

1. In `plugins/scout-status/src/plugin.ts`, export a routable extension named `ScoutStatusPage`. Build it with `scoutStatusPlugin.provide(createRoutableExtension({ ... }))`. Its `component` loads `./components/ScoutStatusPage` with a lazy `import()` and its `mountPoint` is `rootRouteRef`.
2. In `plugins/scout-status/src/index.ts`, export `ScoutStatusPage` together with `scoutStatusPlugin`.
3. In `packages/app/package.json`, add `@internal/plugin-scout-status` to `dependencies` with the version `workspace:^`.
4. In `packages/app/src/App.tsx`, import `ScoutStatusPage` from `@internal/plugin-scout-status`.
5. In the same file, add a route `/scout-status` inside `FlatRoutes` that renders `<ScoutStatusPage />`. A commented-out line does not count.

Keep the plugin `id` (`scout-status`), its `routes` entry and the `/catalog` route as they are.

## Check your work

Use `grep -n` to look at the files you changed. When you are ready, run `astrona submit`. Each validation check prints one line that starts with `OK:` or `FAIL:`, and the `FAIL:` line says what is still missing.
