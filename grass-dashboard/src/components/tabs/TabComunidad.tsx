'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { mockDashboardData, mockComunidadData } from '@/lib/mock-data';
import { useDashboardStore } from '@/lib/dashboard-store';
import dynamic from 'next/dynamic';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  ReferenceLine,
  Cell,
} from 'recharts';

// Importar el mapa dinámicamente
const MapaComunidad = dynamic(() => import('@/components/widgets/MapaComunidad'), {
  ssr: false,
  loading: () => (
    <div className="h-[400px] bg-gray-100 rounded-lg flex items-center justify-center">
      <p className="text-gray-500">Cargando mapa...</p>
    </div>
  ),
});

// Función para calcular color de gradiente basado en valor ISE (0-100)
// Usando la paleta GRASS: estrato-loma (#313b2e) → grass-green (#8aca53) → grass-green-light (#b1ff6d)
const getISEGradientColor = (valor: number): string => {
  const normalized = Math.max(0, Math.min(100, valor)) / 100;

  if (normalized < 0.5) {
    // De estrato-loma (#313b2e) a grass-green (#8aca53)
    const t = normalized * 2;
    const r = Math.round(49 + (138 - 49) * t);
    const g = Math.round(59 + (202 - 59) * t);
    const b = Math.round(46 + (83 - 46) * t);
    return `rgb(${r}, ${g}, ${b})`;
  } else {
    // De grass-green (#8aca53) a grass-green-light (#b1ff6d)
    const t = (normalized - 0.5) * 2;
    const r = Math.round(138 + (177 - 138) * t);
    const g = Math.round(202 + (255 - 202) * t);
    const b = Math.round(83 + (109 - 83) * t);
    return `rgb(${r}, ${g}, ${b})`;
  }
};

