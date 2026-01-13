'use client';

import { useState, useMemo } from 'react';
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
  const [selectedSections, setSelectedSections] = useState<PDFSection[]>(
    PDF_SECTIONS.map(s => s.id)
  );

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

  if (!isOpen) return null;

  const handleToggleSection = (sectionId: PDFSection) => {
    setSelectedSections(prev =>
      prev.includes(sectionId)
        ? prev.filter(s => s !== sectionId)
        : [...prev, sectionId]
    );
  };

  const handleToggleTab = (tab: string) => {
    const tabSections = sectionsByTab[tab].map(s => s.id);
    const allSelected = tabSections.every(s => selectedSections.includes(s));

    if (allSelected) {
      setSelectedSections(prev => prev.filter(s => !tabSections.includes(s)));
    } else {
      setSelectedSections(prev => [...new Set([...prev, ...tabSections])]);
    }
  };

  const handleSelectAll = () => {
    setSelectedSections(PDF_SECTIONS.map(s => s.id));
  };

  const handleDeselectAll = () => {
    setSelectedSections([]);
  };

  const handleDownload = async () => {
    if (selectedSections.length === 0) return;

    setIsDownloading(true);
    try {
      await generatePDF(observacionGeneral, comentarioFinal, selectedSections);
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
    return sectionsByTab[tab].every(s => selectedSections.includes(s.id));
  };

  const isTabPartiallySelected = (tab: string) => {
    const tabSections = sectionsByTab[tab];
    const selectedCount = tabSections.filter(s => selectedSections.includes(s.id)).length;
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
              disabled={isDownloading || selectedSections.length === 0}
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
          <div className="w-64 border-r bg-gray-50 p-4 overflow-y-auto">
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
                        checked={selectedSections.includes(section.id)}
                        onChange={() => handleToggleSection(section.id)}
                        className="w-4 h-4 rounded border-gray-300 text-[var(--grass-green)] focus:ring-[var(--grass-green)]"
                      />
                      <span className="text-sm text-gray-600">{section.label}</span>
                    </label>
                  ))}
                </div>
              </div>
            ))}

            {selectedSections.length === 0 && (
              <p className="text-sm text-amber-600 mt-4">
                Selecciona al menos una sección para generar el PDF
              </p>
            )}
          </div>

          {/* PDF Viewer */}
          <div className="flex-1 overflow-hidden">
            {selectedSections.length > 0 ? (
              <PDFViewer
                style={{ width: '100%', height: '100%', border: 'none' }}
                showToolbar={true}
              >
                <ReportePDF
                  observacionGeneral={observacionGeneral}
                  comentarioFinal={comentarioFinal}
                  selectedSections={selectedSections}
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
