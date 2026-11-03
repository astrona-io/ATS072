---
estimated_duration: 25m
---

# Register A Frontend Plugin In The App

**Status: UNTESTED.** This lab was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

A frontend plugin package exists but the app package does not import it, depend on it or route to it.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-072-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-routable-extension.sh` | `plugin.ts` exports `ScoutStatusPage` from `scoutStatusPlugin.provide(createRoutableExtension(...))` with `mountPoint: rootRouteRef` and a lazy import |
| `validate-plugin-index-exports.sh` | `index.ts` exports `scoutStatusPlugin` and `ScoutStatusPage` |
| `validate-app-dependency.sh` | `packages/app/package.json` is valid JSON and lists `@internal/plugin-scout-status` with a workspace version |
| `validate-app-import.sh` | `App.tsx` imports `ScoutStatusPage` from the plugin package |
| `validate-app-route.sh` | A real `Route` for `/scout-status` is inside `FlatRoutes` (comments are ignored) |
| `validate-plugin-identity-kept.sh` | The plugin id, its root route and the `/catalog` route are unchanged |

The validation scripts read the files in `/home/candidate/backstage-app` with `grep`-style patterns and `python3`. Comments do not count. Nothing runs a Backstage build.
