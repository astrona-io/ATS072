---
estimated_duration: 30m
---

# Lab: Configuring Plugins With app-config.yaml

Graded lab. **UNTESTED**: built with static checks only (`astrona validate`, `bash -n`); it has not been run in a virtual machine. The machine holds `/home/candidate/backstage-app`, a Backstage-style repository without `node_modules`. The task is in `question.md` and the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-072-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

The graders read files with `grep` and `python3`. They strip comment-only lines before they match.

| Script | What it proves |
| --- | --- |
| `validate-token-from-environment.sh` | `apiToken` is `${SCOUT_API_TOKEN}` and the literal token is gone |
| `validate-url-has-default.sh` | `apiUrl` uses `${SCOUT_API_URL:-http://...}` |
| `validate-schema-visibility.sh` | `apiToken` is `secret`; `refreshSeconds` and `title` are `frontend` |
| `validate-package-registers-schema.sh` | `configSchema` and `files` in the plugin `package.json` |
| `validate-backend-uses-rootconfig.sh` | `coreServices.rootConfig`, `getOptionalNumber` with a default, no `process.env` |
| `validate-frontend-reads-no-secret.sh` | The card uses `configApiRef` and does not read `apiToken` |

## Open items (UNTESTED assumptions)

- The `folder` bootstrap type runs every script in `bootstrap/` inside the virtual machine as the default user.
- `python3` is available in the `ubuntu-qcow2-image:24.04-lfcs` image.
