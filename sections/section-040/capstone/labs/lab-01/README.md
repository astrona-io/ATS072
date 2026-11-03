---
estimated_duration: 40m
---

# Capstone: Using Material UI Components

**Status: UNTESTED.** Built without booting the environment; run `astrona test -c .` before relying on it. Open risk: the static checks accept the reference solution but were not run in a booted machine.

The project is a small Backstage-style monorepo in `/home/candidate/backstage-app` with no `node_modules`. Nothing builds or starts Backstage; the checks read the source files with `grep` and `python3`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-072-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-one-material-ui-generation.sh` | No @mui in the app or the plugin; v4 imports in the card |
| `validate-grid-and-infocard-layout.sh` | Grid container and items, InfoCard |
| `validate-theme-created-and-registered.sh` | Theme created and registered |
| `validate-colours-from-theme-tokens.sh` | No colour literals, theme tokens in the panel |
| `validate-status-has-text.sh` | Status components with words |
| `validate-icon-button-has-label.sh` | aria-label on IconButton |
| `validate-states-are-distinct.sh` | Progress, ResponseErrorPanel and EmptyState in order |
| `validate-refresh-calls-retry.sh` | The refresh button is wired to retry |
