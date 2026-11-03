# Configuring Plugins With app-config.yaml - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-072-playground-020-01
- **Type:** Astrona playground - clean environment, no task, no grading

**UNTESTED**: built with static checks only. A virtual machine (qemu, Ubuntu 24.04) with a Backstage-style repository in `/home/candidate/backstage-app`. It has no `node_modules` and does not run Backstage. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-072-playground-020-01
```

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition |
| `bootstrap/prepare.sh` | Writes the repository files |
| `docs/overview.md` | What the repository contains and ideas to try |
