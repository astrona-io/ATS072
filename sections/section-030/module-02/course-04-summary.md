---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# Summary

A Backstage component does not build its own catalog request. It asks the app for the catalog client with `useApi(catalogApiRef)`, and the app supplies the base URL and the authentication. The request runs in `useAsync`, because a render function is synchronous and must not repeat requests. The dependency array lists every value the request reads, so the request runs again only when one of them changes.

A request has four outcomes: loading, error, an empty result and data. The card gives each outcome its own screen. `Progress` shows waiting, `ResponseErrorPanel` shows the error, a short message shows the empty result and a list shows the data. Mixing the outcomes misleads the user: an error is not an empty catalog, and a timeout does not prove that no data exists.

A list needs a stable key for each item. The entity reference from `stringifyEntityRef` is unique and stays the same when the list is reordered, while the list position and a random value do not. Optional catalog fields are typed as optional and narrowed with a check instead of an assertion. A live region with `aria-live="polite"` and a labelled list make the states available to assistive technology, and status is never shown by color alone. The backend, not the card, decides who may read which entity.

- `useApi` returns the object behind an `ApiRef`.
- `useAsync` returns `value`, `loading` and `error`.
- A key is unique among siblings and stable over time.
- Frontend code shows data; the backend authorizes it.

<!-- astrona:playground:destroy -->
