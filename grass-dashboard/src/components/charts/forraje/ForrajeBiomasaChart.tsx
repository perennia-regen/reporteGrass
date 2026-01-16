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
} from 'recharts';
import { forrajeData } from '@/lib/mock-data';
import { getEstratoColor } from '@/lib/utils';
import type { ForrajeEstrato } from '@/types/dashboard';

interface ForrajeBiomasaChartProps {
  data?: ForrajeEstrato[];
}

export const ForrajeBiomasaChart = memo(function ForrajeBiomasaChart({
  data = forrajeData,
}: ForrajeBiomasaChartProps) {
  const chartData = useMemo(() => {
    return data.map((d) => ({
      estrato: d.estrato,
      biomasa: d.biomasa,
      fill: getEstratoColor(d.estrato),
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
          tick={{ fontSize: 11 }}
          axisLine={{ stroke: '#e5e7eb' }}
          label={{
            value: 'kg MS/ha',
            angle: -90,
            position: 'insideLeft',
            style: { textAnchor: 'middle', fontSize: 11, fill: '#6b7280' }
          }}
        />
        <Tooltip
          formatter={(value) => [`${Number(value).toLocaleString()} kg MS/ha`, 'Biomasa']}
          contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
        />
        <Bar dataKey="biomasa" radius={[4, 4, 0, 0]} maxBarSize={80}>
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.fill} />
          ))}
          <LabelList
            dataKey="biomasa"
            position="top"
            formatter={(value) => String(value).replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
            style={{ fontSize: 11, fontWeight: 500 }}
          />
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  );
});
