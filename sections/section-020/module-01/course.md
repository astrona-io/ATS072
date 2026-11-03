---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Configuring Plugins With app-config.yaml

A Backstage plugin is code that many organizations install, and no two organizations want it to behave in exactly the same way. The first and cheapest way to change a plugin is configuration: you change a value in `app-config.yaml` and the plugin reads it at startup. No plugin source is copied, patched or rebuilt.

This module shows the whole path of one configuration value. A value starts in a YAML file, passes through file layering and environment substitution, is checked and filtered by a configuration schema, and is then read by backend code through `coreServices.rootConfig` or by frontend code through `configApiRef`. You work on a plugin named `scout-status` that reports the state of the `scout` service.

## Learning goals

After this module you can:

- Explain which configuration files Backstage loads, in what order, and how objects, arrays and `null` values merge.
- Keep secrets out of YAML files with `${VAR}`, `${VAR:-default}` and the `$env`, `$file` and `$include` keys.
- Write a `config.d.ts` schema with `@visibility frontend`, `backend` and `secret`, and register it with `configSchema` in `package.json`.
- Read configuration in a backend plugin with `coreServices.rootConfig` and in a frontend plugin with `configApiRef`.
- Choose a safe default when an optional setting is missing.

## Before you start

You need to read TypeScript and YAML. Each term is defined where it first appears. The playground is a small virtual machine with a Backstage-style repository in `/home/candidate/backstage-app`. It has no `node_modules` and no running Backstage. You read and edit files with `cat`, `grep`, `nano` and `vim`.

The repository holds these files:

| Path | What it is |
| --- | --- |
| `app-config.yaml` | The base configuration, with a `scoutStatus` block |
| `app-config.production.yaml` | A production override file |
| `plugins/scout-status/config.d.ts` | The configuration schema of the plugin |
| `plugins/scout-status/package.json` | The package file that points to the schema |
| `plugins/scout-status-backend/src/plugin.ts` | The backend plugin that reads the settings |
| `plugins/scout-status/src/components/ScoutStatusCard.tsx` | The frontend component that reads the settings |

## Reading order

The module has three parts. The first part explains how Backstage loads and layers configuration files. The second part explains the schema in `config.d.ts` and the three visibility levels. The third part explains how backend and frontend code read the final values. A graded lab follows the third part, and a short summary closes the module.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
