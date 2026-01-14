'use client';

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
import dynamic from 'next/dynamic';

// Importar el mapa dinámicamente para evitar SSR issues con Leaflet
const MapaEstratos = dynamic(() => import('@/components/widgets/MapaEstratos'), {
  ssr: false,
  loading: () => (
    <div className="h-[400px] bg-gray-100 rounded-lg flex items-center justify-center">
      <p className="text-gray-500">Cargando mapa...</p>
    </div>
  ),
});

export function TabPlanMonitoreo() {
  const { establecimiento, estratos, monitores } = mockDashboardData;
  const { setActiveTab } = useDashboardStore();

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

      {/* Mapa y tabla lado a lado */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Mapa de Estratos */}
        <Card className="lg:col-span-1">
          <CardHeader className="pb-2">
            <CardTitle className="text-lg text-[var(--grass-green-dark)]">
              Mapa de Estratos
            </CardTitle>
          </CardHeader>
          <CardContent>
            <MapaEstratos
              center={establecimiento.coordenadas}
              monitores={monitores}
              estratos={estratos}
            />
            {/* Leyenda */}
            <div className="mt-4 flex flex-wrap gap-4">
              {estratos.map((estrato) => (
                <div key={estrato.id} className="flex items-center gap-2">
                  <div
                    className="w-4 h-4 rounded"
                    style={{ backgroundColor: estrato.color }}
                  />
                  <span className="text-sm">{estrato.nombre}</span>
                  <span className="text-xs text-gray-500">({estrato.porcentaje}%)</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Tabla de Estratificación */}
        <Card className="lg:col-span-1">
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
      </div>

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
