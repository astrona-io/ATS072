---
estimated_duration: 30m
---

# Themes, Layout And Accessible Status States

**Status: UNTESTED.** Built without booting the environment; run `astrona test -c .` before relying on it. Open risk: the static checks accept the reference solution but were not run in a booted machine.

The project is a small Backstage-style monorepo in `/home/candidate/backstage-app` with no `node_modules`. Nothing builds or starts Backstage; the checks read the source files with `grep` and `python3`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-072-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-theme-created.sh` | scoutTheme built with createUnifiedTheme and palettes.light |
| `validate-theme-registered.sh` | createApp themes entry with UnifiedThemeProvider |
| `validate-status-has-text.sh` | Status components with visible words |
| `validate-no-hard-coded-colours.sh` | No colour literals in the plugin |
| `validate-panel-uses-theme-tokens.sh` | Theme palette and spacing in ScoutPanel |
| `validate-icon-button-has-label.sh` | aria-label on every IconButton |
