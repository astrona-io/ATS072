# Frontend Plugins And The Frontend System - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-072-playground-010-01
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A virtual machine with a Backstage-style project: a frontend plugin registered in the app, a backend plugin and a catalog module. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-072-playground-010-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (a qemu virtual machine) |
| `bootstrap/prepare.sh` | Writes the example project to `/home/candidate/backstage-app` |
| `docs/overview.md` | What the project contains and ideas to try |
