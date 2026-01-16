'use client';

import { memo, useCallback, useMemo, useState } from 'react';
import { Marker, Popup } from 'react-leaflet';
import L from 'leaflet';
import type { MonitorMCP, Estrato } from '@/types/dashboard';
import type { SiteId } from '@/components/monitoring/hooks/useMapSelection';

interface SiteMarkersProps {
  monitores: MonitorMCP[];
  estratos: Estrato[];
  selectedStratumIds: Set<string>;
  selectedSiteIds: Set<SiteId>;
  onSiteClick?: (id: SiteId) => void;
}

// Crear icono personalizado para los marcadores
const createSiteIcon = (color: string, label: string | number, isSelected: boolean) => {
  const size = isSelected ? 32 : 28;
  const borderWidth = isSelected ? 3 : 2;
  // Extraer solo el número del nombre del sitio (LAU001 -> 1, LAU12 -> 12)
  const displayLabel = typeof label === 'string'
    ? label.replace(/[^0-9]/g, '').replace(/^0+/, '') || label.slice(-2)
    : label;

  const borderStyle = isSelected
    ? `${borderWidth}px solid white`
    : 'none';

  return L.divIcon({
    className: 'custom-site-marker',
    html: `
      <div style="
        background-color: ${color};
        width: ${size}px;
        height: ${size}px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: bold;
        font-size: ${isSelected ? 12 : 10}px;
        border: ${borderStyle};
        box-shadow: 0 2px 6px rgba(0,0,0,${isSelected ? 0.5 : 0.3});
        transition: all 0.2s ease;
      ">${displayLabel}</div>
    `,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  });
};

// Helper para obtener color de ISE
function getISEColor(ise: number): string {
  if (ise >= 60) return '#22c55e'; // green-500
  if (ise >= 40) return '#eab308'; // yellow-500
  if (ise >= 20) return '#f97316'; // orange-500
  return '#ef4444'; // red-500
}

// Helper para formatear patrón de uso
function formatPatronUso(patron: string | null): string {
  switch (patron) {
    case 'PP': return 'Pastoreo Parejo';
    case 'SD': return 'Sin Datos';
    case 'SP': return 'Sin Pastoreo';
    default: return '-';
  }
}

// Helper para formatear intensidad
function formatIntensidad(intensidad: string | null): string {
  switch (intensidad) {
    case 'none': return 'Ninguna';
    case 'moderate': return 'Moderada';
    case 'intense': return 'Intensa';
    default: return '-';
  }
}

// Helper para obtener nombre del indicador
function getIndicadorLabel(key: string): string {
  const labels: Record<string, string> = {
    abundanciaCanopeo: 'Abundancia de Canopeo',
    microfauna: 'Organismos Vivos',
    gf1PastosVerano: 'Pastos de Verano',
    gf2PastosInvierno: 'Pastos de Invierno',
    gf3HierbasLeguminosas: 'Hierbas y Leguminosas',
    gf4ArbolesArbustos: 'Árboles y Arbustos',
    especiesDeseables: 'Especies Deseables',
    especiesIndeseables: 'Especies Indeseables',
    abundanciaMantillo: 'Abundancia de Mantillo',
    incorporacionMantillo: 'Incorporación de Mantillo',
    descomposicionBostas: 'Descomposición de Bostas',
    sueloDesnudo: 'Suelo Desnudo',
    encostramiento: 'Encostramiento',
    erosionEolica: 'Erosión Eólica',
    erosionHidrica: 'Erosión Hídrica',
  };
  return labels[key] || key;
}

