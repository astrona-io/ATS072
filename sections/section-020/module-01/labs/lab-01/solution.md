# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. File contents are shown in full, because they are what the graders read.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-020/module-01/labs/lab-01
```

Go to the repository in the virtual machine:

```sh
cd ~/backstage-app
```

`astrona submit` right after the start fails all six checks. Work through the steps and submit after each one.

## Step 1: Read the secret and the URL from the environment

Open `app-config.yaml` with `nano app-config.yaml`. In the `scoutStatus` block, replace the two literal values. A secret has no default, so a start without the variable fails at the read. The URL has a default after `:-`.

```yaml
scoutStatus:
  apiUrl: ${SCOUT_API_URL:-http://localhost:9090/status}
  apiToken: ${SCOUT_API_TOKEN}
  refreshSeconds: 30
  title: Scout Status
```

Run `grep -n 'SCOUT_API' app-config.yaml` to check that both lines changed, then `astrona submit --keep`. The checks `token-from-environment` and `url-has-default` pass.

## Step 2: Tag the schema

Open `plugins/scout-status/config.d.ts`. Add a `@visibility` tag inside the comment block above each key. The tag must be in the comment directly above the key it applies to.

```ts
    /**
     * Token for the scout status API.
     * @visibility secret
     */
    apiToken: string;
    /**
     * Seconds between refreshes.
     * @visibility frontend
     */
    refreshSeconds?: number;
    /**
     * Card title.
     * @visibility frontend
     */
    title?: string;
```

Run `grep -n '@visibility' plugins/scout-status/config.d.ts`. It lists three tags. Submit again. `schema-visibility` passes.

## Step 3: Register the schema in package.json

Open `plugins/scout-status/package.json`. Add `configSchema` and add the file to `files`:

```json
  "files": ["dist", "config.d.ts"],
  "configSchema": "config.d.ts",
```

Keep the file valid JSON: every line except the last in an object ends with a comma. Check it with `python3 -m json.tool plugins/scout-status/package.json`. The command prints the file when it is valid. Submit. `package-registers-schema` passes.

## Step 4: Read configuration through coreServices.rootConfig

Open `plugins/scout-status-backend/src/plugin.ts`. Add `config: coreServices.rootConfig` to `deps`, receive `config` in `init`, and replace the three fixed lines:

```ts
      deps: {
        logger: coreServices.logger,
        config: coreServices.rootConfig,
      },
      async init({ logger, config }) {
        const apiUrl = config.getString('scoutStatus.apiUrl');
        const apiToken = config.getString('scoutStatus.apiToken');
        const refreshSeconds =
          config.getOptionalNumber('scoutStatus.refreshSeconds') ?? 30;
```

The file must not contain `process.env` anywhere, not even in an active line. Run `grep -n 'process.env' plugins/scout-status-backend/src/plugin.ts`. It prints nothing. Submit. `backend-uses-rootconfig` passes.

## Step 5: Remove the secret read from the card

Open `plugins/scout-status/src/components/ScoutStatusCard.tsx` and delete the line that calls `config.getString('scoutStatus.apiToken')`. The key is `secret`, so the browser configuration does not contain it, and the call would throw when the card renders. Keep `useApi(configApiRef)` and the two optional reads.

Run `grep -n 'apiToken' plugins/scout-status/src/components/ScoutStatusCard.tsx`. It prints nothing. Submit. All six checks pass.
