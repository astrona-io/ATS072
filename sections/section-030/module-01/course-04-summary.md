---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# Summary

A React component in a Backstage app is a function that receives props and returns JSX. The parent owns the data and passes it down, and the child only turns it into elements. An optional prop is typed with a question mark, and the component shows an explicit text for the missing case instead of asserting that the value exists. Rendering stays a calculation, so requests and other outside actions do not belong in the body of the function.

State and effects handle values that change over time. `useState` stores a value for one component instance and asks React to render again when the value changes. `useEffect` runs after the page update, and its dependency array must list every prop and state value that the effect reads. A missing array runs the effect after every render, and a missing value leaves the effect working with stale data. Hooks are called at the top level of a component in the same order on every render.

A component reaches users through two separate changes. `App.tsx` imports the page from the plugin package and lists a `Route` inside `FlatRoutes`, and the plugin's `src/index.ts` must export the page. `Root.tsx` holds a `SidebarItem` with an icon component, a `to` path and a text, which only links to the address. When a page does not appear, check the plugin export, the import, the route path and the sidebar `to` value in that order.

- A component name starts with a capital letter.
- Props flow from parent to child and are not changed by the child.
- The dependency array lists everything the effect reads.
- A route and a sidebar entry are separate edits.

<!-- astrona:playground:destroy -->
