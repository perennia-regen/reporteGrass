'use client';

import { useState, useCallback, useMemo } from 'react';

// Tipo de ID de sitio que puede ser string o number
export type SiteId = string | number;

export interface UseMapSelectionOptions {
  initialStratumIds?: string[];
  initialSiteIds?: SiteId[];
}

export interface UseMapSelectionReturn {
  // Estado de selección
  selectedStratumIds: Set<string>;
  selectedSiteIds: Set<SiteId>;

  // Acciones para estratos
  toggleStratum: (id: string) => void;
  selectAllStrata: (stratumIds: string[], selected: boolean) => void;
  isStratumSelected: (id: string) => boolean;

  // Acciones para sitios
  toggleSite: (id: SiteId) => void;
  selectAllSitesInStratum: (siteIds: SiteId[], selected: boolean) => void;
  isSiteSelected: (id: SiteId) => boolean;

  // Utilidades
  clearSelection: () => void;
  hasSelection: boolean;
  selectionCount: { strata: number; sites: number };
}

export function useMapSelection(options: UseMapSelectionOptions = {}): UseMapSelectionReturn {
  const { initialStratumIds = [], initialSiteIds = [] } = options;

  const [selectedStratumIds, setSelectedStratumIds] = useState<Set<string>>(
    () => new Set(initialStratumIds)
  );
  const [selectedSiteIds, setSelectedSiteIds] = useState<Set<SiteId>>(
    () => new Set(initialSiteIds)
  );

  // Acciones para estratos
  const toggleStratum = useCallback((id: string) => {
    setSelectedStratumIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }, []);

  const selectAllStrata = useCallback((stratumIds: string[], selected: boolean) => {
    setSelectedStratumIds((prev) => {
      const next = new Set(prev);
      stratumIds.forEach((id) => {
        if (selected) {
          next.add(id);
        } else {
          next.delete(id);
        }
      });
      return next;
    });
  }, []);

  const isStratumSelected = useCallback(
    (id: string) => selectedStratumIds.has(id),
    [selectedStratumIds]
  );

  // Acciones para sitios
  const toggleSite = useCallback((id: SiteId) => {
    setSelectedSiteIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }, []);

  const selectAllSitesInStratum = useCallback((siteIds: SiteId[], selected: boolean) => {
    setSelectedSiteIds((prev) => {
      const next = new Set(prev);
      siteIds.forEach((id) => {
        if (selected) {
          next.add(id);
        } else {
          next.delete(id);
        }
      });
      return next;
    });
  }, []);

  const isSiteSelected = useCallback(
    (id: SiteId) => selectedSiteIds.has(id),
    [selectedSiteIds]
  );

  // Utilidades
  const clearSelection = useCallback(() => {
    setSelectedStratumIds(new Set());
    setSelectedSiteIds(new Set());
  }, []);

  const hasSelection = useMemo(
    () => selectedStratumIds.size > 0 || selectedSiteIds.size > 0,
    [selectedStratumIds, selectedSiteIds]
  );

  const selectionCount = useMemo(
    () => ({
      strata: selectedStratumIds.size,
      sites: selectedSiteIds.size,
    }),
    [selectedStratumIds, selectedSiteIds]
  );

  return {
    selectedStratumIds,
    selectedSiteIds,
    toggleStratum,
    selectAllStrata,
    isStratumSelected,
    toggleSite,
    selectAllSitesInStratum,
    isSiteSelected,
    clearSelection,
    hasSelection,
    selectionCount,
  };
}
