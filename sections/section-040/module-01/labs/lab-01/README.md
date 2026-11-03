---
estimated_duration: 25m
---

# Material UI Components In Backstage

**Status: UNTESTED.** Built without booting the environment; run `astrona test -c .` before relying on it. Open risk: the static checks accept the reference solution but were not run in a booted machine.

The project is a small Backstage-style monorepo in `/home/candidate/backstage-app` with no `node_modules`. Nothing builds or starts Backstage; the checks read the source files with `grep` and `python3`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-072-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-card-uses-v4-imports.sh` | Typography, Button and makeStyles come from @material-ui/core in the card |
| `validate-list-uses-v4-grid.sh` | Grid container and item from v4, no sx prop |
| `validate-no-mui-v5-in-plugin.sh` | No @mui import or dependency |
| `validate-imports-match-dependencies.sh` | Imported libraries are declared and all v4 |
| `validate-card-uses-infocard.sh` | InfoCard from core-components and theme.spacing |
