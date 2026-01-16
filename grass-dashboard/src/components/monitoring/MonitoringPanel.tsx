'use client';

import { memo, useCallback, useMemo } from 'react';
import { Checkbox } from '@/components/ui/checkbox';
import { StratumAccordion } from './StratumAccordion';
import type { Estrato, MonitorMCP } from '@/types/dashboard';
import type { UseMapSelectionReturn } from './hooks/useMapSelection';

interface MonitoringPanelProps {
  estratos: Estrato[];
  monitores: MonitorMCP[];
  selection: UseMapSelectionReturn;
}

function MonitoringPanelComponent({
  estratos,
  monitores,
  selection,
}: MonitoringPanelProps) {
  const {
    selectedStratumIds,
    selectedSiteIds,
    toggleStratum,
    toggleSite,
    selectAllStrata,
    selectAllSitesInStratum,
    selectionCount,
  } = selection;

  // Verificar si todos los estratos están seleccionados
  const allStrataSelected = useMemo(
    () => estratos.every((e) => selectedStratumIds.has(e.id)),
    [estratos, selectedStratumIds]
  );

  // Handler para seleccionar todos
  const handleSelectAll = useCallback(
    (checked: boolean) => {
      const allIds = estratos.map((e) => e.id);
      selectAllStrata(allIds, checked);

      // También seleccionar/deseleccionar todos los sitios
      const allSiteIds = monitores.map((m) => m.id);
      selectAllSitesInStratum(allSiteIds, checked);
    },
    [estratos, monitores, selectAllStrata, selectAllSitesInStratum]
  );

  return (
    <div className="bg-white rounded-lg border border-gray-200 h-full flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <h3 className="font-semibold text-[var(--grass-green-dark)] mb-3">
          Filtrar Capas
        </h3>

        <label className="flex items-center gap-2 py-2 px-2 rounded hover:bg-gray-50 cursor-pointer">
          <Checkbox
            checked={allStrataSelected}
            onCheckedChange={handleSelectAll}
          />
          <span className="text-sm font-medium text-gray-700">
            Seleccionar todos
          </span>
        </label>
      </div>

      {/* Accordion de estratos */}
      <div className="flex-1 overflow-y-auto p-2">
        <StratumAccordion
          estratos={estratos}
          monitores={monitores}
          selectedStratumIds={selectedStratumIds}
          selectedSiteIds={selectedSiteIds}
          onStratumToggle={toggleStratum}
          onSiteToggle={toggleSite}
          onSelectAllSitesInStratum={selectAllSitesInStratum}
        />
      </div>

      {/* Footer con estadísticas */}
      <div className="p-3 border-t border-gray-200 bg-gray-50">
        <div className="text-xs text-gray-500 space-y-1">
          <p>
            <span className="font-medium">{selectionCount.strata}</span> de{' '}
            {estratos.length} estratos visibles
          </p>
          <p>
            <span className="font-medium">{selectionCount.sites}</span> de{' '}
            {monitores.length} sitios seleccionados
          </p>
        </div>
      </div>
    </div>
  );
}

export const MonitoringPanel = memo(MonitoringPanelComponent);
