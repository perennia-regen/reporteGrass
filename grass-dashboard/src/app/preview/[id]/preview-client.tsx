'use client';

import { Canvas } from '@/components/layout/Canvas';
import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';
import { Logo } from '@/components/ui/logo';
import { useEffect } from 'react';

export default function PreviewClient({ id }: { id: string }) {
  const { setIsEditing } = useDashboardStore();
  const { establecimiento } = mockDashboardData;

  // En modo preview, desactivar la edición
  useEffect(() => {
    setIsEditing(false);
  }, [setIsEditing]);

  return (
    <div className="h-screen flex flex-col overflow-hidden">
      {/* Header compacto con identificacion del predio */}
      <header className="border-b bg-[var(--grass-green-dark)] text-white px-3 py-2 sm:px-4 sm:py-2.5 shrink-0">
        <div className="flex items-center gap-3">
          {/* Logo */}
          <Logo
            size="sm"
            showText={false}
            logoSrc="/logo-grass.png"
            className="shrink-0"
          />

          {/* Info izquierda: nombre y fecha */}
          <div className="min-w-0">
            <h1 className="text-sm sm:text-base font-bold text-white truncate">
              {establecimiento.nombre}
            </h1>
            <p className="text-xs text-white/80">
              {establecimiento.fecha} | {establecimiento.codigo}
            </p>
          </div>

          {/* Separador */}
          <div className="hidden sm:block h-8 w-px bg-white/30" />

          {/* Info derecha: nodo, tecnico, has */}
          <div className="hidden sm:flex items-center gap-3 text-xs text-white/90">
            <span>{establecimiento.nodo}</span>
            <span className="text-white/50">|</span>
            <span>{establecimiento.tecnico}</span>
            <span className="text-white/50">|</span>
            <span>{establecimiento.areaTotal} has</span>
          </div>

          {/* Info compacta en movil */}
          <div className="sm:hidden ml-auto text-xs text-white/80 text-right">
            <span>{establecimiento.nodo}</span>
            <span className="mx-1">-</span>
            <span>{establecimiento.areaTotal} has</span>
          </div>
        </div>
      </header>

      {/* Contenido sin sidebar (solo lectura) - Responsive */}
      <div className="flex flex-1 overflow-hidden">
        <main className="flex-1 bg-gray-50 overflow-auto">
          <Canvas />
        </main>
      </div>
    </div>
  );
}
