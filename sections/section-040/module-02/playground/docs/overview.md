# Overview: Themes, Layout And Accessible Status States (Playground)

This is a playground, not a lab. It starts a virtual machine with a small Backstage-style project and then waits. There is no task, no `astrona submit` and no pass or fail. Edit files, search them, break them on purpose and restore them.

## What is in the machine

The project is in `/home/candidate/backstage-app`. It has no `node_modules`, so nothing here builds or starts Backstage. You work with the source files only. The editors `nano` and `vim` are installed, and so are `grep`, `sed`, `awk`, `cat` and `python3`.

| Path | What it is |
| --- | --- |
| `app-config.yaml` | Application configuration of the example portal |
| `packages/app/src/App.tsx` | Creates the app and registers the theme |
| `packages/app/src/theme/scoutTheme.ts` | The custom theme created with `createUnifiedTheme` |
| `packages/backend/src/index.ts` | A minimal new-backend-system entry point |
| `plugins/scout-status/package.json` | Dependencies of the plugin, including `@material-ui/core` (Material UI v4) |
| `plugins/scout-status/src/plugin.ts` | The plugin and its routable page extension |
| `plugins/scout-status/src/hooks/useScoutStatus.ts` | Loads scout data with `useAsyncRetry` |
| `plugins/scout-status/src/components/` | `ScoutStatusPage`, `ScoutList`, `ScoutStatusCard`, `ScoutStatusBadge`, `ScoutPanel` and `ScoutToolbar` |

The project starts in a working state: one Material UI generation, a registered theme, status components with text and an icon button with an accessible name.

## Commands to try

```sh
cd ~/backstage-app
cat packages/app/src/theme/scoutTheme.ts
grep -n "themes\|UnifiedThemeProvider" packages/app/src/App.tsx
grep -rnE "#[0-9a-fA-F]{3,8}" plugins packages --include=*.ts --include=*.tsx
grep -rn "aria-label" plugins/scout-status/src
cat plugins/scout-status/src/components/ScoutStatusBadge.tsx
```

Try changing the `primary` colour in `scoutTheme.ts`, removing the `aria-label` from `ScoutToolbar.tsx`, or replacing a `Status*` component with a coloured `span`, and then search the files again.

Copy a file before you change it, for example `cp plugins/scout-status/src/components/ScoutStatusCard.tsx /tmp/ScoutStatusCard.tsx.orig`, so you can put it back.

## Start over

Run `astrona destroy ats-072-playground-040-02` and start the playground again to get the original files.
