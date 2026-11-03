---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# Asynchronous Catalog Data In React

This module teaches how a Backstage frontend component reads data from the software catalog. You rewrite an `OutpostStatusCard` in a playground virtual machine so that it gets the catalog client with `useApi`, loads entities with `useAsync`, shows loading, empty, success and error states, and renders an accessible list with stable keys.

<!-- astrona:playground -->

## Learning Goals

- Get the catalog client with `useApi(catalogApiRef)` and explain why a component does not call `fetch` itself.
- Run an asynchronous request with `useAsync`, set its dependencies and tell apart `loading`, `error`, an empty result and data.
- Render states with `Progress` and `ResponseErrorPanel` from `@backstage/core-components`.
- Use keys from the entity reference and give the output a live region and a list label.

## Before You Start

You need to know what a function component, props, `useState` and `useEffect` are. The playground is a virtual machine with a Backstage-style project in `/home/candidate/backstage-app`. It has no `node_modules` and does not build the app. You change files with `nano` or `vim` and check them with `grep` and `cat`.

## Reading Order

1. Reading Catalog Data With useApi And catalogApiRef
2. Loading, Empty, Success And Error States
3. Stable Keys And Accessible Output
4. Summary

The graded lab comes after the third reading.
