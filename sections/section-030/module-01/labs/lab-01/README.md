---
estimated_duration: 25m
---

# React Components, Props And Hooks Lab

Graded lab. **Status: UNTESTED.** It was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

The `scout-status` plugin has a page, a card and a counter, but the page is not routed, the sidebar has no entry and the components ignore their props. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-072-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-route.sh` | App.tsx imports ScoutStatusPage and routes /scout-status inside FlatRoutes |
| `validate-sidebar.sh` | Root.tsx has a SidebarItem for scout-status with an icon and a text |
| `validate-props.sh` | OutpostCard takes typed name and optional crew props and shows them |
| `validate-effect.sh` | The CrewCounter effect lists outpost and count as dependencies |
| `validate-composition.sh` | ScoutStatusPage passes name and crew to OutpostCard and outpost to CrewCounter |

The validation scripts read the files with `python3` from the standard library. Nothing runs `yarn`, `node` or a build, and comment-only matches do not count.
