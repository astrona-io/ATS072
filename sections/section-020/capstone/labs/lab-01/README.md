---
estimated_duration: 60m
---

# Capstone: Customizing Backstage Plugins

Graded capstone. **UNTESTED**: built with static checks only (`astrona validate`, `bash -n`); it has not been run in a virtual machine. The machine holds `/home/candidate/backstage-app`, a Backstage-style repository without `node_modules`. It combines configuration (layering, substitution, schema, reading) with extension (catalog module, permission policy, page path, versions). The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-072-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

The graders read files with `python3` and regular expressions. They strip comment-only lines first.

| Script | What it proves |
| --- | --- |
| `validate-config-from-environment.sh` | endpoint has a default and apiKey comes from the environment |
| `validate-production-layering.sh` | the production file only overrides refreshSeconds and the start script loads both files in order |
| `validate-schema-registered.sh` | the schema tags apiKey secret and refreshSeconds frontend, and package.json registers it |
| `validate-config-read-through-rootconfig.sh` | the backend plugin and the catalog module read configuration through coreServices.rootConfig |
| `validate-frontend-reads-no-secret.sh` | the card does not read the secret key |
| `validate-module-extends-catalog.sh` | the probe module extends the catalog and adds its processor |
| `validate-module-default-export.sh` | the probe module package exports the module as default |
| `validate-modules-registered.sh` | the backend adds both modules with backend.add(import(...)) |
| `validate-policy-denies-delete.sh` | outpost-policy policy denies entity deletion for non-administrators |
| `validate-policy-module-sets-policy.sh` | the permission module registers the policy through policyExtensionPoint |
| `validate-page-path-configured.sh` | app.extensions moves page:probe-report to /outpost-probes |
| `validate-versions-consistent.sh` | every package.json asks for the same version of each @backstage package |

## Open items (UNTESTED assumptions)

- `policyExtensionPoint` is imported from `@backstage/plugin-permission-node/alpha`. Check the path against the installed release.
- `user.info.ownershipEntityRefs` is the field of `PolicyQueryUser` in current releases.
- The extension ID `page:probe-report` follows the `<kind>:<plugin id>` pattern for an unnamed page.
