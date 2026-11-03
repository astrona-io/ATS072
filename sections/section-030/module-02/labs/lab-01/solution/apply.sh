#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -eu

APP=/home/candidate/backstage-app

mkdir -p "$APP/plugins/scout-status/src/components/OutpostStatusCard"
cat > "$APP/plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx" <<'ASTRONA_FILE_EOF'
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
ASTRONA_FILE_EOF

echo "[solution] Applied."
