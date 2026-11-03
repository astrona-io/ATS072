---
estimated_duration: 45m
---

# Capstone: Frontend And Backend Plugins

**Status: UNTESTED.** This lab was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

A frontend plugin written for the legacy system must move to the new frontend system, and a backend plugin, an extension point and a module must be wired together and installed.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-072-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-frontend-new-system.sh` | `plugin.tsx` uses `createFrontendPlugin` and `PageBlueprint` (path `/beacon`, lazy loader) and no legacy API remains |
| `validate-frontend-default-export.sh` | `index.ts` default-exports `beaconPlugin` |
| `validate-app-registers-plugin.sh` | `App.tsx` imports the plugin and lists it in `features`; the app package depends on it |
| `validate-backend-extension-point.sh` | The plugin registers `beaconSourcesExtensionPoint` with an `addSource` method |
| `validate-backend-token-from-config.sh` | `coreServices.rootConfig` supplies `beacon.token`; the literal token is gone from the plugin |
| `validate-module-uses-extension-point.sh` | The module depends on the extension point and calls `addSource(groundStationSource)` |
| `validate-backend-adds-packages.sh` | The backend adds the plugin and the module, keeps the app backend and does not add the node library |
| `validate-no-secret-in-source.sh` | No plugin file contains the token value, the page sends no `Authorization` header and `app-config.yaml` keeps `${BEACON_TOKEN}` |

The validation scripts read the files in `/home/candidate/backstage-app` with `grep`-style patterns and `python3`. Comments do not count. Nothing runs a Backstage build.
