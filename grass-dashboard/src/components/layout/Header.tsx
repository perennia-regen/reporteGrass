'use client';

import { Button } from '@/components/ui/button';
import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';

export function Header() {
  const { isEditing, setIsEditing } = useDashboardStore();
  const { establecimiento } = mockDashboardData;

  return (
    <header className="h-16 border-b bg-white px-4 flex items-center justify-between shrink-0">
      {/* Logo y título */}
      <div className="flex items-center gap-4">
        {/* Logo GRASS */}
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 bg-black rounded flex items-center justify-center">
            <svg
              viewBox="0 0 40 40"
              className="w-8 h-8"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              {/* Icono de pasto estilizado */}
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
            <p className="text-xs text-gray-500">Monitoreo Ambiental GRASS</p>
          </div>
        </div>

        {/* Separador */}
        <div className="h-8 w-px bg-gray-200" />

        {/* Info del establecimiento */}
        <div>
          <p className="font-semibold text-gray-900">{establecimiento.nombre}</p>
          <p className="text-xs text-gray-500">{establecimiento.fecha}</p>
        </div>
      </div>

      {/* Acciones */}
      <div className="flex items-center gap-2">
        <Button
          variant={isEditing ? 'default' : 'outline'}
          size="sm"
          onClick={() => setIsEditing(!isEditing)}
          className={isEditing ? 'bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]' : ''}
        >
          {isEditing ? 'Guardar' : 'Editar'}
        </Button>
        <Button variant="outline" size="sm">
          Compartir
        </Button>
        <Button variant="outline" size="sm">
          Exportar PDF
        </Button>
      </div>
    </header>
  );
}
