'use client';

import { memo } from 'react';
import { TileLayer, LayersControl } from 'react-leaflet';

const { BaseLayer } = LayersControl;

export const BaseLayers = memo(function BaseLayers() {
  return (
    <LayersControl position="topright">
      {/* Google Satellite (default) */}
      <BaseLayer checked name="Google Satellite">
        <TileLayer
          url="https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}"
          subdomains={['mt0', 'mt1', 'mt2', 'mt3']}
          maxZoom={20}
          attribution="&copy; Google"
        />
      </BaseLayer>

      {/* Google Hybrid */}
      <BaseLayer name="Google Hybrid">
        <TileLayer
          url="https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}"
          subdomains={['mt0', 'mt1', 'mt2', 'mt3']}
          maxZoom={20}
          attribution="&copy; Google"
        />
      </BaseLayer>

      {/* OpenStreetMap */}
      <BaseLayer name="OpenStreetMap">
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          maxZoom={19}
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        />
      </BaseLayer>
    </LayersControl>
  );
});
