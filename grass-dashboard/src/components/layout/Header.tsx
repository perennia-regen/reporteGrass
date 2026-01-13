'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Logo } from '@/components/ui/logo';
import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';
import { generatePDF } from '@/lib/export-pdf';
import { EditorBanner } from './EditorBanner';

export function Header() {
  const { isEditing, setIsEditing, editableContent } = useDashboardStore();
  const { establecimiento } = mockDashboardData;
  const [isExporting, setIsExporting] = useState(false);
  const [showShareToast, setShowShareToast] = useState(false);

  const handleExportPDF = async () => {
    setIsExporting(true);
    try {
      await generatePDF(editableContent.observacionGeneral, editableContent.comentarioFinal);
    } catch (error) {
      console.error('Error al exportar PDF:', error);
    } finally {
      setIsExporting(false);
    }
  };

  const handleShare = () => {
    // Generar un ID único para el dashboard
    const shareId = btoa(JSON.stringify({
      timestamp: Date.now(),
      establecimiento: establecimiento.nombre,
    })).substring(0, 12);

    const shareUrl = `${window.location.origin}/preview/${shareId}`;

    // Copiar al portapapeles
    navigator.clipboard.writeText(shareUrl).then(() => {
      setShowShareToast(true);
      setTimeout(() => setShowShareToast(false), 3000);
    });
  };

  return (
    <div className="shrink-0">
      <header className="h-16 border-b bg-white px-4 flex items-center justify-between">
        {/* Logo y título */}
        <div className="flex items-center gap-4">
          {/* Logo GRASS - Usa el logo oficial de GRASS */}
          <Logo
            size="xl"
            showText={false}
            logoSrc="/logo-grass.png"
          />
          <div>
            <h1 className="text-lg font-bold text-[var(--grass-green)]">
              Informe de Monitoreo
            </h1>
            <p className="text-xs text-gray-500">Monitoreo Ambiental GRASS</p>
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
        <div className="flex items-center gap-2 relative">
          <Button
            variant={isEditing ? 'default' : 'outline'}
            size="sm"
            onClick={() => setIsEditing(!isEditing)}
            className={isEditing ? 'bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]' : ''}
          >
            {isEditing ? 'Guardar' : 'Editar'}
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={handleShare}
            data-tour="share-button"
          >
            Compartir
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={handleExportPDF}
            disabled={isExporting}
          >
            {isExporting ? 'Exportando...' : 'Exportar PDF'}
          </Button>

          {/* Toast de link copiado */}
          {showShareToast && (
            <div className="absolute top-full right-0 mt-2 bg-[var(--grass-green)] text-white px-4 py-2 rounded-md shadow-lg text-sm z-50">
              Link copiado al portapapeles
            </div>
          )}
        </div>
      </header>

      {/* Banner de modo edición */}
      {isEditing && <EditorBanner />}
    </div>
  );
}
