---
estimated_duration: 30m
---

# Asynchronous Catalog Data Lab

Graded lab. **Status: UNTESTED.** It was built without booting the virtual machine. Only `astrona validate`, `bash -n` and YAML parsing were run. Run `astrona test -c .` before relying on it.

The `OutpostStatusCard` loads data while it renders and uses the list position as the key. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS072.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-072-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-use-api.sh` | The card reads the catalog through useApi(catalogApiRef) and does not call fetch |
| `validate-use-async.sh` | getEntities runs inside useAsync with the catalog API as a dependency |
| `validate-states.sh` | The card renders Progress while loading and ResponseErrorPanel for an error |
| `validate-empty-and-keys.sh` | An empty result has its own message and list keys come from the entity reference |
| `validate-accessibility.sh` | The output has a polite live region and a labelled list |

The validation scripts read the files with `python3` from the standard library. Nothing runs `yarn`, `node` or a build, and comment-only matches do not count.
