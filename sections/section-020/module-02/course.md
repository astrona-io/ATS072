---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Extending And Overriding Plugins Safely

Sooner or later a setting is not enough. The catalog must add a field to every entity, a page must move to another path, or a delete action must be refused for most users. Backstage offers supported ways to change behavior that configuration cannot reach: backend modules that plug into extension points, frontend extension overrides and a permission policy. The unsupported way is to copy a plugin and edit it, which creates a private fork that you must maintain forever.

This module teaches the supported ways in order of how little they couple you to a plugin's internals. You extend the `catalog` backend with a module, override a frontend page extension without touching the plugin that owns it, and write a permission policy whose answers follow the contract the permission framework expects. You then see how to keep the result upgradable with `backstage-cli versions:bump`.

## Learning goals

After this module you can:

- Write a backend module with `createBackendModule` that uses an extension point, and register it with `backend.add(import(...))`.
- Override or configure a frontend extension with `app.extensions`, `.override` and `createFrontendModule`.
- Write a `PermissionPolicy` that returns a correct `PolicyDecision` and denies by default.
- Explain why a private fork is costly and when it is still justified.
- Keep package versions consistent and upgrade with `backstage-cli versions:bump`.

## Before you start

You need to read TypeScript and know what a Backstage plugin is. Each new term is defined where it first appears. The playground is a virtual machine with a Backstage-style repository in `/home/candidate/backstage-app`. It has no `node_modules` and does not run Backstage. You read and edit files with `cat`, `grep`, `nano` and `vim`.

The repository holds these files:

| Path | What it is |
| --- | --- |
| `packages/backend/src/index.ts` | The backend entry point that adds plugins and modules |
| `plugins/catalog-backend-module-scout/src/module.ts` | A catalog module that adds a processor |
| `plugins/permission-backend-module-fleet-policy/src/policy.ts` | The permission policy |
| `packages/app/src/App.tsx` | The frontend app entry point |
| `app-config.yaml` | The configuration, with an `app.extensions` list |

## Reading order

The module has three parts. The first part builds and registers a backend module. The second part overrides frontend extensions. The third part covers the permission policy contract, private forks and upgrades. A graded lab follows the third part, and a short summary closes the module.

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
