# Material UI Components In Backstage - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-072-playground-040-01
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A qemu virtual machine (Ubuntu 24.04) with a Backstage-style project in `/home/candidate/backstage-app`: configuration, TypeScript and React source files, no `node_modules`. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-072-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (qemu image and bootstrap) |
| `bootstrap/01-setup.sh` | Writes the project files into `/home/candidate/backstage-app` |
| `docs/overview.md` | What the project contains and commands to try |
