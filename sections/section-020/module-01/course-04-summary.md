---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Summary

Configuration is the first and safest way to change a Backstage plugin. It needs no copied source and no rebuild of the plugin, and it keeps the plugin on its supported contract.

## What you learned

Backstage loads `app-config.yaml` and, by default, `app-config.local.yaml`. When any `--config` flag is used, only the named files load, and the last flag wins. `APP_CONFIG_` environment variables rank above every file. Objects merge key by key, primitives are replaced, arrays are replaced as a whole, and `null` means explicitly absent. Relative paths resolve from the working directory of the process.

Secrets and environment-specific values stay out of committed files. Substitution with `${NAME}` and `${NAME:-default}` works inside a string, and a missing variable without a default makes the value `undefined`. The `$env`, `$file` and `$include` keys replace a whole value from an environment variable, a text file or a YAML or JSON file.

A package declares its schema with `configSchema` in `package.json`, usually pointing to `config.d.ts`, and lists the file in `files`. The `Config` interface declares keys, types and optionality. The tag `@visibility` decides who can read a key: `backend` is the default, `frontend` also reaches the browser, and `secret` is backend only and marked sensitive. Schemas of all packages merge, and conflicting visibility for one key stops the start.

Backend code requests `coreServices.rootConfig` in `deps` and reads values with `getString`, `getOptionalString`, `getOptionalNumber` and `getConfig`. Frontend code calls `useApi(configApiRef)` and sees only keys tagged `frontend`. Required reads fail early. Optional reads use `??` to supply a default that is safe in production.

The key facts to remember are these:

- Later files and `APP_CONFIG_` variables win, and arrays never merge.
- A secret belongs in an environment variable or a file, never in a committed YAML value.
- No `@visibility` tag means backend only, and `frontend` publishes the value to every browser.
- A plugin reads configuration through `rootConfig` or `configApiRef`, never through `process.env`.

<!-- astrona:playground:destroy -->
