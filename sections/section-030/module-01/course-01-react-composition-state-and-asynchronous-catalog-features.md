---
draft: true
exam_objectives:
- Make changes to React code in Backstage App
---
# React Composition, State And Asynchronous Catalog Features

React components describe what the user should see from their current inputs. Properties supply data and callbacks from surrounding composition. State records local information that changes over time. In Backstage, these components form pages, entity cards, navigation and interactive plugin features. Keeping their responsibilities clear helps a visual feature remain understandable as catalog data and integration responses change.

Rendering should derive interface output rather than perform an uncontrolled external action. A component can show a service's name from an entity property without mutating the entity during every render. External requests belong in the appropriate lifecycle and API abstraction, not in repeated rendering logic. Otherwise a harmless rerender can produce duplicate requests or actions with consequences beyond the interface.

Hooks organize state and lifecycle behavior within the selected React model. Their call order must remain consistent; conditional hook calls can break that contract. Dependencies for an effect determine when it should rerun as inputs change. Omitting a relevant entity identifier can leave a card showing information from the previously selected entity. Including unstable values unnecessarily can trigger repeated fetching.

Consider a build-status card. It first needs the entity's supported external identifier. If that identifier is absent, the useful state may be a clear configuration explanation or an intentionally hidden card. If the identifier exists, the card can request status through the application's frontend API. While waiting it shows a loading state. A failed request and a successful response with no runs need different messages.

Those distinctions protect users from false conclusions. A request timeout is not proof that the service has never built. An absent annotation is not proof that the source host is unavailable. A successfully returned old build should not be presented as a current deployment without explaining the data's meaning and freshness. The component's contract should reflect the evidence it actually receives.

Asynchronous lifecycle also needs attention. A user can navigate to another entity while a previous request is still outstanding. The implementation should prevent the old response from overwriting the new entity's state, using the applicable request and lifecycle handling. A stable entity reference is more reliable than a display title for identifying which response belongs to which view.

List rendering needs stable keys corresponding to the actual items. An array position can be misleading when items are inserted or reordered, causing state to follow the wrong visual row. Component properties should express optionality truthfully. Asserting that every entity has an owner or annotation can suppress a type warning without eliminating the missing-data path.

Accessibility belongs to the feature design. Loading and failure states should be understandable to assistive technology, controls need useful labels, and keyboard interaction should remain available. A colorful icon alone should not communicate the difference between healthy and failing states. Shared Backstage and compatible Material UI components can help, but their use does not automatically make every composition accessible.

Frontend changes should use supported app APIs and the selected composition architecture. A legacy component route and a newer extension definition can have different installation contracts. The backend remains responsible for sensitive authorization and external credentials. A polished browser component improves interaction while the server maintains the actual authority boundary.

A small rendering example distinguishes a missing optional value explicitly:

```tsx
function OwnerLabel({ owner }: { owner?: string }) {
  return <span>{owner ?? 'Owner not recorded'}</span>;
}
```

This fragment derives visible text from a property. It does not fetch data, mutate an entity or enforce permission. An absent value gets truthful presentation instead of a type assertion that pretends every entity has an owner.

## Common pitfalls

> [!WARNING]
> Avoid external actions during rendering, conditional hook calls and stale responses associated with the wrong entity. Model missing data separately from request failure. A disabled button or hidden component does not replace backend permission enforcement.
