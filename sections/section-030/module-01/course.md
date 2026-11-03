---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# React Components, Props And Hooks In A Backstage App

This module teaches the React code that sits behind every visible Backstage feature. You edit a small `scout-status` plugin in a playground virtual machine: a function component with props, a component with state and an effect, and the wiring that makes the page appear in the portal.

<!-- astrona:playground -->

## Learning Goals

- Write a function component in TSX and pass typed props to it, including an optional prop with an explicit missing-value text.
- Use `useState` and `useEffect` with a correct dependency array and follow the rules of hooks.
- Register a plugin page with a `Route` in `packages/app/src/App.tsx` and add a `SidebarItem` in `Root.tsx`.

## Before You Start

You need to read TypeScript at a basic level: variables, functions and objects. The playground is a virtual machine with a Backstage-style project in `/home/candidate/backstage-app`. It has no `node_modules` and does not build the app. You change files with `nano` or `vim` and check them with `grep` and `cat`.

## Reading Order

1. JSX, Function Components And Props
2. State And Effects With Hooks
3. Composing Pages In App.tsx, Routes And The Sidebar
4. Summary

The graded lab comes after the third reading.
