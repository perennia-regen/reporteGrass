'use client';

import { useDashboardStore } from '@/lib/dashboard-store';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Plus, X, Trash2 } from 'lucide-react';
import type { SugerenciaItem } from '@/types/dashboard';

interface TablaPersonalizableProps {
  item: SugerenciaItem;
}

export function TablaPersonalizable({ item }: TablaPersonalizableProps) {
  const { isEditing, updateSugerenciaItem } = useDashboardStore();
  const config = item.tableConfig || { columns: ['Columna 1'], rows: [] };

  const addColumn = () => {
    const newColumns = [...config.columns, `Columna ${config.columns.length + 1}`];
    updateSugerenciaItem(item.id, {
      tableConfig: { ...config, columns: newColumns },
    });
  };

  const removeColumn = (index: number) => {
    if (config.columns.length <= 1) return;
    const removedColumn = config.columns[index];
    const newColumns = config.columns.filter((_, i) => i !== index);
    const newRows = config.rows.map((row) => {
      const newValues = { ...row.values };
      delete newValues[removedColumn];
      return { ...row, values: newValues };
    });
    updateSugerenciaItem(item.id, {
      tableConfig: { columns: newColumns, rows: newRows },
    });
  };

  const updateColumnName = (index: number, name: string) => {
    const oldName = config.columns[index];
    const newColumns = [...config.columns];
    newColumns[index] = name;
    // Actualizar keys en rows
    const newRows = config.rows.map((row) => {
      const newValues = { ...row.values };
      if (oldName in newValues) {
        newValues[name] = newValues[oldName];
        delete newValues[oldName];
      }
      return { ...row, values: newValues };
    });
    updateSugerenciaItem(item.id, {
      tableConfig: { columns: newColumns, rows: newRows },
    });
  };

  const addRow = () => {
    const newRow = {
      id: `row-${Date.now()}`,
      values: config.columns.reduce(
        (acc, col) => ({ ...acc, [col]: '' }),
        {} as Record<string, string>
      ),
    };
    updateSugerenciaItem(item.id, {
      tableConfig: { ...config, rows: [...config.rows, newRow] },
    });
  };

  const removeRow = (rowId: string) => {
    updateSugerenciaItem(item.id, {
      tableConfig: {
        ...config,
        rows: config.rows.filter((r) => r.id !== rowId),
      },
    });
  };

  const updateCell = (rowId: string, column: string, value: string) => {
    const newRows = config.rows.map((row) =>
      row.id === rowId ? { ...row, values: { ...row.values, [column]: value } } : row
    );
    updateSugerenciaItem(item.id, { tableConfig: { ...config, rows: newRows } });
  };

  return (
    <div className="p-2">
      <Table>
        <TableHeader>
          <TableRow>
            {config.columns.map((col, index) => (
              <TableHead key={index} className="relative">
                {isEditing ? (
                  <div className="flex items-center gap-1">
                    <Input
                      value={col}
                      onChange={(e) => updateColumnName(index, e.target.value)}
                      className="h-7 text-xs"
                    />
                    {config.columns.length > 1 && (
                      <button
                        onClick={() => removeColumn(index)}
                        className="text-red-400 hover:text-red-600 shrink-0"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    )}
                  </div>
                ) : (
                  col
                )}
              </TableHead>
            ))}
            {isEditing && <TableHead className="w-8" />}
          </TableRow>
        </TableHeader>
        <TableBody>
          {config.rows.length === 0 && !isEditing && (
            <TableRow>
              <TableCell
                colSpan={config.columns.length}
                className="text-center text-gray-400 italic py-4"
              >
                Sin datos
              </TableCell>
            </TableRow>
          )}
          {config.rows.map((row) => (
            <TableRow key={row.id}>
              {config.columns.map((col) => (
                <TableCell key={col}>
                  {isEditing ? (
                    <Input
                      value={row.values[col] || ''}
                      onChange={(e) => updateCell(row.id, col, e.target.value)}
                      className="h-7 text-xs"
                    />
                  ) : (
                    row.values[col] || '-'
                  )}
                </TableCell>
              ))}
              {isEditing && (
                <TableCell>
                  <button
                    onClick={() => removeRow(row.id)}
                    className="text-red-400 hover:text-red-600"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </TableCell>
              )}
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {isEditing && (
        <div className="flex gap-2 mt-2">
          <Button variant="outline" size="sm" onClick={addRow}>
            <Plus className="w-3 h-3 mr-1" /> Fila
          </Button>
          <Button variant="outline" size="sm" onClick={addColumn}>
            <Plus className="w-3 h-3 mr-1" /> Columna
          </Button>
        </div>
      )}
    </div>
  );
}
