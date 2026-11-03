# Backend Plugins, Modules, Services And Extension Points - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-072-playground-010-02
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A virtual machine with a Backstage-style project: a backend plugin, a catalog module, the frontend plugin that calls the backend. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-072-playground-010-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (a qemu virtual machine) |
| `bootstrap/prepare.sh` | Writes the example project to `/home/candidate/backstage-app` |
| `docs/overview.md` | What the project contains and ideas to try |
