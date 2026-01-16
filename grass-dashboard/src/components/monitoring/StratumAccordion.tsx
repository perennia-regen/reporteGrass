'use client';

import { memo, useMemo, useCallback } from 'react';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';
import { Checkbox } from '@/components/ui/checkbox';
import { SitesList } from './SitesList';
import type { Estrato, MonitorMCP } from '@/types/dashboard';
import type { SiteId } from './hooks/useMapSelection';

interface StratumAccordionProps {
  estratos: Estrato[];
  monitores: MonitorMCP[];
  selectedStratumIds: Set<string>;
  selectedSiteIds: Set<SiteId>;
  onStratumToggle: (id: string) => void;
  onSiteToggle: (id: SiteId) => void;
  onSelectAllSitesInStratum: (siteIds: SiteId[], selected: boolean) => void;
}

function StratumAccordionComponent({
  estratos,
  monitores,
  selectedStratumIds,
  selectedSiteIds,
  onStratumToggle,
  onSiteToggle,
  onSelectAllSitesInStratum,
}: StratumAccordionProps) {
  // Agrupar monitores por estrato
  const monitoresByStratum = useMemo(() => {
    const map = new Map<string, MonitorMCP[]>();
    estratos.forEach((e) => map.set(e.id, []));

    monitores.forEach((m) => {
      const estrato = estratos.find((e) => e.codigo === m.estratoCodigo);
      if (estrato) {
        map.get(estrato.id)?.push(m);
      }
    });

    return map;
  }, [estratos, monitores]);

  // Verificar si todos los sitios de un estrato están seleccionados
  const areAllSitesSelected = useCallback(
    (estratoId: string) => {
      const sites = monitoresByStratum.get(estratoId) || [];
      if (sites.length === 0) return false;
      return sites.every((s) => selectedSiteIds.has(s.id));
    },
    [monitoresByStratum, selectedSiteIds]
  );

  // Handler para el checkbox del estrato
  const handleStratumCheckboxChange = useCallback(
    (estratoId: string, checked: boolean) => {
      // Primero toggle el estrato
      if (checked && !selectedStratumIds.has(estratoId)) {
        onStratumToggle(estratoId);
      } else if (!checked && selectedStratumIds.has(estratoId)) {
        onStratumToggle(estratoId);
      }

      // Luego seleccionar/deseleccionar todos sus sitios
      const sites = monitoresByStratum.get(estratoId) || [];
      const siteIds = sites.map((s) => s.id);
      onSelectAllSitesInStratum(siteIds, checked);
    },
    [selectedStratumIds, onStratumToggle, monitoresByStratum, onSelectAllSitesInStratum]
  );

  return (
    <Accordion type="multiple" className="w-full">
      {estratos.map((estrato) => {
        const sites = monitoresByStratum.get(estrato.id) || [];
        const isSelected = selectedStratumIds.has(estrato.id);
        const allSitesSelected = areAllSitesSelected(estrato.id);

        return (
          <AccordionItem key={estrato.id} value={estrato.id}>
            <AccordionTrigger className="px-2 hover:no-underline">
              <div className="flex items-center gap-3 flex-1">
                <Checkbox
                  checked={isSelected && allSitesSelected}
                  onCheckedChange={(checked) =>
                    handleStratumCheckboxChange(estrato.id, checked as boolean)
                  }
                  onClick={(e) => e.stopPropagation()}
                />
                <div
                  className="w-4 h-4 rounded"
                  style={{ backgroundColor: estrato.color }}
                  aria-hidden="true"
                />
                <span className="font-medium text-gray-900">{estrato.nombre}</span>
                <span className="text-xs text-gray-500 ml-auto mr-2">
                  {sites.length} sitios
                </span>
              </div>
            </AccordionTrigger>
            <AccordionContent>
              <SitesList
                sites={sites}
                selectedIds={selectedSiteIds}
                onSiteToggle={onSiteToggle}
              />
            </AccordionContent>
          </AccordionItem>
        );
      })}
    </Accordion>
  );
}

export const StratumAccordion = memo(StratumAccordionComponent);
