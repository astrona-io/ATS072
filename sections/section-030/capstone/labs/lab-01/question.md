# Question

Solve this question on: `terminal`

The Starfleet portal in `/home/candidate/backstage-app` needs a fleet page. The `FleetPage`, `FleetPanel` and `FleetRow` components exist in the `scout-status` plugin, but the portal does not show them, and the panel is unsafe: it loads data while it renders, shows nothing while waiting or after a failure, keys the rows by position and asserts that every owner is a string. Fix the source files. Do not delete files or change `package.json` files.

1. Register the page. In `packages/app/src/App.tsx`, import `FleetPage` from `@internal/plugin-scout-status` and add `<Route path="/fleet" element={<FleetPage />} />` inside `FlatRoutes`. Keep the catalog route.

2. Add a sidebar entry. In `Root.tsx`, add a `SidebarItem` with `ExtensionIcon`, `to="fleet"` and a text inside the `Menu` group. Keep the `Home` item.

3. Load the catalog data correctly in `FleetPanel.tsx`. Remove `fetch`. Use `useApi(catalogApiRef)` and call `getEntities` inside `useAsync` with `catalogApi` in the dependency array.

4. Show the states. Render `<Progress />` while loading and `<ResponseErrorPanel error={error} />` on failure.

5. Handle an empty answer with a paragraph that starts with `No ships`. Give every `FleetRow` a `key` from `stringifyEntityRef(entity)`, never the position.

6. Treat the owner as optional. In `FleetRow.tsx` make `owner` optional and render `Owner not recorded` when it is missing. Remove `toUpperCase`. In `FleetPanel.tsx` remove the `as string` assertion and pass the owner only when it is a string.

7. Make the output accessible. Wrap the states in an element with `aria-live="polite"` and give the `ul` an `aria-label`.

Nothing is built or started in this virtual machine. The checks read the files.
