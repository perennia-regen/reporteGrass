'use client';

import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

interface LoadingModalProps {
  isOpen: boolean;
  establecimientoNombre: string;
}

const loadingMessages = [
  'Cargando datos del establecimiento...',
  'Procesando indicadores ecosistémicos...',
  'Generando gráficos...',
  'Preparando el tablero...',
];

export function LoadingModal({ isOpen, establecimientoNombre }: LoadingModalProps) {
  const [messageIndex, setMessageIndex] = useState(0);

  useEffect(() => {
    if (!isOpen) {
      return;
    }

    // Reset to first message when modal opens (via microtask to satisfy linter)
    queueMicrotask(() => setMessageIndex(0));

    const interval = setInterval(() => {
      setMessageIndex((prev) => (prev + 1) % loadingMessages.length);
    }, 800);

    return () => clearInterval(interval);
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />

      {/* Modal */}
      <div className="relative bg-white rounded-2xl shadow-2xl p-8 max-w-md w-full mx-4 text-center">
        {/* Logo animation */}
        <div className="w-20 h-20 mx-auto mb-6 relative">
          <div className="absolute inset-0 rounded-full bg-[var(--grass-green)]/20 animate-ping" />
          <div className="relative w-full h-full rounded-full bg-[var(--grass-green)] flex items-center justify-center">
            <Loader2 className="w-10 h-10 text-white animate-spin" />
          </div>
        </div>

        <h2 className="text-xl font-bold text-[var(--grass-green-dark)] mb-2">
          Generando tablero
        </h2>

        <p className="text-gray-600 mb-4">
          {establecimientoNombre}
        </p>

        <div className="h-6">
          <p className="text-sm text-gray-500 animate-pulse">
            {loadingMessages[messageIndex]}
          </p>
        </div>

        {/* Progress bar */}
        <div className="mt-6 h-1.5 bg-gray-200 rounded-full overflow-hidden">
          <div
            className="h-full bg-[var(--grass-green)] rounded-full animate-progress"
            style={{
              animation: 'progress 2.5s ease-in-out forwards',
            }}
          />
        </div>
      </div>

      <style jsx>{`
        @keyframes progress {
          0% {
            width: 0%;
          }
          100% {
            width: 100%;
          }
        }
      `}</style>
    </div>
  );
}
