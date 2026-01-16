'use client';

import { memo, useMemo } from 'react';
import { forrajeHistorico, mockDashboardData } from '@/lib/mock-data';

// Weighted average calculation based on stratum areas
function calculateWeightedAverage(
  estratosData: Array<{ estrato: string; biomasa: number }>,
  estratoAreas: Record<string, number>
): number {
  let totalBiomasa = 0;
  let totalArea = 0;

  estratosData.forEach(({ estrato, biomasa }) => {
    const area = estratoAreas[estrato] || 0;
    totalBiomasa += biomasa * area;
    totalArea += area;
  });

  return totalArea > 0 ? Math.round(totalBiomasa / totalArea) : 0;
}

export const MateriaSecaEvolucionChart = memo(function MateriaSecaEvolucionChart() {
  const { estratos } = mockDashboardData;

  // Build area map from estratos
  const estratoAreas = useMemo(() => {
    const areas: Record<string, number> = {};
    estratos.forEach((e) => {
      areas[e.nombre] = e.superficie;
    });
    return areas;
  }, [estratos]);

  // Calculate weighted average per year
  const chartData = useMemo(() => {
    return forrajeHistorico.map((item) => ({
      year: item.año,
      biomasa: calculateWeightedAverage(item.estratos, estratoAreas),
    }));
  }, [estratoAreas]);

  // Use reduce instead of spread for better performance with large arrays
  const { maxBiomasa, firstValue, lastValue } = useMemo(() => {
    const max = chartData.reduce((acc, d) => Math.max(acc, d.biomasa), 0);
    const first = chartData[0]?.biomasa || 0;
    const last = chartData[chartData.length - 1]?.biomasa || 0;
    return { maxBiomasa: max, firstValue: first, lastValue: last };
  }, [chartData]);

  const trendPercent = firstValue > 0
    ? Math.round(((lastValue - firstValue) / firstValue) * 100)
    : 0;

  return (
    <div className="h-48 flex flex-col">
      <div className="flex-1 flex items-end justify-between gap-3 px-4 pb-2">
        {chartData.map((punto, index) => {
          const heightPercent = maxBiomasa > 0
            ? Math.max((punto.biomasa / maxBiomasa) * 100, 5)
            : 5;

          return (
            <div key={index} className="flex flex-col items-center flex-1">
              <span className="text-xs font-semibold text-[var(--grass-green-dark)] mb-1">
                {punto.biomasa.toLocaleString()}
              </span>
              <div
                className="w-full rounded-t transition-all duration-500 bg-gradient-to-t from-[var(--grass-green-dark)] to-[var(--grass-green)]"
                style={{
                  height: `${heightPercent}%`,
                  minHeight: '8px',
                }}
              />
              <span className="text-xs mt-2 text-gray-600">{punto.year}</span>
            </div>
          );
        })}
      </div>
      <div className="px-4 pt-2 border-t">
        <div className="flex items-center justify-between text-xs">
          <span className="text-gray-500">kg MS/ha ponderado por superficie</span>
          <span className={`font-semibold ${trendPercent >= 0 ? 'text-green-600' : 'text-red-500'}`}>
            {trendPercent >= 0 ? '+' : ''}{trendPercent}% vs base
          </span>
        </div>
      </div>
    </div>
  );
});
