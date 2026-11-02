---
draft: true
exam_objectives:
- Using Material UI components
---
# Compatible UI Components, Theme Context And Accessible States

Material UI provides reusable React components for common interface needs such as typography, buttons, layout and status presentation. Backstage combines these components with its own portal conventions and application composition. The goal is a consistent experience that developers can understand, rather than a collection of unrelated visual styles for every plugin.

Compatibility begins with the installed library generation. Older Backstage code can use the Material UI generation associated with legacy core components, while newer packages may use different MUI entry points and styling contracts. Imports from different major versions should not be combined casually. The application's package graph and selected frontend architecture determine which component and theme APIs are supported.

A theme supplies shared visual values such as spacing, colors and typography. Components consume that context rather than hard-coding every visual choice independently. This makes a card more likely to fit light and dark themes and organization styling. A custom component that bypasses theme values can remain readable in one appearance while becoming illegible in another.

Consider a catalog page with several status cards. Shared typography and spacing help users scan the page, while consistent status presentation helps them understand what is current, loading or unavailable. Visual consistency should follow information meaning. Using the same reassuring success color for a current healthy status and an unknown stale status would conceal a meaningful difference.

Layout components organize content without deciding its business meaning. Responsive behavior needs attention when a narrow screen or browser zoom changes available space. A status label that truncates its only explanation can become ambiguous. Tables need sensible headings and content structure, while long identifiers may require wrapping or a deliberate presentation strategy. Fixed dimensions should not prevent users from reading the data they came to find.

Controls also need semantic correctness. A button performs an action; a link navigates. An icon-only control needs an accessible name. Keyboard focus should remain visible, and loading behavior should not leave a control apparently active while its action cannot be completed. Component libraries provide useful building blocks, but the author still owns the semantics of the assembled feature.

State presentation is especially important for asynchronous integrations. A loading indicator means a request is pending. An empty state means the request completed without relevant data or that required configuration is absent, according to the feature contract. An error state means an operation failed. Those meanings should not collapse into the same blank space, because users need different next steps for each.

Color alone is insufficient to communicate important states. Text, accessible labels and appropriate semantic relationships make the information available to more users. Tooltips can add context but should not contain the only explanation required to use a feature. A dense card with many decorative icons can increase cognitive work even when every component is technically valid.

Customization should remain aligned with the portal's supported components and theme. A plugin may expose a composition or override point that allows an application-specific card. That mechanism is more maintainable than patching private styles across package internals. Relevant checks include alternate themes, loading and error states, keyboard navigation and realistic long values, rather than only a screenshot of the ideal state.

The visual system does not validate the underlying data or enforce server policy. A well-styled destructive action still needs backend authorization. A card's healthy appearance should follow a supported status contract, not a guess from the existence of an entity. Separating presentation from authority and evidence keeps the interface both attractive and trustworthy.

The Backstage ecosystem also has Backstage UI components and migration paths separate from Material UI. The published examination objective still asks about Material UI, so its component and theme contracts remain the subject here. An application using Backstage UI should follow that system's supported interfaces rather than assume the packages are interchangeable. This distinction reinforces the need to identify the actual dependency generation before adapting an example.

## Common pitfalls

> [!WARNING]
> Match Material UI imports and styling to the installed major version. Avoid color-only status, inaccessible controls and layouts that hide meaningful values. Theme consistency is presentation support; it does not prove data freshness or enforce permissions.
