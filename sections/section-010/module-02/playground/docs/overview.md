# Backend Plugins Playground

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

The backend loads the plugin and the module: `packages/backend/src/index.ts` has one `backend.add(import(...))` line each. The reading asks you to follow how the plugin id, the services in `deps` and the extension point connect these files.

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

- Read `plugin.ts` and list every service in `deps` and where each one is used in `init`.
- Change `pluginId` in the backend plugin to another name and list which frontend file would now ask for an address that does not exist.
- Read `module.ts` and find the extension point it uses, then find where the processor class is defined.
- Add a second `logger.info(...)` line to `init` in `module.ts` and explain in which order the module and the catalog plugin would run it.

Nothing here is checked. If you break a file, you can read it again with `cat`, or restart the playground with `astrona destroy` and `astrona run`.
