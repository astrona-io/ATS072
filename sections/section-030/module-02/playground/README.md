# Asynchronous Catalog Data In React - Playground

- **Slug:** ats-072-playground-030-02
- **Type:** Astrona playground, clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A virtual machine with a small Backstage app whose `OutpostStatusCard` reads the catalog with `useApi`, `useAsync`, `Progress` and `ResponseErrorPanel`.

## Run it

```sh
astrona run -c sections/section-030/module-02/playground
astrona destroy ats-072-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (a qemu virtual machine) |
| `bootstrap/prepare.sh` | Writes the Backstage app to `/home/candidate/backstage-app` |
| `docs/overview.md` | What the app contains and what to try |
