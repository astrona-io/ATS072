---
estimated_duration: 40m
---

# Lab: Extending And Overriding Plugins Safely

Graded lab. **UNTESTED**: built with static checks only (`astrona validate`, `bash -n`); it has not been run in a virtual machine. The machine holds `/home/candidate/backstage-app`, a Backstage-style repository without `node_modules`. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-072-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

The graders read files with `python3` and regular expressions. They strip comment-only lines first, so a commented-out `backend.add` does not count.

| Script | What it proves |
| --- | --- |
| `validate-module-extends-catalog.sh` | `pluginId: 'catalog'`, `catalogProcessingExtensionPoint` in `deps`, `addProcessor(new ScoutProcessor(...))` |
| `validate-module-default-export.sh` | `export { ... as default } from './module'` |
| `validate-modules-registered.sh` | Four active `backend.add(import(...))` lines |
| `validate-policy-denies-delete.sh` | `isPermission`, the admin group and `{ result: AuthorizeResult.DENY }` |
| `validate-policy-module-sets-policy.sh` | `pluginId: 'permission'`, `policyExtensionPoint`, `setPolicy` |
| `validate-page-path-configured.sh` | `page:scout-status` with `config.path: /fleet-status` |
| `validate-versions-consistent.sh` | One version per `@backstage` package across all `package.json` files |

## Open items (UNTESTED assumptions)

- `policyExtensionPoint` is imported from `@backstage/plugin-permission-node/alpha`. Check the path against the installed release.
- `user.info.ownershipEntityRefs` is the field of `PolicyQueryUser` in current releases.
- The extension ID `page:scout-status` follows the `<kind>:<plugin id>` pattern for an unnamed page.
