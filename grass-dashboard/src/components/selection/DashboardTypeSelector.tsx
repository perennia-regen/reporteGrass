'use client';

import { Card, CardContent } from '@/components/ui/card';
import { BarChart3, FileText, Leaf, Lock } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { DashboardType, DashboardTypeOption } from '@/lib/establecimientos-mock';

interface DashboardTypeSelectorProps {
  types: DashboardTypeOption[];
  selected: DashboardType | null;
  onSelect: (type: DashboardType) => void;
}

const typeIcons: Record<DashboardType, React.ReactNode> = {
  'monitoreo-corto': <BarChart3 className="w-5 h-5" />,
  'linea-base': <FileText className="w-5 h-5" />,
  'plan-pastoreo': <Leaf className="w-5 h-5" />,
};

export function DashboardTypeSelector({
  types,
  selected,
  onSelect,
}: DashboardTypeSelectorProps) {
  return (
    <div className="space-y-3">
      <label className="text-sm font-medium text-gray-700">
        Tipo de tablero
      </label>
      <div className="grid grid-cols-3 gap-3">
        {types.map((type) => (
          <Card
            key={type.id}
            className={cn(
              'transition-all py-4',
              type.enabled
                ? 'cursor-pointer hover:border-[var(--grass-green)]'
                : 'opacity-60 cursor-not-allowed',
              selected === type.id && type.enabled
                ? 'border-[var(--grass-green)] ring-2 ring-[var(--grass-green)]/20 bg-[var(--grass-green)]/5'
                : 'border-gray-200'
            )}
            onClick={() => type.enabled && onSelect(type.id)}
          >
            <CardContent className="flex flex-col items-center text-center py-0 gap-2">
              <div
                className={cn(
                  'w-12 h-12 rounded-full flex items-center justify-center relative',
                  selected === type.id && type.enabled
                    ? 'bg-[var(--grass-green)] text-white'
                    : type.enabled
                    ? 'bg-gray-100 text-gray-600'
                    : 'bg-gray-100 text-gray-400'
                )}
              >
                {typeIcons[type.id]}
                {!type.enabled && (
                  <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-gray-200 rounded-full flex items-center justify-center">
                    <Lock className="w-3 h-3 text-gray-500" />
                  </div>
                )}
              </div>
              <div>
                <h3
                  className={cn(
                    'font-semibold text-sm',
                    type.enabled
                      ? 'text-[var(--grass-green-dark)]'
                      : 'text-gray-400'
                  )}
                >
                  {type.nombre}
                </h3>
                <p className="text-xs text-gray-500 mt-1">{type.descripcion}</p>
              </div>
              {!type.enabled && (
                <span className="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded">
                  Próximamente
                </span>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
