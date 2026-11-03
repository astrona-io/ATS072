# Overview: Configuring Plugins With app-config.yaml (Playground)

This is a **playground**, not a lab. It starts a virtual machine with a small Backstage-style repository and then waits. There is no task, no `astrona submit` and no pass or fail. Read the files, change them, break them and read them again.

## What is in the box

- A virtual machine with Ubuntu, `bash`, `grep`, `sed`, `python3`, `nano` and `vim`. It has no Node.js, no Yarn and no network access that you need.
- The repository `/home/candidate/backstage-app`. It has no `node_modules` and it does not start Backstage. It only holds the files that the module reads and edits.

| Path | Purpose |
| --- | --- |
| `app-config.yaml` | Base configuration with the `scoutStatus` block and `${...}` substitutions |
| `app-config.production.yaml` | Production override with `app.baseUrl` and a higher `refreshSeconds` |
| `plugins/scout-status/config.d.ts` | Schema with `@visibility secret` and `@visibility frontend` tags |
| `plugins/scout-status/package.json` | Declares `configSchema` and lists `config.d.ts` in `files` |
| `plugins/scout-status-backend/src/plugin.ts` | Reads settings through `coreServices.rootConfig` |
| `plugins/scout-status/src/components/ScoutStatusCard.tsx` | Reads settings through `configApiRef` |
| `packages/backend/src/index.ts` | Adds the backend plugin with `backend.add(import(...))` |

## Practice tasks

- Work out by hand which value of `scoutStatus.refreshSeconds` a start with both files would use, and which value of `scoutStatus.title`.
- Add a key `scoutStatus.environment` to `app-config.yaml`, declare it in `config.d.ts` as optional with `@visibility frontend`, and read it in the card with `getOptionalString` and a default.
- Replace the token line with `$env: SCOUT_API_TOKEN` and explain how that differs from `${SCOUT_API_TOKEN}`.
- Change `@visibility secret` to `@visibility frontend` on `apiToken` and write down who can now read the token.
- Change the production file so that it lists an array and compare it in your head with the base file.
- Use `grep -rn 'process.env' plugins packages` to confirm that no plugin reads the environment directly.
