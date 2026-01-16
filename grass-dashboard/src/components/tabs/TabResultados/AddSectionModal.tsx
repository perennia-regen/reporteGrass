'use client';

import { useState } from 'react';
import { X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface AddSectionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (title: string, position: number) => void;
}

const POSITION_OPTIONS = [
  { value: 0, label: 'Después de ISE' },
  { value: 1, label: 'Después de Procesos del Ecosistema' },
  { value: 2, label: 'Después de Disponibilidad y Calidad Forrajera' },
  { value: 3, label: 'Después de Patrón e Intensidad de Pastoreo' },
];

export function AddSectionModal({ isOpen, onClose, onAdd }: AddSectionModalProps) {
  const [title, setTitle] = useState('');
  const [position, setPosition] = useState(3); // Por defecto después de Pastoreo

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (title.trim()) {
      onAdd(title.trim(), position);
      setTitle('');
      setPosition(3);
      onClose();
    }
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={handleBackdropClick}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />

      {/* Modal */}
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="add-section-title"
        className="relative bg-white rounded-2xl shadow-2xl p-6 max-w-md w-full mx-4"
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h2 id="add-section-title" className="text-lg font-semibold text-gray-900">Nueva Sección</h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            aria-label="Cerrar modal"
          >
            <X className="w-5 h-5 text-gray-500" aria-hidden="true" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="section-title" className="block text-sm font-medium text-gray-700 mb-1">
              Título de la sección
            </label>
            <Input
              id="section-title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Ej: Análisis Adicional"
              autoFocus
            />
          </div>

          <div>
            <label htmlFor="section-position" className="block text-sm font-medium text-gray-700 mb-1">
              Ubicación
            </label>
            <select
              id="section-position"
              value={position}
              onChange={(e) => setPosition(Number(e.target.value))}
              className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-2 focus:ring-[var(--grass-green)] focus:border-transparent"
            >
              {POSITION_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          {/* Actions */}
          <div className="flex items-center justify-end gap-3 mt-6 pt-4 border-t">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={!title.trim()}
              className="bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)] text-white"
            >
              Crear Sección
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
