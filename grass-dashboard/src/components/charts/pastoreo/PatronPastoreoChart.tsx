'use client';

import { memo, useMemo } from 'react';
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  ResponsiveContainer,
  type PieLabelRenderProps,
} from 'recharts';
import { pastoreoData } from '@/lib/mock-data';
import { grassTheme } from '@/styles/grass-theme';
import type { PastoreoPatron } from '@/types/dashboard';

interface PatronPastoreoChartProps {
  data?: PastoreoPatron;
}

const PATRON_LABELS: Record<keyof PastoreoPatron, string> = {
  intenso: 'Intenso',
  moderado: 'Moderado',
  leve: 'Leve',
  nulo: 'Sin pastoreo',
};

const PATRON_COLORS: Record<keyof PastoreoPatron, string> = {
  intenso: grassTheme.colors.pastoreo.intenso,
  moderado: grassTheme.colors.pastoreo.moderado,
  leve: grassTheme.colors.pastoreo.leve,
  nulo: grassTheme.colors.pastoreo.nulo,
};

export const PatronPastoreoChart = memo(function PatronPastoreoChart({
  data = pastoreoData.patronTotal,
}: PatronPastoreoChartProps) {
  const chartData = useMemo(() => {
    return (Object.keys(data) as Array<keyof PastoreoPatron>)
      .filter((key) => data[key] > 0)
      .map((key) => ({
        name: PATRON_LABELS[key],
        value: data[key],
        color: PATRON_COLORS[key],
      }));
  }, [data]);

  const renderCustomLabel = (props: PieLabelRenderProps) => {
    const { cx, cy, midAngle, innerRadius, outerRadius, percent } = props;
    if (
      typeof cx !== 'number' ||
      typeof cy !== 'number' ||
      typeof midAngle !== 'number' ||
      typeof innerRadius !== 'number' ||
      typeof outerRadius !== 'number' ||
      typeof percent !== 'number' ||
      percent < 0.05
    ) {
      return null;
    }
    const RADIAN = Math.PI / 180;
    const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
    const x = cx + radius * Math.cos(-midAngle * RADIAN);
    const y = cy + radius * Math.sin(-midAngle * RADIAN);

    return (
      <text
        x={x}
        y={y}
        fill="white"
        textAnchor="middle"
        dominantBaseline="central"
        fontSize={12}
        fontWeight={600}
      >
        {`${(percent * 100).toFixed(0)}%`}
      </text>
    );
  };

  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={chartData}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={renderCustomLabel}
          outerRadius={100}
          innerRadius={40}
          fill="#8884d8"
          dataKey="value"
          paddingAngle={2}
        >
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={entry.color} />
          ))}
        </Pie>
        <Tooltip
          formatter={(value) => [`${value}%`, 'Porcentaje']}
          contentStyle={{ borderRadius: '8px', border: '1px solid #e5e7eb' }}
        />
        <Legend
          layout="horizontal"
          verticalAlign="bottom"
          align="center"
          formatter={(value) => <span className="text-sm">{value}</span>}
        />
      </PieChart>
    </ResponsiveContainer>
  );
});
