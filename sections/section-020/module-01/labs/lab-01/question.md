# Question

Solve this question on: `terminal`

The `scout-status` plugin in `/home/candidate/backstage-app` reports the state of the `scout` service. A review found five problems in how it is configured and how it reads configuration. The repository has no `node_modules`, and you do not run Backstage. You change the files with `nano` or `vim`.

1. In `app-config.yaml`, the key `scoutStatus.apiToken` holds a literal token. The token must come from the environment variable `SCOUT_API_TOKEN`, with no default value. The key `scoutStatus.apiUrl` must come from `SCOUT_API_URL`, and it must fall back to `http://localhost:9090/status` when the variable is not set.

2. In `plugins/scout-status/config.d.ts`, the token must be visible to the backend only and marked as sensitive. The keys `refreshSeconds` and `title` must be readable in the browser.

3. In `plugins/scout-status/package.json`, register `config.d.ts` as the configuration schema and make sure the file is published with the package.

4. In `plugins/scout-status-backend/src/plugin.ts`, the plugin reads `process.env` and a fixed number. It must read `scoutStatus.apiToken` as a required value and `scoutStatus.refreshSeconds` as an optional number with the default `30`, both through the configuration service of the new backend system.

5. In `plugins/scout-status/src/components/ScoutStatusCard.tsx`, the card reads a value that the browser can never see. Remove the read, and keep the card reading its other settings with the configuration API.
