---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# Make changes to React code in Backstage App

This section covers the React code behind a Backstage app. You work in a playground virtual machine that holds a small Backstage-style project, edit TypeScript and TSX files, and check the result with the validation scripts of the graded labs. The first module covers function components, props, hooks, routes and the sidebar. The second module covers asynchronous catalog data with `useApi`, `catalogApiRef` and `useAsync`, the four request states, stable keys and accessible output.

Each module has a playground, a graded lab after its readings and a summary. The section ends with a capstone lab that combines both modules and a quiz.

## Learning Outcomes

- Write function components with typed props, `useState` and `useEffect`, and use a correct dependency array.
- Register a plugin page with a `Route` in `App.tsx` and a `SidebarItem` in the sidebar component.
- Read catalog data with `useApi(catalogApiRef)` and `useAsync`, and render loading, empty, success and error states with `Progress` and `ResponseErrorPanel`.
- Use stable keys and accessible output, and keep authorization on the backend.
