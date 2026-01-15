'use client';

import { memo } from 'react';
import { ChevronDown } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { useDashboardStore, type KPIType } from '@/lib/dashboard-store';
import { KPI_OPTIONS } from '../constants';
import { useKPIData } from '../hooks';

interface KPICardProps {
  value: KPIType;
  onChange: (v: KPIType) => void;
  usedKPIs: KPIType[];
}

export const KPICard = memo(function KPICard({ value, onChange, usedKPIs }: KPICardProps) {
  const { isEditing } = useDashboardStore();
  const { getKPIData } = useKPIData();
  const data = getKPIData(value);

  return (
    <Card className={`bg-white ${isEditing ? 'overflow-hidden !py-0 !gap-0' : ''}`}>
      {isEditing && (
        <div className="relative bg-gray-50 border-b border-gray-200">
          <select
            value={value}
            onChange={(e) => onChange(e.target.value as KPIType)}
            className="w-full text-xs px-3 py-1.5 pr-10 bg-transparent text-gray-700 cursor-pointer focus:outline-none appearance-none"
          >
            {KPI_OPTIONS.map((opt) => (
              <option
                key={opt.id}
                value={opt.id}
                disabled={usedKPIs.includes(opt.id) && opt.id !== value}
              >
                {opt.name}
              </option>
            ))}
          </select>
          <div className="absolute right-2 top-1/2 -translate-y-1/2 p-1 bg-gray-200 rounded-full pointer-events-none">
            <ChevronDown className="w-3 h-3 text-gray-600" />
          </div>
        </div>
      )}
      <CardContent className="py-4 flex flex-col items-center justify-center">
        <p
          className="text-3xl font-bold"
          style={{ color: data.color }}
        >
          {data.value}
        </p>
        <p className="text-sm text-gray-500 mt-1">{data.label}</p>
        <p className={`text-xs mt-1 ${data.isPositive === false ? 'text-orange-500' : data.isPositive === true ? 'text-green-600' : 'text-gray-400'}`}>
          {data.sublabel}
        </p>
      </CardContent>
    </Card>
  );
});
