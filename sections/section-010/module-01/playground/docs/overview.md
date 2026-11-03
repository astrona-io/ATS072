# Frontend Plugins Playground

This playground is a virtual machine with a small Backstage-style project in `/home/candidate/backstage-app`. It is a working example, not a lab: nothing is graded and nothing is submitted. The project has no `node_modules` directory and no network access is needed. You read and edit files; you do not build or start Backstage.

## What is in the project

| Path | What it is |
| --- | --- |
| `app-config.yaml` | Application configuration (titles, base URLs, database, catalog rules) |
| `package.json` | Root workspace file listing `packages/*` and `plugins/*` |
| `packages/app/src/App.tsx` | The app package: imports plugin pages and defines routes in `FlatRoutes` |
| `packages/app/package.json` | Dependencies of the app package, including the frontend plugin |
| `packages/backend/src/index.ts` | The backend: `createBackend()` and one `backend.add(import(...))` line per plugin or module |
| `plugins/scout-status/` | Frontend plugin: `plugin.ts`, `routes.ts`, `index.ts` and the page component |
| `plugins/scout-status-backend/` | Backend plugin `scout-status`: `plugin.ts` and `router.ts` |
| `plugins/catalog-backend-module-outpost/` | Backend module for the catalog plugin: `module.ts` and `OutpostProcessor.ts` |

The frontend plugin is registered in the app: the dependency is in `packages/app/package.json`, the page is imported in `App.tsx` and a route points at it. The reading asks you to follow the chain from the route to the component and to add a second route.

## Helper commands

The terminal has `grep`, `cat`, `find`, `nano`, `vim` and `python3`. These are the commands the reading uses.

```sh
cd ~/backstage-app
find . -type f | sort
grep -rn "scout-status" --include=*.ts --include=*.tsx --include=*.json .
cat plugins/scout-status/src/plugin.ts
python3 -m json.tool packages/app/package.json
```

## Ideas to try

- Follow the chain `App.tsx` route, plugin package name, `index.ts` export, `plugin.ts` extension, `routes.ts` route reference and component file with `grep -rn`.
- Add a second page: copy the component folder to a new name, export a second routable extension that uses the same `rootRouteRef`, and read why two extensions cannot share one route reference mount path in a real app.
- Comment out the import of `ScoutStatusPage` in `App.tsx` and list which other lines now point at something that no longer exists.
- Find where the component asks for the backend address (`discoveryApi.getBaseUrl('scout-status')`) and which backend file defines that id.

Nothing here is checked. If you break a file, you can read it again with `cat`, or restart the playground with `astrona destroy` and `astrona run`.
