'use client';

import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';
import { EditableText } from '@/components/editor/EditableText';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import type { SugerenciaItem } from '@/types/dashboard';

interface TablaEstratoProps {
  item: SugerenciaItem;
}

export function TablaEstrato({ item }: TablaEstratoProps) {
  const { editableContent, updateContent } = useDashboardStore();
  const { estratos } = mockDashboardData;

  return (
    <div className="p-2">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-32">Estrato</TableHead>
            <TableHead>Recomendación</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {estratos.map((estrato) => (
            <TableRow key={estrato.id}>
              <TableCell>
                <div className="flex items-center gap-2">
                  <div
                    className="w-3 h-3 rounded-full shrink-0"
                    style={{ backgroundColor: estrato.color }}
                  />
                  <span className="font-medium text-sm">{estrato.nombre}</span>
                </div>
              </TableCell>
              <TableCell>
                <EditableText
                  value={editableContent[`tabla_${item.id}_${estrato.id}`] || ''}
                  onChange={(value) => updateContent(`tabla_${item.id}_${estrato.id}`, value)}
                  placeholder="Ingrese recomendación…"
                  className="text-sm"
                />
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
