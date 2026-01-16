'use client';

import { memo, useMemo } from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { pastoreoData } from '@/lib/mock-data';
import { grassTheme } from '@/styles/grass-theme';
import type { IntensidadPastoreoEstrato } from '@/types/dashboard';

interface IntensidadPastoreoChartProps {
  data?: IntensidadPastoreoEstrato[];
}

export const IntensidadPastoreoChart = memo(function IntensidadPastoreoChart({
  data = pastoreoData.intensidadPorEstrato,
}: IntensidadPastoreoChartProps) {
  const chartData = useMemo(() => {
    return data.map((d) => ({
      estrato: d.estrato,
      Intenso: d.intenso,
      Moderado: d.moderado,
      Leve: d.leve,
      'Sin pastoreo': d.nulo,
    }));
  }, [data]);

  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart
        data={chartData}
        margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
      >
        <CartesianGrid strokeDasharray="3 3" vertical={false} />
        <XAxis
          dataKey="estrato"
          tick={{ fontSize: 12 }}
          axisLine={{ stroke: '#e5e7eb' }}
        />
        <YAxis
          tick={{ fontSize: 11 }}
          axisLine={{ stroke: '#e5e7eb' }}
          domain={[0, 100]}
          tickFormatter={(value) => `${value}%`}
          label={{
            value: 'Porcentaje',
            angle: -90,
            position: 'insideLeft',
            style: { textAnchor: 'middle', fontSize: 11, fill: '#6b7280' }
          }}
        />
        <Tooltip
          formatter={(value) => [`${value}%`, '']}
          contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
        />
        <Legend />
        <Bar
          dataKey="Intenso"
          stackId="a"
          fill={grassTheme.colors.pastoreo.intenso}
          radius={[0, 0, 0, 0]}
        />
        <Bar
          dataKey="Moderado"
          stackId="a"
          fill={grassTheme.colors.pastoreo.moderado}
        />
        <Bar
          dataKey="Leve"
          stackId="a"
          fill={grassTheme.colors.pastoreo.leve}
        />
        <Bar
          dataKey="Sin pastoreo"
          stackId="a"
          fill={grassTheme.colors.pastoreo.nulo}
          radius={[4, 4, 0, 0]}
        />
      </BarChart>
    </ResponsiveContainer>
  );
});
