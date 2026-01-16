'use client';

import dynamic from 'next/dynamic';
import { MapLoading } from './MapLoading';

// Dynamic import of MapaComunidad with loading state
export const DynamicMapaComunidad = dynamic(
  () => import('@/components/widgets/MapaComunidad'),
  {
    loading: () => <MapLoading />,
    ssr: false,
  }
);

// Dynamic import of MapaEstratos with loading state
export const DynamicMapaEstratos = dynamic(
  () => import('@/components/widgets/MapaEstratos'),
  {
    loading: () => <MapLoading />,
    ssr: false,
  }
);

// Dynamic import of MonitoringMap (nuevo mapa con polígonos GeoJSON)
export const DynamicMonitoringMap = dynamic(
  () => import('@/components/maps/MonitoringMap'),
  {
    loading: () => <MapLoading />,
    ssr: false,
  }
);
