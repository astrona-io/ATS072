# Solution

Start in the app directory:

```sh
cd ~/backstage-app
find . -type f | sort
```

Step 1. In `packages/app/src/App.tsx` add the import and the route:

```tsx
import { FleetPage } from '@internal/plugin-scout-status';
```

```tsx
<Route path="/fleet" element={<FleetPage />} />
```

Step 2. In `Root.tsx`, inside the `Menu` group:

```tsx
<SidebarItem icon={ExtensionIcon} to="fleet" text="Fleet status" />
```

Step 3 to 7. Replace `FleetRow.tsx` with:

```tsx
import React from 'react';

export interface FleetRowProps {
  name: string;
  owner?: string;
}

export const FleetRow = ({ name, owner }: FleetRowProps) => (
  <li>
    {name}: {owner ?? 'Owner not recorded'}
  </li>
);
```

Replace `FleetPanel.tsx` with:

```tsx
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import { Progress, ResponseErrorPanel } from '@backstage/core-components';
import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { stringifyEntityRef } from '@backstage/catalog-model';
import { FleetRow } from '../FleetRow';

export const FleetPanel = () => {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const response = await catalogApi.getEntities({
      filter: { kind: 'Component' },
    });
    return response.items;
  }, [catalogApi]);

  const ships = value ?? [];

  return (
    <div aria-live="polite" aria-busy={loading}>
      {loading && <Progress />}
      {error && <ResponseErrorPanel error={error} />}
      {!loading && !error && ships.length === 0 && (
        <p>No ships found in the catalog.</p>
      )}
      {!loading && !error && ships.length > 0 && (
        <ul aria-label="Fleet">
          {ships.map(entity => (
            <FleetRow
              key={stringifyEntityRef(entity)}
              name={entity.metadata.name}
              owner={
                typeof entity.spec?.owner === 'string'
                  ? entity.spec.owner
                  : undefined
              }
            />
          ))}
        </ul>
      )}
    </div>
  );
};
```

Run `astrona submit` after each step to see which check turns green. The route and the sidebar item are separate changes: the route makes the page reachable at `/fleet`, and the sidebar item only links to that path.
