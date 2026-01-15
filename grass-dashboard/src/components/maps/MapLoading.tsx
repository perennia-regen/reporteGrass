'use client';

interface MapLoadingProps {
  height?: string;
}

export function MapLoading({ height = '400px' }: MapLoadingProps) {
  return (
    <div
      className="flex items-center justify-center bg-gray-100 rounded-lg animate-pulse"
      style={{ height }}
    >
      <div className="text-center">
        <div className="text-gray-400 text-sm">Cargando mapa...</div>
      </div>
    </div>
  );
}
