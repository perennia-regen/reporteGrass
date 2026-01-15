'use client';

import { useState, useRef, useEffect, useMemo } from 'react';
import dynamic from 'next/dynamic';
import { Button } from '@/components/ui/button';
import { Logo } from '@/components/ui/logo';
import { useDashboardStore } from '@/lib/dashboard-store';
import { mockDashboardData } from '@/lib/mock-data';
import { createShareUrl, type ShareableState } from '@/lib/url-state';
import { Eye, Send, Printer, ChevronDown, Link2, Pencil, Check, ExternalLink, Home } from 'lucide-react';
import NextLink from 'next/link';

// Dynamic import for PDF Preview Modal - only loads when needed
const PDFPreviewModal = dynamic(
  () => import('@/components/PDFPreviewModal').then((mod) => mod.PDFPreviewModal),
  {
    loading: () => (
      <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
        <div className="bg-white rounded-lg p-6">
          <div className="animate-pulse text-gray-600">Cargando vista previa...</div>
        </div>
      </div>
    ),
    ssr: false,
  }
);

export function Header() {
  const { isEditing, setIsEditing, editableContent, selectedKPIs, sugerenciaItems } = useDashboardStore();
  const { establecimiento } = mockDashboardData;
  const [showPDFPreview, setShowPDFPreview] = useState(false);
  const [showSendDropdown, setShowSendDropdown] = useState(false);
  const [showToast, setShowToast] = useState<string | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Crear estado compartible con la configuración actual
  const shareableState: ShareableState = useMemo(() => ({
    kpis: selectedKPIs,
    content: editableContent,
    sug: sugerenciaItems,
    v: 1, // versión del formato
  }), [selectedKPIs, editableContent, sugerenciaItems]);

  // Generar URL con estado incluido
  const shareUrl = useMemo(() => {
    if (typeof window === 'undefined') return '/preview/';
    return createShareUrl(window.location.origin, shareableState, establecimiento.nombre);
  }, [shareableState, establecimiento.nombre]);

  // ID corto para el path
  const previewId = useMemo(() => {
    return btoa(establecimiento.nombre).substring(0, 8);
  }, [establecimiento.nombre]);

  // Cerrar dropdown al hacer click afuera
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setShowSendDropdown(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleCopyLink = () => {
    navigator.clipboard.writeText(shareUrl).then(() => {
      setShowToast('Link copiado');
      setShowSendDropdown(false);
      setTimeout(() => setShowToast(null), 2000);
    });
  };

  const handleWhatsApp = () => {
    const message = encodeURIComponent(`Mira el informe de monitoreo de ${establecimiento.nombre}: ${shareUrl}`);
    window.open(`https://wa.me/?text=${message}`, '_blank');
    setShowSendDropdown(false);
  };

  const handlePrint = () => {
    setShowPDFPreview(true);
  };

  const handleSave = () => {
    // Aquí iría la lógica de guardado
    setIsEditing(false);
    setShowToast('Cambios guardados');
    setTimeout(() => setShowToast(null), 2000);
  };

  return (
    <div className="shrink-0">
      <header className="h-16 border-b bg-white px-4 flex items-center justify-between">
        {/* Volver y Logo */}
        <div className="flex items-center gap-4">
          <NextLink href="/">
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8 text-gray-500 hover:text-gray-900"
            >
              <Home className="w-4 h-4" />
            </Button>
          </NextLink>

          <div className="h-8 w-px bg-gray-200" />

          <Logo
            size="xl"
            showText={false}
            logoSrc="/logo-grass.png"
          />
          <div>
            <h1 className="text-lg font-bold text-black">
              Editor de Informe
            </h1>
            <p className="text-xs text-gray-500">Monitoreo Ambiental GRASS</p>
          </div>

          <div className="h-8 w-px bg-gray-200" />

          <div>
            <p className="font-semibold text-gray-900">{establecimiento.nombre}</p>
            <p className="text-xs text-gray-500">{establecimiento.fecha}</p>
          </div>
        </div>

        {/* Centro - Modo edición */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2">
          {!isEditing ? (
            <Button
              variant="outline"
              size="sm"
              onClick={() => setIsEditing(true)}
              className="gap-2"
            >
              <Pencil className="w-4 h-4" />
              Editar informe
            </Button>
          ) : (
            <div className="flex items-center gap-2">
              <div className="flex items-center gap-2 bg-amber-50 border border-amber-200 rounded-lg px-3 py-1.5">
                <Pencil className="w-3.5 h-3.5 text-amber-600" />
                <span className="text-sm text-amber-700 font-medium">Editando</span>
              </div>
              <Button
                size="sm"
                onClick={handleSave}
                className="gap-1.5 bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)] text-white"
              >
                <Check className="w-4 h-4" />
                Guardar
              </Button>
            </div>
          )}
        </div>

        {/* Acciones derecha */}
        <div className="flex items-center gap-2 relative">
          {/* Vista Productor - navega a preview */}
          <NextLink href={`/preview/${previewId}`} target="_blank">
            <Button
              variant="outline"
              size="sm"
              className="gap-1.5"
            >
              <Eye className="w-4 h-4" />
              Vista Productor
              <ExternalLink className="w-3 h-3 text-gray-400" />
            </Button>
          </NextLink>

          {/* Botón Descargar PDF */}
          <Button
            size="sm"
            onClick={handlePrint}
            className="gap-1 bg-gray-700 hover:bg-gray-800 text-white"
          >
            <Printer className="w-4 h-4" />
            Descargar PDF
          </Button>

          {/* Botón Enviar con dropdown */}
          <div className="relative" ref={dropdownRef}>
            <Button
              size="sm"
              onClick={() => setShowSendDropdown(!showSendDropdown)}
              className="gap-1 bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)] text-white"
              data-tour="share-button"
            >
              <Send className="w-4 h-4" />
              Enviar
              <ChevronDown className={`w-3 h-3 transition-transform ${showSendDropdown ? 'rotate-180' : ''}`} />
            </Button>

            {/* Dropdown */}
            {showSendDropdown && (
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border py-1 z-50">
                <button
                  onClick={handleWhatsApp}
                  className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 flex items-center gap-2"
                >
                  <svg className="w-4 h-4 text-green-600" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
                  </svg>
                  Enviar por WhatsApp
                </button>
                <button
                  onClick={handleCopyLink}
                  className="w-full px-4 py-2 text-left text-sm hover:bg-gray-50 flex items-center gap-2"
                >
                  <Link2 className="w-4 h-4 text-gray-500" />
                  Copiar link
                </button>
              </div>
            )}
          </div>

          {/* Toast */}
          {showToast && (
            <div className="absolute top-full right-0 mt-2 bg-[var(--grass-green)] text-white px-4 py-2 rounded-md shadow-lg text-sm z-50 flex items-center gap-2">
              <Check className="w-4 h-4" />
              {showToast}
            </div>
          )}
        </div>
      </header>

      {/* Modal de preview del PDF - only mounted when needed */}
      {showPDFPreview && (
        <PDFPreviewModal
          isOpen={showPDFPreview}
          onClose={() => setShowPDFPreview(false)}
          observacionGeneral={editableContent.observacionGeneral}
          comentarioFinal={editableContent.comentarioFinal}
        />
      )}
    </div>
  );
}
