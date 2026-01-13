'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Logo } from '@/components/ui/logo';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { EstablishmentSelector } from '@/components/selection/EstablishmentSelector';
import { DashboardTypeSelector } from '@/components/selection/DashboardTypeSelector';
import { LoadingModal } from '@/components/selection/LoadingModal';
import {
  establecimientosMock,
  dashboardTypes,
  type DashboardType,
} from '@/lib/establecimientos-mock';
import { ArrowRight } from 'lucide-react';

export default function SelectionPage() {
  const router = useRouter();
  const [selectedEstablecimiento, setSelectedEstablecimiento] = useState<string | null>(null);
  const [selectedType, setSelectedType] = useState<DashboardType | null>('monitoreo-corto');
  const [isLoading, setIsLoading] = useState(false);

  const selectedEst = establecimientosMock.find((e) => e.id === selectedEstablecimiento);
  const canGenerate = selectedEstablecimiento && selectedType;

  const handleGenerate = () => {
    if (!canGenerate) return;

    setIsLoading(true);

    // Simular carga y redirigir
    setTimeout(() => {
      router.push(`/dashboard?est=${selectedEstablecimiento}&tipo=${selectedType}`);
    }, 2500);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <Logo size="lg" showText={false} />
          <div className="text-right">
            <h1 className="text-xl font-bold text-[var(--grass-green-dark)]">
              Sistema de Informes GRASS
            </h1>
            <p className="text-sm text-gray-500">
              Generador de tableros de monitoreo
            </p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-6 py-8">
        <Card className="shadow-lg">
          <CardHeader className="border-b">
            <CardTitle className="text-2xl">Generar nuevo tablero</CardTitle>
            <p className="text-gray-500 mt-1">
              Selecciona el establecimiento y el tipo de informe que deseas generar
            </p>
          </CardHeader>

          <CardContent className="space-y-8 pt-6">
            {/* Selector de establecimiento */}
            <EstablishmentSelector
              establecimientos={establecimientosMock}
              selected={selectedEstablecimiento}
              onSelect={setSelectedEstablecimiento}
            />

            {/* Selector de tipo de tablero */}
            <DashboardTypeSelector
              types={dashboardTypes}
              selected={selectedType}
              onSelect={setSelectedType}
            />

            {/* Botón de generar */}
            <div className="pt-4 border-t">
              <Button
                size="lg"
                className="w-full h-12 text-base bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]"
                disabled={!canGenerate}
                onClick={handleGenerate}
              >
                Generar tablero
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
              {!canGenerate && (
                <p className="text-center text-sm text-gray-500 mt-2">
                  Selecciona un establecimiento para continuar
                </p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Info adicional */}
        <div className="mt-8 text-center text-sm text-gray-500">
          <p>
            Los tableros de <strong>Línea de Base</strong> y{' '}
            <strong>Plan de Pastoreo</strong> estarán disponibles próximamente.
          </p>
        </div>
      </main>

      {/* Loading Modal */}
      <LoadingModal
        isOpen={isLoading}
        establecimientoNombre={selectedEst?.nombre || ''}
      />
    </div>
  );
}
