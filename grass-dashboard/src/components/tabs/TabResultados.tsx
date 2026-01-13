'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import { useDashboardStore } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine,
  LineChart,
  Line,
} from 'recharts';

export function TabResultados() {
  const { ise, procesos, procesosHistorico, recomendaciones, estratos } = mockDashboardData;
  const { editableContent, updateContent } = useDashboardStore();

  // Preparar datos para gráfico ISE por estrato
  const iseEstratoData = Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
    nombre,
    ISE: valor,
    fill: valor >= ISE_THRESHOLD ? '#4CAF50' : '#8D6E63',
  }));

  // Preparar datos para evolución ISE
  const iseEvolucionData = ise.historico.map((h) => ({
    fecha: h.fecha,
    ISE: h.valor,
  }));

  // Preparar datos para evolución ISE por estrato
  const iseEstratoEvolucionData = ise.historico.map((h) => ({
    fecha: h.fecha,
    ...h.porEstrato,
  }));

  // Preparar datos para procesos ecosistémicos
  const procesosData = [
    { proceso: 'Ciclo del Agua', valor: procesos.cicloAgua, fill: '#E65100' },
    { proceso: 'Ciclo Mineral', valor: procesos.cicloMineral, fill: '#8D6E63' },
    { proceso: 'Flujo de Energía', valor: procesos.flujoEnergia, fill: '#2E7D32' },
    { proceso: 'Din. Comunidades', valor: procesos.dinamicaComunidades, fill: '#FFC107' },
  ];

  // Preparar datos para evolución de procesos
  const procesosEvolucionData = procesosHistorico.map((h) => ({
    fecha: h.fecha,
    'Ciclo Agua': h.valores.cicloAgua,
    'Ciclo Mineral': h.valores.cicloMineral,
    'Flujo Energía': h.valores.flujoEnergia,
    'Din. Comunidades': h.valores.dinamicaComunidades,
  }));

  return (
    <div className="space-y-8 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-black">
          Resultados del Monitoreo
        </h2>
        <p className="text-gray-600 mt-1">
          Índice de Salud Ecosistémica (ISE) y Procesos del Ecosistema
        </p>
      </div>

      {/* SECCIÓN ISE */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Índice de Salud Ecosistémica (ISE)
        </h3>

        {/* ISE por Estrato */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">ISE por Estrato - Marzo 2025</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={iseEstratoData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 100]} />
                  <YAxis dataKey="nombre" type="category" width={80} />
                  <Tooltip />
                  <ReferenceLine x={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" label={{ value: 'Deseable', position: 'top' }} />
                  <ReferenceLine x={ise.promedio} stroke="#E65100" strokeDasharray="3 3" label={{ value: `Prom: ${ise.promedio}`, position: 'bottom' }} />
                  <Bar dataKey="ISE" fill="#8D6E63" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
              <p className="text-xs text-gray-500 mt-2">
                El valor promedio del ISE fue de <strong>{ise.promedio}</strong>, por debajo del umbral deseable de {ISE_THRESHOLD} puntos.
              </p>
            </CardContent>
          </Card>

          {/* Evolución ISE Total */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Evolución ISE - Total Establecimiento</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={iseEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[0, 100]} />
                  <Tooltip />
                  <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" label="Deseable" />
                  <Bar dataKey="ISE" fill="#8D6E63" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
              <p className="text-xs text-gray-500 mt-2">
                Se observa una marcada disminución inicial por sequía severa (2023), con recuperación parcial posterior.
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Evolución ISE por Estrato */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Evolución ISE por Estrato</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={iseEstratoEvolucionData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="fecha" />
                <YAxis domain={[-30, 100]} />
                <Tooltip />
                <Legend />
                <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
                <Bar dataKey="Bajo" fill="#EF9A9A" />
                <Bar dataKey="Media Loma" fill="#42A5F5" />
                <Bar dataKey="Loma" fill="#1565C0" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </section>

      {/* SECCIÓN PROCESOS ECOSISTÉMICOS */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Procesos del Ecosistema
        </h3>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          {/* Procesos Actual */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Procesos - Total Establecimiento (Marzo 2025)</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={procesosData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 100]} unit="%" />
                  <YAxis dataKey="proceso" type="category" width={110} />
                  <Tooltip formatter={(value) => `${value}%`} />
                  <Bar dataKey="valor" radius={[0, 4, 4, 0]}>
                    {procesosData.map((entry, index) => (
                      <Bar key={index} dataKey="valor" fill={entry.fill} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
              <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: '#E65100' }} />
                  <span>Ciclo del Agua: {procesos.cicloAgua}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: '#8D6E63' }} />
                  <span>Ciclo Mineral: {procesos.cicloMineral}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: '#2E7D32' }} />
                  <span>Flujo de Energía: {procesos.flujoEnergia}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: '#FFC107' }} />
                  <span>Din. Comunidades: {procesos.dinamicaComunidades}%</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Evolución Procesos */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Evolución de Procesos</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={procesosEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[0, 100]} unit="%" />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="Ciclo Agua" stroke="#E65100" strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Ciclo Mineral" stroke="#8D6E63" strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Flujo Energía" stroke="#2E7D32" strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Din. Comunidades" stroke="#FFC107" strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* SECCIÓN SÍNTESIS Y RECOMENDACIONES */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Síntesis y Recomendaciones
        </h3>

        <Card>
          <CardContent className="pt-6">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[120px]">Estrato</TableHead>
                  <TableHead>Sugerencias de Manejo</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {recomendaciones.map((rec) => {
                  const estrato = estratos.find((e) => e.nombre === rec.estrato);
                  return (
                    <TableRow key={rec.estrato}>
                      <TableCell className="font-medium">
                        <div className="flex items-center gap-2">
                          <div
                            className="w-3 h-3 rounded"
                            style={{ backgroundColor: estrato?.color || '#757575' }}
                          />
                          {rec.estrato}
                        </div>
                      </TableCell>
                      <TableCell className="text-sm text-gray-700">
                        {rec.sugerencia}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* Comentario Final */}
        <Card className="mt-6">
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Comentario Final del Técnico</CardTitle>
          </CardHeader>
          <CardContent>
            <EditableText
              value={editableContent.comentarioFinal}
              onChange={(value) => updateContent('comentarioFinal', value)}
              placeholder="Ingrese un comentario final sobre los resultados..."
              className="text-gray-700 leading-relaxed"
              multiline
            />
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
