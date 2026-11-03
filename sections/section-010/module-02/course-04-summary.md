---
draft: true
exam_objectives:
- Understand frontend versus backend plugins
---
# Summary

A backend plugin runs on the server, where it can hold secrets, call private systems and check permissions. In the new backend system, `createBackend()` creates the backend and each `backend.add(import('...'))` line loads one plugin or module. A plugin is made with `createBackendPlugin`, has a `pluginId`, and declares its needs and its start function with `registerInit`. A package that is installed but not added does not run.

The plugin id decides the URL path: the HTTP router service mounts the plugin router under `/api/<pluginId>`, and the frontend finds that address through the discovery API using the same id. The id in the frontend, the backend and the discovery call must match.

Plugins receive what they need as services. `coreServices` holds the references for the logger, the HTTP router, the root configuration, the database, authentication, the scheduler and more. The plugin lists them in `deps` and receives the implementations in `init`. Secrets are read from configuration in the backend, and the default for routes is authenticated callers only.

A plugin lets others customize it with an extension point, created with `createExtensionPoint` and usually published in a `-node` package. A backend module, made with `createBackendModule`, extends exactly one plugin through those extension points. Modules are initialized completely before the plugin starts, so the plugin can use what they add. Modules never import private files of another package.

Code must match the design of the app. The new backend uses `backend.add` and default exports, the old one uses glue code in a `plugins` folder, and the frontend and backend choices are independent.

Key facts:

- `createBackendPlugin` takes `pluginId`; `createBackendModule` takes `pluginId` and `moduleId`.
- `coreServices.httpRouter` mounts a plugin under `/api/<pluginId>`.
- Modules start before the plugin they extend.
- The `-node` library package is not added with `backend.add`.

<!-- astrona:playground:destroy -->
