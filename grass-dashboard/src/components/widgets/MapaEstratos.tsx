'use client';

import { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import type { MonitorMCP, Estrato } from '@/types/dashboard';

// Fix para los iconos de Leaflet en Next.js
const createCustomIcon = (color: string, number: number) => {
  return L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        background-color: ${color};
        width: 28px;
        height: 28px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-weight: bold;
        font-size: 12px;
        border: 2px solid white;
        box-shadow: 0 2px 4px rgba(0,0,0,0.3);
      ">${number}</div>
    `,
    iconSize: [28, 28],
    iconAnchor: [14, 14],
  });
};

interface MapaEstratosProps {
  center: [number, number];
  monitores: MonitorMCP[];
  estratos: Estrato[];
}

function MapController({ center }: { center: [number, number] }) {
  const map = useMap();

  useEffect(() => {
    map.setView(center, 13);
  }, [map, center]);

  return null;
}

export default function MapaEstratos({ center, monitores, estratos }: MapaEstratosProps) {
  // Obtener color del estrato
  const getEstratoColor = (estratoCodigo: string): string => {
    const estrato = estratos.find((e) => e.codigo === estratoCodigo);
    return estrato?.color || '#757575';
  };

  return (
    <MapContainer
      center={center}
      zoom={13}
      style={{ height: '400px', width: '100%', borderRadius: '0.5rem' }}
      scrollWheelZoom={true}
    >
      <MapController center={center} />
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />

      {/* Marcadores de monitores */}
      {monitores.map((monitor) => (
        <Marker
          key={monitor.id}
          position={monitor.coordenadas}
          icon={createCustomIcon(getEstratoColor(monitor.estratoCodigo), monitor.id)}
        >
          <Popup>
            <div className="text-sm">
              <p className="font-bold">Monitor #{monitor.id}</p>
              <p className="text-gray-600">Estrato: {monitor.estrato}</p>
              <p className="text-gray-600">ISE: {monitor.ise2}</p>
              <div className="mt-2 text-xs">
                <p>Lat: {monitor.coordenadas[0].toFixed(4)}</p>
                <p>Lng: {monitor.coordenadas[1].toFixed(4)}</p>
              </div>
            </div>
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  );
}
