'use client';

import { memo, useMemo } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Cell,
  LabelList,
  ReferenceLine,
} from 'recharts';
import { forrajeData } from '@/lib/mock-data';
import { grassTheme } from '@/styles/grass-theme';
import type { ForrajeEstrato } from '@/types/dashboard';

interface ForrajeCalidadChartProps {
  data?: ForrajeEstrato[];
}

// Helper para obtener color basado en calidad
function getCalidadColor(calidad: number): string {
  if (calidad >= 4.5) return grassTheme.colors.calidadForraje[5];
  if (calidad >= 3.5) return grassTheme.colors.calidadForraje[4];
  if (calidad >= 2.5) return grassTheme.colors.calidadForraje[3];
  if (calidad >= 1.5) return grassTheme.colors.calidadForraje[2];
  return grassTheme.colors.calidadForraje[1];
}

export const ForrajeCalidadChart = memo(function ForrajeCalidadChart({
  data = forrajeData,
}: ForrajeCalidadChartProps) {
  const chartData = useMemo(() => {
    return data.map((d) => ({
      estrato: d.estrato,
      calidad: d.calidad,
      fill: getCalidadColor(d.calidad),
    }));
  }, [data]);

  return (
    <ResponsiveContainer width="100%" height={280}>
      <BarChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
        <CartesianGrid strokeDasharray="3 3" vertical={false} />
        <XAxis
          dataKey="estrato"
          tick={{ fontSize: 12 }}
          axisLine={{ stroke: '#e5e7eb' }}
        />
        <YAxis
          domain={[0, 5]}
          ticks={[1, 2, 3, 4, 5]}
          tick={{ fontSize: 11 }}
          axisLine={{ stroke: '#e5e7eb' }}
          label={{
            value: 'Calidad (1-5)',
            angle: -90,
            position: 'insideLeft',
            style: { textAnchor: 'middle', fontSize: 11, fill: '#6b7280' }
          }}
        />
        <Tooltip
          formatter={(value) => [Number(value).toFixed(1), 'Calidad']}
          contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
        />
        <ReferenceLine y={3} stroke="#9ca3af" strokeDasharray="3 3" />
        <Bar dataKey="calidad" radius={[4, 4, 0, 0]} maxBarSize={80}>
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.fill} />
          ))}
          <LabelList
            dataKey="calidad"
            position="top"
            formatter={(value) => (typeof value === 'number' ? value.toFixed(1) : String(value))}
            style={{ fontSize: 11, fontWeight: 500 }}
          />
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
});
