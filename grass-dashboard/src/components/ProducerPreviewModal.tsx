'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Logo } from '@/components/ui/logo';
import { mockDashboardData } from '@/lib/mock-data';
import { useDashboardStore } from '@/lib/dashboard-store';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import { X, Smartphone, Monitor } from 'lucide-react';

interface ProducerPreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
}

type DeviceSize = 'mobile' | 'desktop';

const deviceSizes: Record<DeviceSize, { width: number; height: number; label: string }> = {
  mobile: { width: 402, height: 874, label: 'iPhone 17' },
  desktop: { width: 1024, height: 768, label: 'Desktop' },
};

export function ProducerPreviewModal({ isOpen, onClose }: ProducerPreviewModalProps) {
  const [device, setDevice] = useState<DeviceSize>('desktop');
  const { establecimiento, ise, estratos, procesos } = mockDashboardData;
  const { editableContent } = useDashboardStore();

  if (!isOpen) return null;

  const currentDevice = deviceSizes[device];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Overlay */}
      <div className="absolute inset-0 bg-black/50" onClick={onClose} />

      {/* Modal */}
      <div className="relative bg-gray-800 rounded-lg shadow-xl w-[95vw] h-[90vh] max-w-6xl flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-700">
          <div>
            <h2 className="text-lg font-semibold text-white">
              Vista del Productor
            </h2>
            <p className="text-sm text-gray-400">
              Previsualiza como vera el productor el informe en su dispositivo
            </p>
          </div>
          <div className="flex items-center gap-4">
            {/* Device selector */}
            <div className="flex items-center gap-1 bg-gray-700 rounded-lg p-1">
              <button
                onClick={() => setDevice('desktop')}
                className={`p-2 rounded ${device === 'desktop' ? 'bg-[var(--grass-green)] text-white' : 'text-gray-400 hover:text-white'}`}
                title="Desktop"
              >
                <Monitor className="w-5 h-5" />
              </button>
              <button
                onClick={() => setDevice('mobile')}
                className={`p-2 rounded ${device === 'mobile' ? 'bg-[var(--grass-green)] text-white' : 'text-gray-400 hover:text-white'}`}
                title="iPhone 17"
              >
                <Smartphone className="w-5 h-5" />
              </button>
            </div>
            <span className="text-sm text-gray-400">{currentDevice.label}</span>
            <Button variant="outline" size="sm" onClick={onClose} className="text-gray-300 border-gray-600 hover:bg-gray-700">
              <X className="w-4 h-4" />
            </Button>
          </div>
        </div>

        {/* Content - Device Frame */}
        <div className="flex-1 flex items-center justify-center p-6 overflow-hidden">
          <div
            className={`bg-white shadow-2xl overflow-hidden transition-all duration-300 flex flex-col ${device === 'mobile' ? 'rounded-[2.5rem]' : 'rounded-lg'}`}
            style={{
              width: `${currentDevice.width}px`,
              height: `${currentDevice.height}px`,
              maxWidth: '100%',
              maxHeight: '100%',
            }}
          >
            {/* Device notch (for mobile) */}
            {device === 'mobile' && (
              <div className="h-8 bg-black flex items-center justify-center">
                <div className="w-28 h-6 bg-black rounded-b-2xl" />
              </div>
            )}

            {/* Preview Content */}
            <div className="flex-1 overflow-auto bg-gray-50">
              <ProducerView
                establecimiento={establecimiento}
                ise={ise}
                estratos={estratos}
                procesos={procesos}
                observacionGeneral={editableContent.observacionGeneral}
                device={device}
              />
            </div>

            {/* Home indicator (for mobile) */}
            {device === 'mobile' && (
              <div className="h-6 bg-white flex items-center justify-center">
                <div className="w-32 h-1 bg-gray-300 rounded-full" />
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// Componente interno para la vista del productor
interface ProducerViewProps {
  establecimiento: typeof mockDashboardData.establecimiento;
  ise: typeof mockDashboardData.ise;
  estratos: typeof mockDashboardData.estratos;
  procesos: typeof mockDashboardData.procesos;
  observacionGeneral: string;
  device: DeviceSize;
}

function ProducerView({
  establecimiento,
  ise,
  estratos,
  procesos,
  observacionGeneral,
  device,
}: ProducerViewProps) {
  const isMobile = device === 'mobile';

  return (
    <div className="min-h-full">
      {/* Header compacto con identificacion del predio */}
      <header className="bg-[var(--grass-green-dark)] text-white px-3 py-2">
        <div className="flex items-center gap-3">
          <Logo
            size="sm"
            showText={false}
            logoSrc="/logo-grass.png"
            className="shrink-0"
          />
          <div className="min-w-0 flex-1">
            <h1 className={`font-bold text-white truncate ${isMobile ? 'text-sm' : 'text-base'}`}>
              {establecimiento.nombre}
            </h1>
            <p className="text-xs text-white/80">
              {establecimiento.fecha} | {establecimiento.codigo}
            </p>
          </div>
          {!isMobile && (
            <>
              <div className="h-8 w-px bg-white/30" />
              <div className="flex items-center gap-3 text-xs text-white/90">
                <span>{establecimiento.nodo}</span>
                <span className="text-white/50">|</span>
                <span>{establecimiento.tecnico}</span>
                <span className="text-white/50">|</span>
                <span>{establecimiento.areaTotal} has</span>
              </div>
            </>
          )}
          {isMobile && (
            <div className="text-xs text-white/80 text-right">
              <span>{establecimiento.nodo}</span>
              <span className="mx-1">-</span>
              <span>{establecimiento.areaTotal} has</span>
            </div>
          )}
        </div>
      </header>

      {/* Contenido principal */}
      <div className={`${isMobile ? 'p-3 space-y-4' : 'p-4 space-y-5'}`}>
        {/* Datos Destacados */}
        <section>
          <h3 className={`font-semibold text-[var(--grass-green-dark)] mb-3 ${isMobile ? 'text-sm' : 'text-base'}`}>
            Datos Destacados
          </h3>
          <div className={`grid ${isMobile ? 'grid-cols-2 gap-2' : 'grid-cols-4 gap-3'}`}>
            <KPICard
              value={ise.promedio.toFixed(1)}
              label="ISE Promedio"
              color="var(--grass-green-dark)"
              sublabel={ise.promedio >= ISE_THRESHOLD ? 'Deseable' : `${(ISE_THRESHOLD - ise.promedio).toFixed(1)} pts bajo umbral`}
              isDesirable={ise.promedio >= ISE_THRESHOLD}
              isMobile={isMobile}
            />
            <KPICard
              value={String(establecimiento.areaTotal)}
              label="Hectareas"
              color="var(--grass-brown)"
              isMobile={isMobile}
            />
            <KPICard
              value={estratos.reduce((sum, e) => sum + e.estaciones, 0).toString()}
              label="Sitios MCP"
              color="var(--estrato-loma)"
              isMobile={isMobile}
            />
            <KPICard
              value={estratos.length.toString()}
              label="Estratos"
              color="var(--grass-orange)"
              isMobile={isMobile}
            />
          </div>
        </section>

        {/* ISE por Estrato */}
        <section className="bg-white rounded-lg shadow-sm p-3">
          <h3 className={`font-semibold text-[var(--grass-green-dark)] mb-3 ${isMobile ? 'text-sm' : 'text-base'}`}>
            ISE por Estrato
          </h3>
          <div className="space-y-2">
            {Object.entries(ise.porEstrato).map(([estrato, valor]) => (
              <div key={estrato}>
                <div className="flex justify-between items-center mb-1">
                  <span className={`font-medium ${isMobile ? 'text-xs' : 'text-sm'}`}>{estrato}</span>
                  <span className={`font-bold ${isMobile ? 'text-xs' : 'text-sm'}`}>{valor.toFixed(1)}</span>
                </div>
                <div className="h-4 bg-gray-200 rounded-full overflow-hidden relative">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{
                      width: `${Math.max(valor, 0)}%`,
                      backgroundColor: valor >= ISE_THRESHOLD ? 'var(--grass-green)' : 'var(--grass-brown)',
                    }}
                  />
                  <div
                    className="absolute top-0 bottom-0 w-0.5 bg-gray-500"
                    style={{ left: `${ISE_THRESHOLD}%` }}
                  />
                </div>
              </div>
            ))}
            <p className={`text-gray-500 mt-2 ${isMobile ? 'text-xs' : 'text-sm'}`}>
              Linea vertical = umbral deseable ({ISE_THRESHOLD} pts)
            </p>
          </div>
        </section>

        {/* Procesos Ecosistemicos */}
        <section className="bg-white rounded-lg shadow-sm p-3">
          <h3 className={`font-semibold text-[var(--grass-green-dark)] mb-3 ${isMobile ? 'text-sm' : 'text-base'}`}>
            Procesos Ecosistemicos
          </h3>
          <div className="space-y-2">
            {[
              { key: 'cicloAgua', label: 'Ciclo del Agua', color: '#3B82F6' },
              { key: 'cicloMineral', label: 'Ciclo Mineral', color: '#8B5CF6' },
              { key: 'flujoEnergia', label: 'Flujo de Energia', color: '#F59E0B' },
              { key: 'dinamicaComunidades', label: 'Dinamica Comunidades', color: '#10B981' },
            ].map(({ key, label, color }) => (
              <div key={key}>
                <div className="flex justify-between items-center mb-1">
                  <span className={`${isMobile ? 'text-xs' : 'text-sm'}`}>{label}</span>
                  <span className={`font-bold ${isMobile ? 'text-xs' : 'text-sm'}`}>
                    {procesos[key as keyof typeof procesos]}%
                  </span>
                </div>
                <div className="h-3 bg-gray-200 rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full"
                    style={{
                      width: `${procesos[key as keyof typeof procesos]}%`,
                      backgroundColor: color,
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </section>

        {/* Observacion General */}
        <section className="bg-white rounded-lg shadow-sm p-3">
          <h3 className={`font-semibold text-[var(--grass-green-dark)] mb-2 ${isMobile ? 'text-sm' : 'text-base'}`}>
            Observacion General
          </h3>
          <p className={`text-gray-700 leading-relaxed ${isMobile ? 'text-xs' : 'text-sm'}`}>
            {observacionGeneral || 'Sin observaciones registradas.'}
          </p>
        </section>
      </div>

      {/* Footer */}
      <footer className={`border-t bg-white text-center text-gray-500 ${isMobile ? 'p-3 text-xs' : 'p-4 text-sm'}`}>
        <p>Protocolo GRASS - Monitoreo de Pastizales</p>
        <p className="text-gray-400 mt-1">Generado con GRASS Dashboard</p>
      </footer>
    </div>
  );
}

// Componente KPI Card
interface KPICardProps {
  value: string;
  label: string;
  color: string;
  sublabel?: string;
  isDesirable?: boolean;
  isMobile: boolean;
}

function KPICard({ value, label, color, sublabel, isDesirable, isMobile }: KPICardProps) {
  return (
    <div className={`bg-white rounded-lg shadow-sm text-center ${isMobile ? 'p-2' : 'p-3'}`}>
      <p
        className={`font-bold ${isMobile ? 'text-xl' : 'text-2xl'}`}
        style={{ color }}
      >
        {value}
      </p>
      <p className={`text-gray-500 ${isMobile ? 'text-xs' : 'text-sm'}`}>{label}</p>
      {sublabel && (
        <p className={`mt-1 text-xs ${isDesirable ? 'text-green-600' : 'text-orange-500'}`}>
          {sublabel}
        </p>
      )}
    </div>
  );
}
