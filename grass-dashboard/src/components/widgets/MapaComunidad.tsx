'use client';

import { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { EstablecimientoComunidad } from '@/types/dashboard';

// Función para calcular color de gradiente basado en valor ISE (0-100)
// Usando la paleta GRASS: estrato-loma (#313b2e) → grass-green (#8aca53) → grass-green-light (#b1ff6d)
const getISEGradientColor = (valor: number): string => {
  const normalized = Math.max(0, Math.min(100, valor)) / 100;

  if (normalized < 0.5) {
    // De estrato-loma (#313b2e) a grass-green (#8aca53)
    const t = normalized * 2;
    const r = Math.round(49 + (138 - 49) * t);
    const g = Math.round(59 + (202 - 59) * t);
    const b = Math.round(46 + (83 - 46) * t);
    return `rgb(${r}, ${g}, ${b})`;
  } else {
    // De grass-green (#8aca53) a grass-green-light (#b1ff6d)
    const t = (normalized - 0.5) * 2;
    const r = Math.round(138 + (177 - 138) * t);
    const g = Math.round(202 + (255 - 202) * t);
    const b = Math.round(83 + (109 - 83) * t);
    return `rgb(${r}, ${g}, ${b})`;
  }
};

// Crear icono personalizado basado en ISE
const createCommunityIcon = (isCurrent: boolean, ise: number) => {
  const color = getISEGradientColor(ise);
  const size = isCurrent ? 32 : 24;

  return L.divIcon({
    className: 'custom-marker',
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
        font-size: ${isCurrent ? 14 : 10}px;
        border: ${isCurrent ? '3px solid #000' : '2px solid white'};
        box-shadow: 0 2px 6px rgba(0,0,0,0.3);
      ">
        ${isCurrent ? '★' : ''}
      </div>
    `,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  });
};

interface MapaComunidadProps {
  establecimientos: EstablecimientoComunidad[];
  currentEstablecimiento: string;
}

// Componente para ajustar la vista del mapa
function FitBounds({ establecimientos }: { establecimientos: EstablecimientoComunidad[] }) {
  const map = useMap();

  useEffect(() => {
    if (establecimientos.length > 0) {
      const bounds = L.latLngBounds(
        establecimientos.map((e) => e.coordenadas)
      );
      map.fitBounds(bounds, { padding: [30, 30] });
    }
  }, [map, establecimientos]);

  return null;
}

export default function MapaComunidad({
  establecimientos,
  currentEstablecimiento,
}: MapaComunidadProps) {
  // Centro inicial aproximado de Argentina
  const center: [number, number] = [-33.5, -62];

  return (
    <MapContainer
      center={center}
      zoom={6}
      style={{ height: '400px', width: '100%', borderRadius: '0.5rem' }}
      scrollWheelZoom={true}
    >
      <FitBounds establecimientos={establecimientos} />
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />

      {/* Marcadores de establecimientos */}
      {establecimientos.map((est) => {
        const isCurrent = est.nombre === currentEstablecimiento;
        return (
          <Marker
            key={est.id}
            position={est.coordenadas}
            icon={createCommunityIcon(isCurrent, est.ise)}
            zIndexOffset={isCurrent ? 1000 : 0}
          >
            <Popup>
              <div className="text-sm min-w-[180px]">
                <p className="font-bold text-base">
                  {est.nombre}
                  {isCurrent && (
                    <span className="ml-2 text-xs bg-green-100 text-green-800 px-2 py-0.5 rounded">
                      Tu campo
                    </span>
                  )}
                </p>
                <p className="text-gray-500">{est.provincia}</p>
                <hr className="my-2" />
                <div className="space-y-1">
                  <p>
                    <span className="text-gray-600">ISE:</span>{' '}
                    <strong className={est.ise >= 70 ? 'text-green-600' : 'text-orange-600'}>
                      {est.ise}
                    </strong>
                  </p>
                  <p>
                    <span className="text-gray-600">Área:</span> {est.areaTotal} has
                  </p>
                  <p>
                    <span className="text-gray-600">Años monitoreando:</span> {est.anosMonitoreando}
                  </p>
                </div>
              </div>
            </Popup>
          </Marker>
        );
      })}
    </MapContainer>
  );
}
