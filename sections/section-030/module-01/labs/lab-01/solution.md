# Solution

Start in the app directory and list the files:

```sh
cd ~/backstage-app
find . -type f | sort
```

Step 1. Open `packages/app/src/App.tsx` with `nano`. Add the import below the `CatalogIndexPage` import and the route as the last child of `FlatRoutes`:

```tsx
import { ScoutStatusPage } from '@internal/plugin-scout-status';
```

```tsx
<Route path="/scout-status" element={<ScoutStatusPage />} />
```

Run `astrona submit` and read the feedback for the first check.

Step 2. Open `packages/app/src/components/Root/Root.tsx`. Add this line under the `Home` item, inside the same `SidebarGroup`:

```tsx
<SidebarItem icon={ExtensionIcon} to="scout-status" text="Scout status" />
```

`ExtensionIcon` is already imported at the top of the file. Submit again.

Step 3. Replace the content of `plugins/scout-status/src/components/OutpostCard/OutpostCard.tsx`:

```tsx
import React from 'react';

export interface OutpostCardProps {
  name: string;
  crew?: number;
}

export const OutpostCard = ({ name, crew }: OutpostCardProps) => {
  return (
    <div>
      <h3>{name}</h3>
      <p>{crew === undefined ? 'Crew not recorded' : `Crew: ${crew}`}</p>
    </div>
  );
};
```

The `crew` property is optional, so the component must handle `undefined` instead of using `crew!` or `as number`.

Step 4. In `CrewCounter.tsx`, the effect reads `outpost` and `count`. Change its end from `});` to:

```tsx
  }, [outpost, count]);
```

Without the array the effect runs after every render. With the array it runs only when one of the two values changes.

Step 5. In `ScoutStatusPage.tsx`, change the two elements:

```tsx
<OutpostCard name="outpost-alpha" crew={12} />
<CrewCounter outpost="outpost-alpha" />
```

Run `astrona submit` again. All five checks pass when every change is in place.
