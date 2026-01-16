'use client';

import { memo, useCallback } from 'react';
import { GeoJSON, Tooltip } from 'react-leaflet';
import type { Estrato, EstratoGeoJSON } from '@/types/dashboard';
import type { PathOptions, LeafletMouseEvent } from 'leaflet';
import type { Feature, Geometry } from 'geojson';

interface StratumLayersProps {
  estratos: Estrato[];
  selectedIds: Set<string>;
  onStratumClick?: (id: string) => void;
}

function StratumLayersComponent({ estratos, selectedIds, onStratumClick }: StratumLayersProps) {
  // Filtrar solo los estratos seleccionados
  const visibleEstratos = estratos.filter((e) => selectedIds.has(e.id));

  const getStyle = useCallback(
    (estrato: Estrato): PathOptions => {
      const isSelected = selectedIds.has(estrato.id);
      // Loma usa borde brillante para verse sobre suelo oscuro
      const isLoma = estrato.id === 'loma';
      const strokeColor = isLoma ? '#90EE90' : estrato.color; // Verde brillante para loma
      return {
        fillColor: estrato.color,
        fillOpacity: isSelected ? 0.4 : 0.15,
        color: strokeColor,
        weight: isSelected ? 3 : 1,
        opacity: 1,
      };
    },
    [selectedIds]
  );

  const handleClick = useCallback(
    (estratoId: string) => (e: LeafletMouseEvent) => {
      e.originalEvent.stopPropagation();
      onStratumClick?.(estratoId);
    },
    [onStratumClick]
  );

  // Convertir Estrato a GeoJSON Feature
  const toGeoJSONFeature = useCallback((estrato: Estrato): EstratoGeoJSON | null => {
    if (!estrato.geometry) return null;
    return {
      type: 'Feature',
      properties: {
        id: estrato.id,
        nombre: estrato.nombre,
        codigo: estrato.codigo,
        color: estrato.color,
        superficie: estrato.superficie,
      },
      geometry: estrato.geometry,
    };
  }, []);

  return (
    <>
      {visibleEstratos.map((estrato) => {
        const feature = toGeoJSONFeature(estrato);
        if (!feature) return null;

        return (
          <GeoJSON
            key={`${estrato.id}-${selectedIds.has(estrato.id)}`}
            data={feature as Feature<Geometry>}
            style={() => getStyle(estrato)}
            eventHandlers={{
              click: handleClick(estrato.id),
            }}
          >
            <Tooltip sticky>
              <div className="text-sm">
                <p className="font-semibold">{estrato.nombre}</p>
                <p className="text-gray-600">{estrato.superficie} has</p>
              </div>
            </Tooltip>
          </GeoJSON>
        );
      })}
    </>
  );
}

export const StratumLayers = memo(StratumLayersComponent);
