'use client';

import { Header } from '@/components/layout/Header';
import { Canvas } from '@/components/layout/Canvas';
import { useDashboardStore } from '@/lib/dashboard-store';
import { useEffect } from 'react';

export default function PreviewPage({ params }: { params: { id: string } }) {
  const { setIsEditing } = useDashboardStore();

  // En modo preview, desactivar la edición
  useEffect(() => {
    setIsEditing(false);
  }, [setIsEditing]);

  return (
    <div className="h-screen flex flex-col overflow-hidden">
      {/* Header simplificado para preview */}
      <header className="h-16 border-b bg-white px-4 flex items-center justify-between shrink-0">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 bg-black rounded flex items-center justify-center">
              <svg
                viewBox="0 0 40 40"
                className="w-8 h-8"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <path
                  d="M20 5 L20 15 M15 8 L15 18 M25 8 L25 18 M10 12 L10 20 M30 12 L30 20"
                  stroke="#4CAF50"
                  strokeWidth="2"
                  strokeLinecap="round"
                />
                <text
                  x="20"
                  y="32"
                  textAnchor="middle"
                  fill="white"
                  fontSize="8"
                  fontWeight="bold"
                >
                  GRASS
                </text>
              </svg>
            </div>
            <div>
              <h1 className="text-lg font-bold text-[var(--grass-green-dark)]">
                Informe de Monitoreo
              </h1>
              <p className="text-xs text-gray-500">Vista de solo lectura</p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-500 bg-gray-100 px-3 py-1 rounded">
            Modo Preview
          </span>
        </div>
      </header>

      {/* Contenido sin sidebar (solo lectura) */}
      <div className="flex flex-1 overflow-hidden">
        <main className="flex-1 bg-gray-50 overflow-auto">
          <Canvas />
        </main>
      </div>
    </div>
  );
}
