# Question

Solve this question on: `terminal`

The `OutpostStatusCard` in the `scout-status` plugin of `/home/candidate/backstage-app` must list the outposts from the Backstage catalog. The first version calls `fetch` while it renders and uses the list position as the key. Rewrite `plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx`. Do not change other files.

1. Remove the `fetch` call. Get the catalog client with `useApi(catalogApiRef)`. Import `useApi` from `@backstage/core-plugin-api` and `catalogApiRef` from `@backstage/plugin-catalog-react`.

2. Load the entities with `useAsync` from `react-use`. Call `catalogApi.getEntities` inside an async callback, pass a `filter`, and give `useAsync` a dependency array that contains `catalogApi`. Read `value`, `loading` and `error` from the result.

3. While `loading` is true render `<Progress />`. When `error` is set render `<ResponseErrorPanel error={error} />`. Both components come from `@backstage/core-components`.

4. When the load succeeds with no entities, render a paragraph that starts with `No outposts`. When it succeeds with entities, render a list. Each `li` has a `key` built with `stringifyEntityRef(entity)` from `@backstage/catalog-model`, not the list position.

5. Wrap all states in an element with `aria-live="polite"` and give the `ul` an `aria-label`.

The `OutpostStatusCard` is the only file that needs changes. Nothing is built or started in this virtual machine.
