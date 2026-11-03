---
estimated_duration: 30m
---

# Install A Backend Plugin And A Module

**Status: UNTESTED.** This lab was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

The backend plugin has the wrong id and no router, the catalog module uses a private import and no extension point, and the backend does not add either package.

The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-072-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-backend-plugin-id.sh` | `createBackendPlugin` uses `pluginId: 'scout-status'`, not the package name |
| `validate-plugin-mounts-router.sh` | `deps` has `httpRouter: coreServices.httpRouter` and `init` calls `httpRouter.use(await createRouter({ logger }))` |
| `validate-module-public-import.sh` | The extension point is imported from `@backstage/plugin-catalog-node`, not from a `src` path |
| `validate-module-uses-extension-point.sh` | The module keeps `pluginId` and `moduleId`, depends on `catalogProcessingExtensionPoint` and calls `addProcessor` |
| `validate-backend-adds-plugin.sh` | An active `backend.add(import('@internal/plugin-scout-status-backend'))` exists |
| `validate-backend-adds-module.sh` | The module is added and the catalog backend is still added |
| `validate-backend-dependencies.sh` | `packages/backend/package.json` lists both internal packages with workspace versions |

The validation scripts read the files in `/home/candidate/backstage-app` with `grep`-style patterns and `python3`. Comments do not count. Nothing runs a Backstage build.