// Componente de Popup compacto con scroll
function SitePopupContent({ monitor, color }: { monitor: MonitorMCP; color: string }) {
  const [activePhoto, setActivePhoto] = useState<'panoramic' | '45' | '90'>('panoramic');
  const [showIndicadores, setShowIndicadores] = useState(false);
  const siteName = monitor.nombre || `Sitio #${monitor.id}`;
  const hasPhotos = monitor.fotos && (monitor.fotos.panoramic || monitor.fotos.degrees45 || monitor.fotos.degrees90);
  const hasForraje = monitor.forraje && monitor.forraje.biomasaKgMSHa !== null;

  const currentPhotoUrl = monitor.fotos ? (
    activePhoto === 'panoramic' ? monitor.fotos.panoramic :
    activePhoto === '45' ? monitor.fotos.degrees45 :
    monitor.fotos.degrees90
  ) : undefined;

  // Obtener indicadores como array
  const indicadoresList = Object.entries(monitor.indicadores)
    .filter(([key]) => key !== 'estructuraSuelo')
    .map(([key, value]) => ({ key, label: getIndicadorLabel(key), value }));

  return (
    <div
      className="text-xs"
      style={{ width: '240px', maxHeight: '320px', overflowY: 'auto' }}
    >
      {/* Header compacto */}
      <div className="flex items-center gap-2 mb-2 sticky top-0 bg-white pb-1">
        <div
          className="w-2.5 h-2.5 rounded-full flex-shrink-0"
          style={{ backgroundColor: color }}
        />
        <p className="font-bold text-sm">{siteName}</p>
        <span className="text-gray-400 text-xs ml-auto">{monitor.estrato}</span>
      </div>

      {/* ISE Score - clickeable para expandir indicadores */}
      <button
        onClick={() => setShowIndicadores(!showIndicadores)}
        className="w-full rounded-lg p-2 mb-2 text-left transition-colors hover:opacity-90"
        style={{ backgroundColor: `${getISEColor(monitor.ise2)}15` }}
      >
        <div className="flex items-center justify-between">
          <div>
            <span className="text-gray-600 text-xs">Score ISE</span>
            <p className="text-xs text-gray-400 mt-0.5">
              {showIndicadores ? '▼ Ocultar detalles' : '▶ Ver 15 indicadores'}
            </p>
          </div>
          <span
            className="text-xl font-bold"
            style={{ color: getISEColor(monitor.ise2) }}
          >
            {monitor.ise2}
          </span>
        </div>
      </button>

      {/* Indicadores expandibles */}
      {showIndicadores && (
        <div className="bg-gray-50 rounded-lg p-2 mb-2 space-y-1">
          {indicadoresList.map(({ key, label, value }) => (
            <div key={key} className="flex justify-between items-center">
              <span className="text-gray-600 text-xs truncate pr-2">{label}</span>
              <span className="font-medium text-gray-800 text-xs">{value}</span>
            </div>
          ))}
        </div>
      )}

      {/* Datos de Forraje compactos */}
      {hasForraje && (
        <div className="bg-gray-50 rounded p-2 mb-2">
          <div className="grid grid-cols-2 gap-1">
            <div>
              <span className="text-gray-500">Biomasa:</span>
              <p className="font-semibold text-gray-800">
                {monitor.forraje!.biomasaKgMSHa?.toLocaleString() || '-'}
              </p>
            </div>
            <div>
              <span className="text-gray-500">Calidad:</span>
              <p className="font-semibold text-gray-800">
                {monitor.forraje!.calidadForraje !== null ? `${monitor.forraje!.calidadForraje}/5` : '-'}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Fotos compactas */}
      {hasPhotos && (
        <div className="mb-2">
          {currentPhotoUrl && (
            <a href={currentPhotoUrl} target="_blank" rel="noopener noreferrer">
              <img
                src={currentPhotoUrl}
                alt={`${siteName} - ${activePhoto}`}
                className="w-full h-24 object-cover rounded mb-1.5 cursor-pointer hover:opacity-90 transition-opacity"
              />
            </a>
          )}
          <div className="flex gap-1">
            {monitor.fotos?.panoramic && (
              <button
                onClick={() => setActivePhoto('panoramic')}
                className={`flex-1 px-1.5 py-0.5 text-xs rounded transition-colors ${
                  activePhoto === 'panoramic'
                    ? 'bg-green-600 text-white'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                Pan
              </button>
            )}
            {monitor.fotos?.degrees45 && (
              <button
                onClick={() => setActivePhoto('45')}
                className={`flex-1 px-1.5 py-0.5 text-xs rounded transition-colors ${
                  activePhoto === '45'
                    ? 'bg-green-600 text-white'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                45°
              </button>
            )}
            {monitor.fotos?.degrees90 && (
              <button
                onClick={() => setActivePhoto('90')}
                className={`flex-1 px-1.5 py-0.5 text-xs rounded transition-colors ${
                  activePhoto === '90'
                    ? 'bg-green-600 text-white'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                90°
              </button>
            )}
          </div>
        </div>
      )}

      {/* Coordenadas */}
      <div className="pt-1.5 border-t border-gray-200 text-xs text-gray-400 flex justify-between">
        <span>{monitor.coordenadas[0].toFixed(4)}</span>
        <span>{monitor.coordenadas[1].toFixed(4)}</span>
      </div>
    </div>
  );
}

function SiteMarkersComponent({
  monitores,
  estratos,
  selectedStratumIds,
  selectedSiteIds,
  onSiteClick,
}: SiteMarkersProps) {
  // Crear mapa de colores por código de estrato (para mostrar en popup)
  const estratoColorMap = useMemo(() => {
    const map = new Map<string, string>();
    estratos.forEach((e) => map.set(e.codigo, e.color));
    return map;
  }, [estratos]);

  // Crear mapa de id -> nombre de estrato
  const estratoIdByCode = useMemo(() => {
    const map = new Map<string, string>();
    estratos.forEach((e) => map.set(e.codigo, e.id));
    return map;
  }, [estratos]);

  // Filtrar monitores visibles (solo los de estratos seleccionados)
  const visibleMonitores = useMemo(() => {
    return monitores.filter((m) => {
      const estratoId = estratoIdByCode.get(m.estratoCodigo);
      return estratoId && selectedStratumIds.has(estratoId);
    });
  }, [monitores, estratoIdByCode, selectedStratumIds]);

  // Calcular el centro de todos los monitores visibles para determinar popup direction
  const mapCenter = useMemo(() => {
    if (visibleMonitores.length === 0) return { lat: 0, lng: 0 };
    const sumLat = visibleMonitores.reduce((sum, m) => sum + m.coordenadas[0], 0);
    const sumLng = visibleMonitores.reduce((sum, m) => sum + m.coordenadas[1], 0);
    return {
      lat: sumLat / visibleMonitores.length,
      lng: sumLng / visibleMonitores.length,
    };
  }, [visibleMonitores]);

  const handleClick = useCallback(
    (id: SiteId) => () => {
      onSiteClick?.(id);
    },
    [onSiteClick]
  );

  return (
    <>
      {visibleMonitores.map((monitor) => {
        const estratoColor = estratoColorMap.get(monitor.estratoCodigo) || '#757575';
        const iseColor = getISEColor(monitor.ise2);
        const isSelected = selectedSiteIds.has(monitor.id);

        // Determinar si el popup debe ir arriba o abajo según posición del marker
        const isInUpperHalf = monitor.coordenadas[0] > mapCenter.lat;
        const popupOffset: [number, number] = isInUpperHalf ? [0, -5] : [0, 5];

        return (
          <Marker
            key={monitor.id}
            position={monitor.coordenadas}
            icon={createSiteIcon(iseColor, monitor.nombre || monitor.id, isSelected)}
            eventHandlers={{
              click: handleClick(monitor.id),
            }}
          >
            <Popup
              maxWidth={260}
              className="compact-popup"
              offset={popupOffset}
              autoPan={true}
              autoPanPaddingTopLeft={L.point(50, 50)}
              autoPanPaddingBottomRight={L.point(50, 50)}
            >
              <SitePopupContent monitor={monitor} color={estratoColor} />
            </Popup>
          </Marker>
        );
      })}
    </>
  );
}

export const SiteMarkers = memo(SiteMarkersComponent);
