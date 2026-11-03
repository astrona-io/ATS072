---
draft: true
exam_objectives:
- Customizing Backstage plugins
---
# Summary

When configuration is not enough, Backstage offers supported ways to extend a plugin. Each one uses a public contract, and the narrowest contract that meets the need is the best choice.

## What you learned

A backend module is created with `createBackendModule`. It names the `pluginId` it extends and its own `moduleId`, and it asks for extension points and services in `deps`. The catalog offers `catalogProcessingExtensionPoint`, which accepts a processor through `addProcessor`. The package exports the module as `default`, and the backend loads it with `backend.add(import(...))`. A module that is not added, or has the wrong `pluginId`, does nothing.

On the frontend, plugins expose extensions with IDs. The smallest change is the `app.extensions` list in `app-config.yaml`, which can set `config`, `disabled` and `attachTo`. A larger change overrides one extension with `.override` and `withOverrides`. The largest change adds or replaces extensions with `createFrontendModule`. None of these edits the plugin package, and none of them changes what the backend allows.

A permission policy implements `PermissionPolicy.handle`, receives a `PolicyQuery` and an optional user, and returns an object with a `result` of `ALLOW`, `DENY` or `CONDITIONAL`. It compares the permission with `isPermission`, denies explicitly and is registered through a module for the `permission` plugin.

Customizations stay maintainable when versions move together with `backstage-cli versions:bump`, when each customization lists the contract it depends on, and when every private fork has a reason and an owner.

The key facts to remember are these:

- A module needs the right `pluginId`, a `default` export and a `backend.add` line.
- Configure first, override next, and add a module last.
- The backend policy decides access; the interface only presents choices.
- A fork needs an owner, because it must follow every upstream security fix.

<!-- astrona:playground:destroy -->
