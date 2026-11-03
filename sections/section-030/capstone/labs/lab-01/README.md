---
estimated_duration: 40m
---

# React Changes In A Backstage App Capstone

Graded lab. **Status: UNTESTED.** It was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

The `FleetPage` is not routed or linked, and its `FleetPanel` loads data badly and asserts an optional owner. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-072-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route.sh` | App.tsx imports FleetPage and routes /fleet inside FlatRoutes |
| `validate-sidebar.sh` | Root.tsx has a SidebarItem for fleet with an icon and a text |
| `validate-data-access.sh` | FleetPanel reads the catalog through useApi(catalogApiRef) inside useAsync, without fetch |
| `validate-states.sh` | FleetPanel renders Progress while loading and ResponseErrorPanel on error |
| `validate-empty-and-keys.sh` | FleetPanel has an empty state and keys that come from the entity reference |
| `validate-optional-owner.sh` | FleetRow treats owner as optional and FleetPanel does not assert it |
| `validate-accessibility.sh` | FleetPanel has a polite live region and a labelled list |

The validation scripts read the files with `python3` from the standard library. Nothing runs `yarn`, `node` or a build, and comment-only matches do not count.
