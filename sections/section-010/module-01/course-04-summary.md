---
draft: true
exam_objectives:
- Understand frontend versus backend plugins
---
# Summary

A frontend plugin is a package that runs in the browser and gives pages and components to a Backstage app. In the legacy system it has an entry point, a plugin object made with `createPlugin`, routable extensions made with `createRoutableExtension`, route references and React components. The components load data by asking the discovery API for the base URL of a backend plugin id and calling it with the fetch API.

A plugin package does nothing until the app uses it. In the legacy system the app package needs a workspace dependency, an import of the extension and a `Route` inside `FlatRoutes`. Each step fails in its own way: a build error for a missing dependency, a missing page for a missing route. A commented-out route registers nothing, and a sidebar link is a separate step.

The new frontend system describes a plugin with `createFrontendPlugin`, a `pluginId` and a list of extensions. A page is made with `PageBlueprint`, which carries its own path and loader. The app passes plugins in the `features` array of `createApp` from `@backstage/frontend-defaults`, or the Backstage command-line tool discovers them. The package default-exports the plugin.

The two systems cannot be mixed without a compatibility layer, so the import of `createApp` in `App.tsx` decides which plugin API fits. In both systems the frontend holds no secrets and reaches the server through the backend plugin id.

Key facts:

- `createPlugin` takes `id`; `createFrontendPlugin` takes `pluginId`.
- Legacy pages need a dependency, an import and a route in `FlatRoutes`.
- New pages are extensions made with `PageBlueprint` and listed in `features`.
- The discovery API finds a backend by plugin id.

<!-- astrona:playground:destroy -->
