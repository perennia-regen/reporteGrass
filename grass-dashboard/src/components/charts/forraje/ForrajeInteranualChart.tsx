'use client';

import { memo, useMemo, useState } from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { forrajeHistorico } from '@/lib/mock-data';
import { getEstratoColor } from '@/lib/utils';
import type { ForrajeHistoricoItem } from '@/types/dashboard';

interface ForrajeInteranualChartProps {
  data?: ForrajeHistoricoItem[];
  metric?: 'biomasa' | 'calidad';
}

export const ForrajeInteranualChart = memo(function ForrajeInteranualChart({
  data = forrajeHistorico,
  metric = 'biomasa',
}: ForrajeInteranualChartProps) {
  const [selectedMetric, setSelectedMetric] = useState(metric);

  const chartData = useMemo(() => {
    return data.map((item) => {
      const row: Record<string, number | string> = { año: item.año.toString() };
      item.estratos.forEach((e) => {
        row[e.estrato] = selectedMetric === 'biomasa' ? e.biomasa : e.calidad;
      });
      return row;
    });
  }, [data, selectedMetric]);

  const estratos = useMemo(() => {
    if (data.length === 0) return [];
    return data[0].estratos.map((e) => e.estrato);
  }, [data]);

  const yAxisConfig = useMemo(() => {
    if (selectedMetric === 'biomasa') {
      return {
        domain: [0, 'auto'] as [number, 'auto'],
        label: 'kg MS/ha',
        tickFormatter: (value: number) => value.toLocaleString(),
      };
    }
    return {
      domain: [0, 5] as [number, number],
      label: 'Calidad (1-5)',
      tickFormatter: (value: number) => value.toFixed(1),
    };
  }, [selectedMetric]);

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <select
          value={selectedMetric}
          onChange={(e) => setSelectedMetric(e.target.value as 'biomasa' | 'calidad')}
          className="text-sm border rounded px-2 py-1 bg-white"
        >
          <option value="biomasa">Biomasa (kg MS/ha)</option>
          <option value="calidad">Calidad Forrajera</option>
        </select>
      </div>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="año"
            tick={{ fontSize: 12 }}
          />
          <YAxis
            domain={yAxisConfig.domain}
            tick={{ fontSize: 11 }}
            tickFormatter={yAxisConfig.tickFormatter}
            label={{
              value: yAxisConfig.label,
              angle: -90,
              position: 'insideLeft',
              style: { textAnchor: 'middle', fontSize: 11, fill: '#6b7280' }
            }}
          />
          <Tooltip
            formatter={(value) => [
              selectedMetric === 'biomasa'
                ? `${Number(value).toLocaleString()} kg MS/ha`
                : Number(value).toFixed(1),
              selectedMetric === 'biomasa' ? 'Biomasa' : 'Calidad'
            ]}
            contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
          />
          <Legend />
          {estratos.map((estrato) => (
            <Line
              key={estrato}
              type="monotone"
              dataKey={estrato}
              stroke={getEstratoColor(estrato)}
              strokeWidth={2}
              dot={{ r: 4, fill: getEstratoColor(estrato) }}
              activeDot={{ r: 6 }}
            />
          ))}
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
});
