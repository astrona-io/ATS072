# Asynchronous Catalog Data In React - Playground

This virtual machine holds a small Backstage-style monorepo in `/home/candidate/backstage-app`. It has no `node_modules` and no network need. You read and edit the files with `nano` or `vim`, and you search them with `grep`.

## Layout

| Path | Purpose |
| --- | --- |
| `app-config.yaml` | App configuration, including the catalog location |
| `catalog/outposts.yaml` | Three example `Component` entities of type `outpost` |
| `packages/app/src/App.tsx` | Routes, including `/scout-status` |
| `plugins/scout-status/src/components/ScoutStatusPage` | The page |
| `plugins/scout-status/src/components/OutpostStatusCard` | The card that loads the catalog data |

The card is the finished version. It uses `useApi(catalogApiRef)`, `useAsync`, `Progress`, `ResponseErrorPanel`, an empty-state message, keys from `stringifyEntityRef` and a live region.

## Commands to try

```sh
cd ~/backstage-app
cat plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx
grep -n "key=" -r plugins
cat catalog/outposts.yaml
```

## Ideas

Change the `filter` to another `spec.type`. Add a `title` to one entity and read how the card chooses between `title` and `name`. Change the dependency array from `[catalogApi]` to `[]` and decide what would change for a card that gets a filter from a prop. Nothing in this virtual machine builds the app, so you check your work by reading.
