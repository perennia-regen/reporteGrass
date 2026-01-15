'use client';

interface ChartLoadingProps {
  height?: string;
}

export function ChartLoading({ height = '100%' }: ChartLoadingProps) {
  return (
    <div
      className="flex items-center justify-center bg-gray-50 rounded animate-pulse"
      style={{ height }}
    >
      <div className="text-gray-400 text-sm">Cargando gráfico...</div>
    </div>
  );
}
