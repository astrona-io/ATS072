# Question

Solve this question on: `terminal`

The `scout-status` plugin in `/home/candidate/backstage-app` gives the Starfleet portal a page about the outposts. The page, the card and the counter exist, but the portal does not show the page, and the components ignore the data the page could give them. Change the source files so the feature works. Do not delete any component file and do not change `package.json` files.

1. In `packages/app/src/App.tsx`, import `ScoutStatusPage` from `@internal/plugin-scout-status` and add a route with the path `/scout-status` that renders `<ScoutStatusPage />` inside `FlatRoutes`. Keep the existing catalog route.

2. In `packages/app/src/components/Root/Root.tsx`, add a `SidebarItem` inside the `Menu` group. It uses `ExtensionIcon`, links to `scout-status` and has a text. Keep the existing `Home` item.

3. In `OutpostCard.tsx`, replace the fixed text with props. Declare an `OutpostCardProps` interface with `name: string` and an optional `crew?: number`. Render the name in the `h3`. When `crew` is `undefined`, show `Crew not recorded`. Do not assert that `crew` is always present.

4. In `CrewCounter.tsx`, the effect that sets `document.title` runs after every render. Give it a dependency array that lists every value from the component that the effect reads.

5. In `ScoutStatusPage.tsx`, pass `name="outpost-alpha"` and `crew={12}` to `OutpostCard`, and `outpost="outpost-alpha"` to `CrewCounter`.

Nothing is built or started in this virtual machine. The checks read the files.
