'use client';

import { Wrench, Eye } from 'lucide-react';

export function EditorBanner() {
  return (
    <div className="bg-amber-50 border-b border-amber-200 px-4 py-2.5 flex items-center gap-3">
      <div className="flex items-center gap-2 text-amber-700">
        <Wrench className="w-4 h-4" />
        <span className="text-sm font-medium">
          Vista de edición
        </span>
      </div>
      <div className="h-4 w-px bg-amber-300" />
      <div className="flex items-center gap-1.5 text-amber-600">
        <Eye className="w-4 h-4" />
        <span className="text-sm">
          El productor no ve esta barra lateral ni las herramientas de edición
        </span>
      </div>
      <span className="ml-auto text-xs font-medium text-amber-700 bg-amber-100 px-2.5 py-1 rounded-full border border-amber-200">
        Solo para técnicos
      </span>
    </div>
  );
}
