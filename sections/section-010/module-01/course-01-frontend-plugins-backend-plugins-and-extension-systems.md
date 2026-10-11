---
draft: true
exam_objectives:
- Understand frontend versus backend plugins
---
# Frontend Plugins, Backend Plugins And Extension Systems

Backstage plugins divide responsibilities across browser and server boundaries. A frontend plugin can provide a page, card, route or client API integration. A backend plugin can provide HTTP routes, database work, scheduled processing or privileged calls to another system. Some features require both. Their packages may be installed together, but their security and lifecycle responsibilities remain separate.

For example, a delivery feature can include a frontend card that displays release status and a backend plugin that retrieves status from a protected controller. The browser component should receive only the data and actions its caller is permitted to use. The server holds the integration credential and enforces the relevant permission boundary. A shared feature name does not justify shipping the credential in the frontend bundle.

The current backend system assembles plugins, modules and services. A backend plugin provides its own feature. A module extends a particular plugin through supported extension points and is installed in the same backend instance as that plugin. Services provide facilities such as configuration, logging, routing or database access through declared interfaces. This composition avoids requiring every plugin to implement all infrastructure concerns itself.

An extension point is a supported customization contract owned by a plugin. A module can register an additional processor or action through that contract. It should not depend on arbitrary private implementation files. Private imports can appear to work initially while breaking on an update because they were never a supported interface. A stable extension contract makes the customization understandable to both plugin and application authors.

Initialization order matters. Modules register their extensions before the target plugin completes its own initialization. This lets the plugin start with the intended extensions available. A module that tries to change an extension point after initialization can violate the lifecycle contract. The exact APIs belong to the installed backend-system version, so instructions from another architecture need deliberate interpretation.

Frontend composition also has architecture generations. Existing applications may use legacy plugin and route wiring, while newer frontend systems use their own plugin, extension and override mechanisms. A package's newer entry point may be different from its legacy entry point. An author should identify the application's selected system before choosing installation code, rather than combining examples that assume incompatible models.

Installing the dependency does not register the feature by itself in every arrangement. The application must discover or explicitly add the required extension, provide configuration and connect supporting APIs. A blank page can therefore result from missing composition even though package installation succeeded. The diagnosis should distinguish an unavailable package, an unregistered feature and a backend route that failed to initialize.

Services and modules also define deployment boundaries. A module belongs with the plugin it extends, while independent plugins communicate through supported APIs rather than direct private calls. Splitting backends for isolation or scale requires corresponding discovery and identity configuration. Copying a package to another deployment is not sufficient to preserve its runtime dependencies.

Good feature review explains both sides of the boundary. The frontend handles loading, absent data and errors accessibly. The backend validates input, checks permissions and protects secrets. Shared types help describe the response but do not replace runtime validation. The user sees one integrated feature because those contracts agree, not because the browser and server are the same execution environment.

## Common pitfalls

> [!WARNING]
> Match plugin wiring to the application's architecture generation. A backend module extends a specific plugin through supported contracts; it is not an unrestricted hook into every plugin. Package installation alone does not prove registration, configuration or server authorization.
