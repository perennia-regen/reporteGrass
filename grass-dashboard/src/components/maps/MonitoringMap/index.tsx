'use client';

import { useEffect, useMemo, memo } from 'react';
import { MapContainer, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

import { BaseLayers } from './BaseLayers';
import { StratumLayers } from './StratumLayers';
import { SiteMarkers } from './SiteMarkers';
import type { Estrato, MonitorMCP } from '@/types/dashboard';
import type { SiteId } from '@/components/monitoring/hooks/useMapSelection';

interface MonitoringMapProps {
  center: [number, number];
  estratos: Estrato[];
  monitores: MonitorMCP[];
  selectedStratumIds: Set<string>;
  selectedSiteIds: Set<SiteId>;
  onStratumClick?: (id: string) => void;
  onSiteClick?: (id: SiteId) => void;
  height?: number;
}

// Componente para controlar el bounds del mapa (memoizado para evitar recálculos)
const MapBoundsController = memo(function MapBoundsController({
  estratos,
  selectedStratumIds,
}: {
  estratos: Estrato[];
  selectedStratumIds: Set<string>;
}) {
  const map = useMap();

  useEffect(() => {
    // Calcular bounds de todos los estratos seleccionados
    const visibleEstratos = estratos.filter(
      (e) => e.geometry && selectedStratumIds.has(e.id)
    );

    if (visibleEstratos.length === 0) return;

    const allCoords: [number, number][] = [];

    visibleEstratos.forEach((estrato) => {
      if (!estrato.geometry) return;

      if (estrato.geometry.type === 'Polygon') {
        // Polygon: coordinates es number[][][]
        const coords = estrato.geometry.coordinates[0] as number[][];
        coords.forEach((coord) => {
          // GeoJSON es [lng, lat], Leaflet es [lat, lng]
          allCoords.push([coord[1], coord[0]]);
        });
      } else if (estrato.geometry.type === 'MultiPolygon') {
        // MultiPolygon: coordinates es number[][][][]
        const multiCoords = estrato.geometry.coordinates as number[][][][];
        multiCoords.forEach((polygon) => {
          const ring = polygon[0]; // Outer ring
          ring.forEach((coord) => {
            allCoords.push([coord[1], coord[0]]);
          });
        });
      }
    });

    if (allCoords.length > 0) {
      const bounds = L.latLngBounds(allCoords);
      map.fitBounds(bounds, { padding: [20, 20] });
    }
  }, [map, estratos, selectedStratumIds]);

  return null;
});

export default function MonitoringMap({
  center,
  estratos,
  monitores,
  selectedStratumIds,
  selectedSiteIds,
  onStratumClick,
  onSiteClick,
  height = 500,
}: MonitoringMapProps) {
  // Si no hay selección, mostrar todos los estratos
  // Usa dependencias primitivas para evitar re-renders innecesarios
  const effectiveSelectedStratumIds = useMemo(() => {
    if (selectedStratumIds.size === 0) {
      return new Set(estratos.map((e) => e.id));
    }
    return selectedStratumIds;
  }, [selectedStratumIds.size, estratos.length, selectedStratumIds, estratos]);

  return (
    <MapContainer
      center={center}
      zoom={13}
      style={{ height: `${height}px`, width: '100%', borderRadius: '0.5rem' }}
      scrollWheelZoom={true}
    >
      <BaseLayers />

      <MapBoundsController
        estratos={estratos}
        selectedStratumIds={effectiveSelectedStratumIds}
      />

      <StratumLayers
        estratos={estratos}
        selectedIds={effectiveSelectedStratumIds}
        onStratumClick={onStratumClick}
      />

      <SiteMarkers
        monitores={monitores}
        estratos={estratos}
        selectedStratumIds={effectiveSelectedStratumIds}
        selectedSiteIds={selectedSiteIds}
        onSiteClick={onSiteClick}
      />
    </MapContainer>
  );
}
