'use client';

import { useState, useMemo, useCallback } from 'react';
import { PDFViewer } from '@react-pdf/renderer';
import { Button } from '@/components/ui/button';
import { ReportePDF, generatePDF, PDF_SECTIONS, type PDFSection } from '@/lib/export-pdf';

interface PDFPreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
  observacionGeneral: string;
  comentarioFinal: string;
}

export function PDFPreviewModal({
  isOpen,
  onClose,
  observacionGeneral,
  comentarioFinal,
}: PDFPreviewModalProps) {
  const [isDownloading, setIsDownloading] = useState(false);

  // Estado para los checkboxes (lo que el usuario está seleccionando)
  const [pendingSections, setPendingSections] = useState<PDFSection[]>(
    PDF_SECTIONS.map(s => s.id)
  );

  // Estado para las secciones aplicadas al PDF (solo cambia con el botón Actualizar)
  const [appliedSections, setAppliedSections] = useState<PDFSection[]>(
    PDF_SECTIONS.map(s => s.id)
  );

  // Indica si hay cambios pendientes de aplicar
  const hasPendingChanges = useMemo(() => {
    if (pendingSections.length !== appliedSections.length) return true;
    return !pendingSections.every(s => appliedSections.includes(s));
  }, [pendingSections, appliedSections]);

  // Agrupar secciones por tab
  const sectionsByTab = useMemo(() => {
    const grouped: Record<string, typeof PDF_SECTIONS> = {};
    PDF_SECTIONS.forEach(section => {
      if (!grouped[section.tab]) {
        grouped[section.tab] = [];
      }
      grouped[section.tab].push(section);
    });
    return grouped;
  }, []);

  const handleApplyChanges = useCallback(() => {
    setAppliedSections([...pendingSections]);
  }, [pendingSections]);

  // Key estable para el PDFViewer basado en las secciones aplicadas
  const pdfKey = useMemo(() => appliedSections.sort().join(','), [appliedSections]);

  if (!isOpen) return null;

  const handleToggleSection = (sectionId: PDFSection) => {
    setPendingSections(prev =>
      prev.includes(sectionId)
        ? prev.filter(s => s !== sectionId)
        : [...prev, sectionId]
    );
  };

  const handleToggleTab = (tab: string) => {
    const tabSections = sectionsByTab[tab].map(s => s.id);
    const allSelected = tabSections.every(s => pendingSections.includes(s));

    if (allSelected) {
      setPendingSections(prev => prev.filter(s => !tabSections.includes(s)));
    } else {
      setPendingSections(prev => [...new Set([...prev, ...tabSections])]);
    }
  };

  const handleSelectAll = () => {
    setPendingSections(PDF_SECTIONS.map(s => s.id));
  };

  const handleDeselectAll = () => {
    setPendingSections([]);
  };

  const handleDownload = async () => {
    if (appliedSections.length === 0) return;

    setIsDownloading(true);
    try {
      await generatePDF(observacionGeneral, comentarioFinal, appliedSections);
    } catch (error) {
      console.error('Error al descargar PDF:', error);
    } finally {
      setIsDownloading(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  const isTabFullySelected = (tab: string) => {
    return sectionsByTab[tab].every(s => pendingSections.includes(s.id));
  };

  const isTabPartiallySelected = (tab: string) => {
    const tabSections = sectionsByTab[tab];
    const selectedCount = tabSections.filter(s => pendingSections.includes(s.id)).length;
    return selectedCount > 0 && selectedCount < tabSections.length;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div
        className="absolute inset-0 bg-black/50"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative bg-white rounded-lg shadow-xl w-[95vw] h-[90vh] max-w-7xl flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b">
          <h2 className="text-lg font-semibold text-gray-900">
            Vista Previa del Reporte
          </h2>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={handlePrint}
            >
              Imprimir
            </Button>
            <Button
              variant="default"
              size="sm"
              onClick={handleDownload}
              disabled={isDownloading || appliedSections.length === 0}
              className="bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]"
            >
              {isDownloading ? 'Descargando...' : 'Descargar PDF'}
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={onClose}
            >
              Cerrar
            </Button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 flex overflow-hidden">
          {/* Sidebar con checkboxes */}
          <div className="w-72 border-r bg-gray-50 p-4 overflow-y-auto flex flex-col">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-medium text-gray-900">Secciones</h3>
              <div className="flex gap-1">
                <button
                  onClick={handleSelectAll}
                  className="text-xs text-[var(--grass-green)] hover:underline"
                >
                  Todas
                </button>
                <span className="text-gray-300">|</span>
                <button
                  onClick={handleDeselectAll}
                  className="text-xs text-gray-500 hover:underline"
                >
                  Ninguna
                </button>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto">
              {Object.entries(sectionsByTab).map(([tab, sections]) => (
                <div key={tab} className="mb-4">
                  {/* Tab header */}
                  <label className="flex items-center gap-2 mb-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={isTabFullySelected(tab)}
                      ref={input => {
                        if (input) {
                          input.indeterminate = isTabPartiallySelected(tab);
                        }
                      }}
                      onChange={() => handleToggleTab(tab)}
                      className="w-4 h-4 rounded border-gray-300 text-[var(--grass-green)] focus:ring-[var(--grass-green)]"
                    />
                    <span className="font-medium text-gray-700">{tab}</span>
                  </label>

                  {/* Secciones del tab */}
                  <div className="ml-6 space-y-2">
                    {sections.map(section => (
                      <label
                        key={section.id}
                        className="flex items-center gap-2 cursor-pointer"
                      >
                        <input
                          type="checkbox"
                          checked={pendingSections.includes(section.id)}
                          onChange={() => handleToggleSection(section.id)}
                          className="w-4 h-4 rounded border-gray-300 text-[var(--grass-green)] focus:ring-[var(--grass-green)]"
                        />
                        <span className="text-sm text-gray-600">{section.label}</span>
                      </label>
                    ))}
                  </div>
                </div>
              ))}
            </div>

            {/* Botón de actualizar preview */}
            <div className="pt-4 border-t mt-4">
              <Button
                variant={hasPendingChanges ? 'default' : 'outline'}
                size="sm"
                onClick={handleApplyChanges}
                disabled={pendingSections.length === 0}
                className={`w-full ${hasPendingChanges ? 'bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]' : ''}`}
              >
                {hasPendingChanges ? 'Actualizar Preview' : 'Sin cambios'}
              </Button>
              {pendingSections.length === 0 && (
                <p className="text-xs text-amber-600 mt-2 text-center">
                  Selecciona al menos una sección
                </p>
              )}
            </div>
          </div>

          {/* PDF Viewer */}
          <div className="flex-1 overflow-hidden">
            {appliedSections.length > 0 ? (
              <PDFViewer
                key={pdfKey}
                style={{ width: '100%', height: '100%', border: 'none' }}
                showToolbar={true}
              >
                <ReportePDF
                  observacionGeneral={observacionGeneral}
                  comentarioFinal={comentarioFinal}
                  selectedSections={appliedSections}
                />
              </PDFViewer>
            ) : (
              <div className="flex items-center justify-center h-full bg-gray-100">
                <p className="text-gray-500">Selecciona secciones para ver la vista previa</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
