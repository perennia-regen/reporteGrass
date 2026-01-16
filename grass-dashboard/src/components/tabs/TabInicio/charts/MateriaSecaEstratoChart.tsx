'use client';

import { memo, useMemo } from 'react';
import { forrajeData } from '@/lib/mock-data';
import { getEstratoColor } from '@/lib/utils';

export const MateriaSecaEstratoChart = memo(function MateriaSecaEstratoChart() {
  const chartData = useMemo(() => {
    return forrajeData.map((item) => ({
      estrato: item.estrato,
      codigo: item.codigo,
      biomasa: item.biomasa,
      calidad: item.calidad,
      color: getEstratoColor(item.estrato),
    }));
  }, []);

  const maxBiomasa = Math.max(...chartData.map((d) => d.biomasa));

  return (
    <div className="space-y-3 p-4">
      {chartData.map(({ estrato, biomasa, calidad, color }) => {
        const porcentaje = maxBiomasa > 0 ? (biomasa / maxBiomasa) * 100 : 0;

        return (
          <div key={estrato} className="flex items-center gap-4">
            <span className="w-24 text-sm font-medium">{estrato}</span>
            <div className="flex-1 bg-gray-100 rounded-full h-6 relative overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{
                  width: `${Math.max(porcentaje, 0)}%`,
                  backgroundColor: color,
                }}
              />
            </div>
            <div className="w-28 text-right">
              <span className="font-semibold text-sm">{biomasa.toLocaleString()}</span>
              <span className="text-xs text-gray-500 ml-1">kg MS/ha</span>
            </div>
          </div>
        );
      })}
      <div className="pt-3 border-t mt-3">
        <p className="text-xs text-gray-500">
          Calidad promedio: {chartData.map(d => `${d.estrato}: ${d.calidad}/5`).join(' | ')}
        </p>
      </div>
    </div>
  );
});
