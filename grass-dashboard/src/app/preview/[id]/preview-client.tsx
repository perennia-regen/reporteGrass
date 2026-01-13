'use client';

import { Canvas } from '@/components/layout/Canvas';
import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';
import { Logo } from '@/components/ui/logo';
import { useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { deserializeState } from '@/lib/url-state';

export default function PreviewClient({ }: { id: string }) {
  const { setIsEditing, setSelectedKPIs, setSugerenciaItems } = useDashboardStore();
  const updateContent = useDashboardStore((state) => state.updateContent);
  const { establecimiento } = mockDashboardData;
  const searchParams = useSearchParams();

  // En modo preview: desactivar edición y cargar estado desde URL
  useEffect(() => {
    setIsEditing(false);

    // Leer estado de la URL
    const stateParam = searchParams.get('s');
    if (stateParam) {
      const state = deserializeState(stateParam);
      if (state) {
        // Aplicar KPIs
        if (state.kpis) {
          setSelectedKPIs(state.kpis);
        }
        // Aplicar contenido editable
        if (state.content) {
          Object.entries(state.content).forEach(([key, value]) => {
            updateContent(key, value);
          });
        }
        // Aplicar sugerencias
        if (state.sug) {
          setSugerenciaItems(state.sug);
        }
      }
    }
  }, [setIsEditing, searchParams, setSelectedKPIs, updateContent, setSugerenciaItems]);

  return (
    <div className="h-screen flex flex-col overflow-hidden">
      {/* Header compacto con identificacion del predio */}
      <header className="h-16 border-b bg-white px-4 flex items-center shrink-0">
        <div className="flex items-center gap-4 w-full">
          {/* Logo */}
          <Logo
            size="xl"
            showText={false}
            logoSrc="/logo-grass.png"
            className="shrink-0"
          />

          {/* Titulo e info */}
          <div>
            <h1 className="text-lg font-bold text-black">
              Informe de Monitoreo
            </h1>
            <p className="text-xs text-gray-500">Monitoreo Ambiental GRASS</p>
          </div>

          {/* Separador */}
          <div className="hidden sm:block h-8 w-px bg-gray-200" />

          {/* Info del establecimiento */}
          <div className="hidden sm:block">
            <p className="font-semibold text-gray-900">{establecimiento.nombre}</p>
            <p className="text-xs text-gray-500">{establecimiento.fecha}</p>
          </div>

          {/* Separador */}
          <div className="hidden md:block h-8 w-px bg-gray-200" />

          {/* Info adicional: nodo, tecnico, has */}
          <div className="hidden md:flex items-center gap-3 text-xs text-gray-500">
            <span>{establecimiento.nodo}</span>
            <span className="text-gray-300">|</span>
            <span>{establecimiento.tecnico}</span>
            <span className="text-gray-300">|</span>
            <span>{establecimiento.areaTotal} has</span>
          </div>

          {/* Info compacta en movil */}
          <div className="sm:hidden ml-auto text-xs text-gray-500 text-right">
            <p className="font-semibold text-gray-900">{establecimiento.nombre}</p>
            <span>{establecimiento.nodo} - {establecimiento.areaTotal} has</span>
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
