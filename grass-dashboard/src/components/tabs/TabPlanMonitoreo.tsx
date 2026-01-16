'use client';

import { useState, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { mockDashboardData } from '@/lib/mock-data';
import { useDashboardStore } from '@/lib/dashboard-store';
import { DynamicMonitoringMap } from '@/components/maps/DynamicMaps';
import { MonitoringPanel } from '@/components/monitoring/MonitoringPanel';
import { useMapSelection } from '@/components/monitoring/hooks/useMapSelection';
import { Maximize2, Minimize2, X } from 'lucide-react';

export function TabPlanMonitoreo() {
  const { establecimiento, estratos, monitores } = mockDashboardData;
  const { setActiveTab } = useDashboardStore();
  const [isFullscreen, setIsFullscreen] = useState(false);

  // Inicializar selección con todos los estratos y sitios seleccionados
  const selection = useMapSelection({
    initialStratumIds: estratos.map((e) => e.id),
    initialSiteIds: monitores.map((m) => m.id),
  });

  const toggleFullscreen = useCallback(() => {
    setIsFullscreen((prev) => !prev);
  }, []);

  const quickActions = [
    { id: 'inicio', name: 'Inicio' },
    { id: 'resultados', name: 'Resultados' },
    { id: 'sobre-grass', name: 'Sobre GRASS' },
    { id: 'comunidad', name: 'Comunidad' },
  ];

  // Calcular totales
  const totalSuperficie = estratos.reduce((sum, e) => sum + e.superficie, 0);
  const totalEstaciones = estratos.reduce((sum, e) => sum + e.estaciones, 0);

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-[var(--grass-green-dark)]">
          Plan de Monitoreo
        </h2>
        <p className="text-gray-600 mt-1">
          El plan de monitoreo incluyó {totalEstaciones} sitios de MCP para monitoreo de los procesos ecosistémicos.
        </p>
      </div>

      {/* Resumen de área */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="py-6 flex flex-col items-center justify-center">
            <p className="text-2xl font-bold text-[var(--grass-green-dark)]">
              {establecimiento.areaTotal} has
            </p>
            <p className="text-sm text-gray-500">Área Total</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="py-6 flex flex-col items-center justify-center">
            <p className="text-2xl font-bold text-[var(--grass-green)]">
              {totalSuperficie.toFixed(0)} has
            </p>
            <p className="text-sm text-gray-500">Área de Monitoreo</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="py-6 flex flex-col items-center justify-center">
            <p className="text-2xl font-bold text-[var(--grass-green-dark)]">
              {totalEstaciones}
            </p>
            <p className="text-sm text-gray-500">Sitios MCP</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="py-6 flex flex-col items-center justify-center">
            <p className="text-2xl font-bold text-[var(--grass-green)]">
              {estratos.length}
            </p>
            <p className="text-sm text-gray-500">Estratos</p>
          </CardContent>
        </Card>
      </div>

      {/* Panel + Mapa interactivo */}
      <Card>
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg text-[var(--grass-green-dark)]">
              Mapa de Estratos y Sitios de Monitoreo
            </CardTitle>
            <Button
              variant="outline"
              size="sm"
              onClick={toggleFullscreen}
              className="gap-2"
              aria-label="Expandir mapa a pantalla completa"
            >
              <Maximize2 className="h-4 w-4" aria-hidden="true" />
              Pantalla completa
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col lg:flex-row gap-4">
            {/* Panel de selección */}
            <div className="w-full lg:w-72 shrink-0">
              <MonitoringPanel
                estratos={estratos}
                monitores={monitores}
                selection={selection}
              />
            </div>

            {/* Mapa */}
            <div className="flex-1 min-h-[550px]">
              <DynamicMonitoringMap
                center={establecimiento.coordenadas}
                estratos={estratos}
                monitores={monitores}
                selectedStratumIds={selection.selectedStratumIds}
                selectedSiteIds={selection.selectedSiteIds}
                onStratumClick={selection.toggleStratum}
                onSiteClick={selection.toggleSite}
                height={550}
              />
            </div>
          </div>

          {/* Leyenda */}
          <div className="mt-4 pt-4 border-t border-gray-100">
            <div className="flex flex-wrap gap-6 items-start">
              {/* Estratos */}
              <div>
                <p className="text-xs font-medium text-gray-500 mb-2">Estratos</p>
                <div className="flex flex-wrap gap-3">
                  {estratos.map((estrato) => (
                    <div key={estrato.id} className="flex items-center gap-1.5">
                      <div
                        className="w-3 h-3 rounded"
                        style={{ backgroundColor: estrato.color }}
                        aria-hidden="true"
                      />
                      <span className="text-sm">{estrato.nombre}</span>
                      <span className="text-xs text-gray-400">({estrato.porcentaje}%)</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* ISE Color Scale */}
              <div className="ml-6">
                <p className="text-xs font-medium text-gray-500 mb-2">Sitios por ISE</p>
                <div className="flex gap-3">
                  <div className="flex items-center gap-1.5">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#22c55e' }} aria-hidden="true" />
                    <span className="text-xs text-gray-600">≥60</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#eab308' }} aria-hidden="true" />
                    <span className="text-xs text-gray-600">40-59</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#f97316' }} aria-hidden="true" />
                    <span className="text-xs text-gray-600">20-39</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#ef4444' }} aria-hidden="true" />
                    <span className="text-xs text-gray-600">&lt;20</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Fullscreen Map Overlay */}
      {isFullscreen && (
        <div className="fixed inset-0 z-50 bg-white">
          <div className="h-full flex flex-col">
            {/* Fullscreen Header */}
            <div className="flex items-center justify-between p-4 border-b bg-white">
              <h2 className="text-lg font-semibold text-[var(--grass-green-dark)]">
                Mapa de Estratos y Sitios de Monitoreo
              </h2>
              <Button
                variant="outline"
                size="sm"
                onClick={toggleFullscreen}
                className="gap-2"
                aria-label="Cerrar vista de pantalla completa"
              >
                <X className="h-4 w-4" aria-hidden="true" />
                Cerrar
              </Button>
            </div>

            {/* Fullscreen Content */}
            <div className="flex-1 flex">
              {/* Panel */}
              <div className="w-72 border-r bg-white overflow-y-auto">
                <MonitoringPanel
                  estratos={estratos}
                  monitores={monitores}
                  selection={selection}
                />
              </div>

              {/* Map */}
              <div className="flex-1">
                <DynamicMonitoringMap
                  center={establecimiento.coordenadas}
                  estratos={estratos}
                  monitores={monitores}
                  selectedStratumIds={selection.selectedStratumIds}
                  selectedSiteIds={selection.selectedSiteIds}
                  onStratumClick={selection.toggleStratum}
                  onSiteClick={selection.toggleSite}
                  height={window.innerHeight - 73}
                />
              </div>
            </div>

            {/* Fullscreen Legend */}
            <div className="p-3 border-t bg-white flex flex-wrap gap-6 items-center">
              {/* Estratos */}
              <div className="flex items-center gap-1">
                <span className="text-xs font-medium text-gray-500 mr-2">Estratos:</span>
                {estratos.map((estrato) => (
                  <div key={estrato.id} className="flex items-center gap-1.5 mr-3">
                    <div
                      className="w-3 h-3 rounded"
                      style={{ backgroundColor: estrato.color }}
                      aria-hidden="true"
                    />
                    <span className="text-sm">{estrato.nombre}</span>
                  </div>
                ))}
              </div>

              {/* ISE */}
              <div className="flex items-center gap-1">
                <span className="text-xs font-medium text-gray-500 mr-2">ISE:</span>
                <div className="flex items-center gap-1.5 mr-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#22c55e' }} aria-hidden="true" />
                  <span className="text-xs">≥60</span>
                </div>
                <div className="flex items-center gap-1.5 mr-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#eab308' }} aria-hidden="true" />
                  <span className="text-xs">40-59</span>
                </div>
                <div className="flex items-center gap-1.5 mr-2">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#f97316' }} aria-hidden="true" />
                  <span className="text-xs">20-39</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#ef4444' }} aria-hidden="true" />
                  <span className="text-xs">&lt;20</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tabla de Estratificación */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Estratificación por Ambientes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Estrato</TableHead>
                <TableHead className="text-right">Superficie</TableHead>
                <TableHead className="text-right">% del Est.</TableHead>
                <TableHead className="text-right">N° Estaciones</TableHead>
                <TableHead className="text-right">Área/Estación</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {estratos.map((estrato) => (
                <TableRow key={estrato.id}>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div
                        className="w-3 h-3 rounded"
                        style={{ backgroundColor: estrato.color }}
                        aria-hidden="true"
                      />
                      {estrato.nombre}
                    </div>
                  </TableCell>
                  <TableCell className="text-right">{estrato.superficie} has</TableCell>
                  <TableCell className="text-right">{estrato.porcentaje}%</TableCell>
                  <TableCell className="text-right">{estrato.estaciones}</TableCell>
                  <TableCell className="text-right">{estrato.areaPorEstacion} has</TableCell>
                </TableRow>
              ))}
              {/* Fila de totales */}
              <TableRow className="font-semibold bg-gray-50">
                <TableCell>Total</TableCell>
                <TableCell className="text-right">{totalSuperficie} has</TableCell>
                <TableCell className="text-right">100%</TableCell>
                <TableCell className="text-right">{totalEstaciones}</TableCell>
                <TableCell className="text-right">-</TableCell>
              </TableRow>
            </TableBody>
          </Table>

          {/* Gráfico de distribución simple */}
          <div className="mt-6">
            <p className="text-sm font-medium text-gray-700 mb-2">Distribución de Área</p>
            <div className="flex h-8 rounded-lg overflow-hidden">
              {estratos.map((estrato) => (
                <div
                  key={estrato.id}
                  className="flex items-center justify-center text-white text-xs font-medium"
                  style={{
                    backgroundColor: estrato.color,
                    width: `${estrato.porcentaje}%`,
                  }}
                >
                  {estrato.porcentaje}%
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Información adicional */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Ubicación del Establecimiento
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <p className="text-xs text-gray-500">Provincia</p>
              <p className="font-medium">{establecimiento.ubicacion.provincia}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Departamento</p>
              <p className="font-medium">{establecimiento.ubicacion.departamento}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Distrito</p>
              <p className="font-medium">{establecimiento.ubicacion.distrito}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Footer */}
      <div className="mt-8 pt-6 pb-8 border-t border-gray-200">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
          {quickActions.map((action) => (
            <Button
              key={action.id}
              variant="outline"
              size="sm"
              className="text-gray-600 hover:text-gray-900 hover:bg-gray-50 border-gray-200 w-full"
              onClick={() => setActiveTab(action.id)}
            >
              {action.name}
            </Button>
          ))}
        </div>
        <p className="text-center text-xs text-gray-400">
          Grassland Regeneration and Sustainable Standard - 2025
        </p>
      </div>
    </div>
  );
}