export function TabComunidad() {
  const { establecimiento, ise } = mockDashboardData;
  const { establecimientos, estadisticas } = mockComunidadData;
  const { setActiveTab } = useDashboardStore();

  const quickActions = [
    { id: 'inicio', name: 'Inicio' },
    { id: 'plan-monitoreo', name: 'Plan de Monitoreo' },
    { id: 'resultados', name: 'Resultados' },
    { id: 'sobre-grass', name: 'Sobre GRASS' },
  ];

  // Calcular ranking
  const sortedByISE = [...establecimientos].sort((a, b) => b.ise - a.ise);
  const miRanking = sortedByISE.findIndex((e) => e.nombre === establecimiento.nombre) + 1;

  // Datos para comparación
  const comparacionData = [
    { nombre: 'Tu campo', ise: ise.promedio, isCurrent: true },
    { nombre: 'Promedio', ise: estadisticas.isePromedio, isCurrent: false },
    { nombre: 'Mejor', ise: Math.max(...establecimientos.map((e) => e.ise)), isCurrent: false },
    { nombre: 'Peor', ise: Math.min(...establecimientos.map((e) => e.ise)), isCurrent: false },
  ];

  // Datos para ranking
  const rankingData = sortedByISE.map((e) => ({
    nombre: e.nombre,
    ise: e.ise,
    isCurrent: e.nombre === establecimiento.nombre,
  }));

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-[var(--grass-green-dark)]">
          Comunidad GRASS
        </h2>
        <p className="text-gray-600 mt-1">
          Red de establecimientos monitoreando con el protocolo GRASS
        </p>
      </div>

      {/* Estadísticas de la comunidad */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold text-[var(--grass-green-dark)]">
              {estadisticas.totalEstablecimientos}
            </p>
            <p className="text-sm text-gray-500">Establecimientos</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold text-[var(--estrato-media-loma)]">
              {estadisticas.totalHectareas.toLocaleString()}
            </p>
            <p className="text-sm text-gray-500">Hectáreas totales</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold" style={{ color: getISEGradientColor(estadisticas.isePromedio) }}>
              {estadisticas.isePromedio.toFixed(1)}
            </p>
            <p className="text-sm text-gray-500">ISE Promedio Comunidad</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold text-[var(--grass-green)]">
              #{miRanking}
            </p>
            <p className="text-sm text-gray-500">Tu posición en el ranking</p>
          </CardContent>
        </Card>
      </div>

      {/* Mapa y comparación */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Mapa de la comunidad */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-lg text-[var(--grass-green-dark)]">
              Mapa de la Comunidad
            </CardTitle>
          </CardHeader>
          <CardContent>
            <MapaComunidad
              establecimientos={establecimientos}
              currentEstablecimiento={establecimiento.nombre}
            />
            <div className="mt-4 flex flex-col gap-2 text-sm">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full border-2 border-black" style={{ backgroundColor: getISEGradientColor(70) }} />
                <span>Tu establecimiento (borde negro)</span>
              </div>
              <div className="flex items-center gap-2">
                <div
                  className="w-24 h-3 rounded"
                  style={{
                    background: `linear-gradient(to right, ${getISEGradientColor(0)}, ${getISEGradientColor(50)}, ${getISEGradientColor(100)})`
                  }}
                />
                <span className="text-xs text-gray-500">Color = ISE (más claro = mejor)</span>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Comparación con comunidad */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-lg text-[var(--grass-green-dark)]">
              Comparación con la Comunidad
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={comparacionData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="nombre" />
                <YAxis domain={[0, 100]} />
                <Tooltip />
                <ReferenceLine y={70} stroke="#666" strokeDasharray="5 5" label="Deseable" />
                <Bar dataKey="ise" radius={[4, 4, 0, 0]}>
                  {comparacionData.map((entry, index) => (
                    <Cell
                      key={index}
                      fill={getISEGradientColor(entry.ise)}
                      stroke={entry.isCurrent ? '#000' : 'none'}
                      strokeWidth={entry.isCurrent ? 2 : 0}
                    />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
            <div className="mt-4 p-4 bg-gray-50 rounded-lg">
              <p className="text-sm text-gray-700">
                Tu establecimiento (<strong>{establecimiento.nombre}</strong>) tiene un ISE de{' '}
                <strong>{ise.promedio}</strong>, que está{' '}
                {ise.promedio >= estadisticas.isePromedio ? (
                  <span className="text-green-600">
                    {(ise.promedio - estadisticas.isePromedio).toFixed(1)} puntos por encima
                  </span>
                ) : (
                  <span className="text-orange-600">
                    {(estadisticas.isePromedio - ise.promedio).toFixed(1)} puntos por debajo
                  </span>
                )}{' '}
                del promedio de la comunidad.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Ranking de establecimientos */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Ranking de Establecimientos
          </CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={320}>
            <BarChart data={rankingData} layout="vertical" barSize={36} margin={{ top: 5, right: 30, left: 10, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
              <XAxis type="number" domain={[0, 100]} />
              <YAxis
                dataKey="nombre"
                type="category"
                width={110}
                tick={{ fontSize: 12 }}
                tickLine={false}
                axisLine={false}
              />
              <Tooltip />
              <ReferenceLine x={70} stroke="#666" strokeDasharray="5 5" />
              <Bar dataKey="ise" radius={[4, 4, 4, 4]}>
                {rankingData.map((entry, index) => (
                  <Cell
                    key={index}
                    fill={getISEGradientColor(entry.ise)}
                    stroke={entry.isCurrent ? '#000' : 'none'}
                    strokeWidth={entry.isCurrent ? 2 : 0}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      {/* Lista de establecimientos */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Establecimientos de la Comunidad
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {sortedByISE.map((est, index) => (
              <div
                key={est.id}
                className={`p-4 rounded-lg border ${
                  est.nombre === establecimiento.nombre
                    ? 'border-[var(--grass-green)] bg-green-50'
                    : 'border-gray-200'
                }`}
              >
                <div className="flex justify-between items-start">
                  <div>
                    <p className="font-semibold text-sm">{est.nombre}</p>
                    <p className="text-xs text-gray-500">{est.provincia}</p>
                  </div>
                  <span className="text-xs font-bold bg-gray-100 px-2 py-1 rounded">
                    #{index + 1}
                  </span>
                </div>
                <div className="mt-2 flex justify-between text-sm">
                  <span className="text-gray-600">ISE: <strong>{est.ise}</strong></span>
                  <span className="text-gray-500">{est.areaTotal} has</span>
                </div>
                <p className="text-xs text-gray-400 mt-1">
                  {est.anosMonitoreando} años monitoreando
                </p>
              </div>
            ))}
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
