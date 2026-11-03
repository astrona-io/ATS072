# Solution

Open the file:

```sh
cd ~/backstage-app
nano plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx
```

Replace the whole content with the version below, then run `astrona submit`.

```tsx
import React from 'react';
import useAsync from 'react-use/lib/useAsync';
import { Progress, ResponseErrorPanel } from '@backstage/core-components';
import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { stringifyEntityRef } from '@backstage/catalog-model';

export const OutpostStatusCard = () => {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const response = await catalogApi.getEntities({
      filter: { kind: 'Component', 'spec.type': 'outpost' },
    });
    return response.items;
  }, [catalogApi]);

  const outposts = value ?? [];

  return (
    <div aria-live="polite" aria-busy={loading}>
      {loading && <Progress />}
      {error && <ResponseErrorPanel error={error} />}
      {!loading && !error && outposts.length === 0 && (
        <p>No outposts found in the catalog.</p>
      )}
      {!loading && !error && outposts.length > 0 && (
        <ul aria-label="Outposts">
          {outposts.map(entity => (
            <li key={stringifyEntityRef(entity)}>
              {entity.metadata.title ?? entity.metadata.name}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};
```

Why each part is there. `useApi(catalogApiRef)` asks the app for the catalog client, so the card does not build URLs or tokens. `useAsync` runs the callback after the first render and again only when `catalogApi` changes, so a rerender does not send a second request. The four branches separate waiting, failure, an empty answer and data. The key `stringifyEntityRef(entity)` gives `component:default/outpost-alpha`, which stays the same when the list order changes.

Run `astrona submit` again to see the five checks.
