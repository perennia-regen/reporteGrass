'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { mockDashboardData, mockComunidadData } from '@/lib/mock-data';
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

export function TabComunidad() {
  const { establecimiento, ise } = mockDashboardData;
  const { establecimientos, estadisticas } = mockComunidadData;

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
            <p className="text-3xl font-bold text-[var(--grass-brown)]">
              {estadisticas.totalHectareas.toLocaleString()}
            </p>
            <p className="text-sm text-gray-500">Hectáreas totales</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold text-[var(--estrato-loma)]">
              {estadisticas.isePromedio.toFixed(1)}
            </p>
            <p className="text-sm text-gray-500">ISE Promedio Comunidad</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6 text-center">
            <p className="text-3xl font-bold text-[var(--grass-orange)]">
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
            <div className="mt-4 flex items-center gap-4 text-sm">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-[var(--grass-green)]" />
                <span>Tu establecimiento</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 rounded-full bg-[var(--grass-brown)]" />
                <span>Otros establecimientos</span>
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
                      fill={entry.isCurrent ? '#4CAF50' : '#8D6E63'}
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
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={rankingData} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis type="number" domain={[0, 100]} />
              <YAxis dataKey="nombre" type="category" width={100} />
              <Tooltip />
              <ReferenceLine x={70} stroke="#666" strokeDasharray="5 5" />
              <Bar dataKey="ise" radius={[0, 4, 4, 0]}>
                {rankingData.map((entry, index) => (
                  <Cell
                    key={index}
                    fill={entry.isCurrent ? '#4CAF50' : '#8D6E63'}
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
    </div>
  );
}
