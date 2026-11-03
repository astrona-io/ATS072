# React Components, Props And Hooks - Playground

- **Slug:** ats-072-playground-030-01
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A virtual machine with a small Backstage app whose `scout-status` plugin already has a routed page, a sidebar entry, typed props and an effect with dependencies.

## Run it

```sh
astrona run -c sections/section-030/module-01/playground
astrona destroy ats-072-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (a qemu virtual machine) |
| `bootstrap/prepare.sh` | Writes the Backstage app to `/home/candidate/backstage-app` |
| `docs/overview.md` | What the app contains and what to try |
