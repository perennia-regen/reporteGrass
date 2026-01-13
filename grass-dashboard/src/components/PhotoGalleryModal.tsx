'use client';

import { useState } from 'react';
import { X, MapPin, Check } from 'lucide-react';
import { mockDashboardData } from '@/lib/mock-data';
import type { FotoMonitoreo } from '@/types/dashboard';

interface PhotoGalleryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSelect: (foto: FotoMonitoreo) => void;
  currentPhotoUrl?: string;
}

export function PhotoGalleryModal({ isOpen, onClose, onSelect, currentPhotoUrl }: PhotoGalleryModalProps) {
  const { fotos, establecimiento } = mockDashboardData;
  const [selectedPhoto, setSelectedPhoto] = useState<FotoMonitoreo | null>(null);

  if (!isOpen) return null;

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  const handleConfirm = () => {
    if (selectedPhoto) {
      onSelect(selectedPhoto);
      onClose();
    }
  };

  // Location string from establecimiento
  const ubicacionStr = `${establecimiento.ubicacion.distrito}, ${establecimiento.ubicacion.departamento}, ${establecimiento.ubicacion.provincia}`;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={handleBackdropClick}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />

      {/* Modal */}
      <div className="relative bg-white rounded-2xl shadow-2xl p-6 max-w-4xl w-full mx-4 max-h-[85vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-lg font-semibold text-gray-900">Galeria de Fotos</h2>
            <p className="text-sm text-gray-500">Selecciona una foto del monitoreo</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Gallery Grid */}
        <div className="flex-1 overflow-y-auto">
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {fotos.map((foto, index) => {
              const isSelected = selectedPhoto?.url === foto.url;
              const isCurrent = currentPhotoUrl === foto.url;

              return (
                <div
                  key={index}
                  className={`group cursor-pointer rounded-lg overflow-hidden border-2 transition-all ${
                    isSelected
                      ? 'border-[var(--grass-green)] ring-2 ring-[var(--grass-green)]/20'
                      : isCurrent
                        ? 'border-blue-400'
                        : 'border-transparent hover:border-gray-300'
                  }`}
                  onClick={() => setSelectedPhoto(foto)}
                >
                  {/* Photo placeholder */}
                  <div className="aspect-video bg-gray-100 flex items-center justify-center text-gray-400 relative">
                    <svg
                      className="w-10 h-10"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={1.5}
                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                      />
                    </svg>

                    {/* Selection indicator */}
                    {isSelected && (
                      <div className="absolute top-2 right-2 bg-[var(--grass-green)] text-white rounded-full p-1">
                        <Check className="w-4 h-4" />
                      </div>
                    )}

                    {/* Current indicator */}
                    {isCurrent && !isSelected && (
                      <div className="absolute top-2 right-2 bg-blue-500 text-white text-xs px-2 py-0.5 rounded">
                        Actual
                      </div>
                    )}
                  </div>

                  {/* Photo info */}
                  <div className="p-3 bg-white">
                    <p className="font-medium text-sm text-[var(--grass-green-dark)] truncate">
                      {foto.sitio}
                    </p>
                    <div className="flex items-center gap-1 mt-1 text-xs text-gray-500">
                      <MapPin className="w-3 h-3" />
                      <span className="truncate">{ubicacionStr}</span>
                    </div>
                    <p className="text-xs text-gray-400 mt-1 line-clamp-2">
                      {foto.comentario}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-end gap-3 mt-4 pt-4 border-t">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
          >
            Cancelar
          </button>
          <button
            onClick={handleConfirm}
            disabled={!selectedPhoto}
            className={`px-4 py-2 text-sm rounded-lg transition-colors ${
              selectedPhoto
                ? 'bg-[var(--grass-green)] text-white hover:bg-[var(--grass-green-dark)]'
                : 'bg-gray-200 text-gray-400 cursor-not-allowed'
            }`}
          >
            Seleccionar
          </button>
        </div>
      </div>
    </div>
  );
}
