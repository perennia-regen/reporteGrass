'use client';

import { memo } from 'react';
import { ChevronDown, X } from 'lucide-react';
import { useDashboardStore } from '@/lib/dashboard-store';
import { CHART_OPTIONS, type ChartType } from '../constants';
import { getChartName } from '../utils';

interface ChartHeaderProps {
  value: ChartType;
  onChange: (v: ChartType) => void;
  usedCharts: ChartType[];
  canRemove?: boolean;
  onRemove?: () => void;
}

export const ChartHeader = memo(function ChartHeader({
  value,
  onChange,
  usedCharts,
  canRemove = false,
  onRemove,
}: ChartHeaderProps) {
  const { isEditing } = useDashboardStore();

  if (isEditing) {
    return (
      <div className="relative bg-gray-50 border-b border-gray-200">
        <select
          value={value}
          onChange={(e) => onChange(e.target.value as ChartType)}
          className={`w-full text-xs px-3 py-1.5 bg-transparent text-gray-700 cursor-pointer focus:outline-none appearance-none ${canRemove ? 'pr-16' : 'pr-10'}`}
        >
          {CHART_OPTIONS.map((opt) => (
            <option key={opt.id} value={opt.id} disabled={usedCharts.includes(opt.id) && opt.id !== value}>
              {opt.name}
            </option>
          ))}
        </select>
        <div className={`absolute top-1/2 -translate-y-1/2 p-1 bg-gray-200 rounded-full pointer-events-none ${canRemove ? 'right-9' : 'right-2'}`}>
          <ChevronDown className="w-3 h-3 text-gray-600" />
        </div>
        {canRemove && onRemove && (
          <button
            onClick={onRemove}
            className="absolute right-2 top-1/2 -translate-y-1/2 p-1 hover:bg-red-100 rounded-full text-red-500"
            title="Eliminar grafico"
          >
            <X className="w-3 h-3" />
          </button>
        )}
      </div>
    );
  }

  return (
    <div className="bg-gray-50 px-3 py-2 border-b">
      <span className="text-xs font-medium text-gray-700">{getChartName(value)}</span>
    </div>
  );
});
