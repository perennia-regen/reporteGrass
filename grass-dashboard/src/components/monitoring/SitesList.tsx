'use client';

import { memo } from 'react';
import { Checkbox } from '@/components/ui/checkbox';
import type { MonitorMCP } from '@/types/dashboard';
import type { SiteId } from './hooks/useMapSelection';

interface SitesListProps {
  sites: MonitorMCP[];
  selectedIds: Set<SiteId>;
  onSiteToggle: (id: SiteId) => void;
}

function SitesListComponent({ sites, selectedIds, onSiteToggle }: SitesListProps) {
  return (
    <div className="space-y-1 pl-6">
      {sites.map((site) => {
        const isSelected = selectedIds.has(site.id);
        const siteName = site.nombre || `Sitio ${site.id}`;
        return (
          <label
            key={site.id}
            className="flex items-center gap-2 py-1 px-2 rounded hover:bg-gray-50 cursor-pointer group"
          >
            <Checkbox
              checked={isSelected}
              onCheckedChange={() => onSiteToggle(site.id)}
            />
            <span className="text-sm text-gray-700 group-hover:text-gray-900">
              {siteName}
            </span>
            <span className="ml-auto text-xs text-gray-400">
              ISE: {site.ise2}
            </span>
          </label>
        );
      })}
    </div>
  );
}

export const SitesList = memo(SitesListComponent);
