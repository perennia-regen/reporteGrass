'use client';

import { Card, CardContent } from '@/components/ui/card';
import { MapPin, Calendar, Ruler } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { EstablecimientoOption } from '@/lib/establecimientos-mock';

interface EstablishmentSelectorProps {
  establecimientos: EstablecimientoOption[];
  selected: string | null;
  onSelect: (id: string) => void;
}

export function EstablishmentSelector({
  establecimientos,
  selected,
  onSelect,
}: EstablishmentSelectorProps) {
  return (
    <div className="space-y-3">
      <label className="text-sm font-medium text-gray-700">
        Seleccionar establecimiento
      </label>
      <div className="grid gap-3">
        {establecimientos.map((est) => (
          <Card
            key={est.id}
            className={cn(
              'cursor-pointer transition-all py-4 hover:border-[var(--grass-green)]',
              selected === est.id
                ? 'border-[var(--grass-green)] ring-2 ring-[var(--grass-green)]/20 bg-[var(--grass-green)]/5'
                : 'border-gray-200'
            )}
            onClick={() => onSelect(est.id)}
          >
            <CardContent className="flex items-center justify-between py-0">
              <div className="flex items-center gap-4">
                <div
                  className={cn(
                    'w-10 h-10 rounded-full flex items-center justify-center',
                    selected === est.id
                      ? 'bg-[var(--grass-green)] text-white'
                      : 'bg-gray-100 text-gray-600'
                  )}
                >
                  <MapPin className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-semibold text-[var(--grass-green-dark)]">
                    {est.nombre}
                  </h3>
                  <p className="text-sm text-gray-500">{est.provincia}</p>
                </div>
              </div>
              <div className="flex items-center gap-6 text-sm text-gray-500">
                <div className="flex items-center gap-1.5">
                  <Ruler className="w-4 h-4" />
                  <span>{est.hectareas} ha</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <Calendar className="w-4 h-4" />
                  <span>{est.ultimoMonitoreo}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
