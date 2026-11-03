# React Components, Props And Hooks - Playground

This virtual machine holds a small Backstage-style monorepo in `/home/candidate/backstage-app`. It has no `node_modules` and no network need. You read and edit the files with `nano` or `vim`, and you search them with `grep`.

## Layout

| Path | Purpose |
| --- | --- |
| `app-config.yaml` | App configuration (title, base URLs, catalog location) |
| `packages/app/src/App.tsx` | The app: imports pages and lists routes in `FlatRoutes` |
| `packages/app/src/components/Root/Root.tsx` | The sidebar |
| `plugins/scout-status/src/index.ts` | The plugin exports |
| `plugins/scout-status/src/components/ScoutStatusPage` | The page that composes the components |
| `plugins/scout-status/src/components/OutpostCard` | A function component with typed props |
| `plugins/scout-status/src/components/CrewCounter` | A component with `useState` and `useEffect` |

The playground has the finished version: the page is routed at `/scout-status`, the sidebar has an entry, the card takes `name` and `crew`, and the effect lists its dependencies.

## Commands to try

```sh
cd ~/backstage-app
grep -n "Route" packages/app/src/App.tsx
grep -n "SidebarItem" packages/app/src/components/Root/Root.tsx
grep -rn "useEffect" plugins
```

## Ideas

Remove `[outpost, count]` from the effect and read what the code now says. Make `crew` required in `OutpostCardProps` and find the places that would stop type checking. Add a second route and a second sidebar item for a page of your own. Nothing in this virtual machine builds the app, so you check your work by reading.
