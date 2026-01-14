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
import { indicadoresBiologicos } from '@/lib/mock-data';
import { useDashboardStore } from '@/lib/dashboard-store';

export function TabSobreGrass() {
  const { setActiveTab } = useDashboardStore();

  const quickActions = [
    { id: 'inicio', name: 'Inicio' },
    { id: 'plan-monitoreo', name: 'Plan de Monitoreo' },
    { id: 'resultados', name: 'Resultados' },
    { id: 'comunidad', name: 'Comunidad' },
  ];

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-[var(--grass-green-dark)]">
          Sobre GRASS
        </h2>
        <p className="text-gray-600 mt-1">
          Grassland Regeneration and Sustainable Standard por Ovis 21
        </p>
      </div>

      {/* Introducción */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl text-[var(--grass-green-dark)]">
            Introducción al GRASS
          </CardTitle>
        </CardHeader>
        <CardContent className="prose prose-sm max-w-none">
          <p className="text-gray-700 leading-relaxed">
            El <strong>protocolo de monitoreo ambiental GRASS</strong> es una herramienta diseñada para
            realizar el seguimiento ecosistémico en establecimientos agropecuarios. Permite
            diagnosticar el funcionamiento de los procesos ecológicos y cuantificar el grado
            de regeneración de las tierras.
          </p>
        </CardContent>
      </Card>

      {/* Los 3 procedimientos */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl text-[var(--grass-green-dark)]">
            El GRASS se aplica con tres procedimientos
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex gap-4 p-4 bg-gray-50 rounded-lg">
              <div className="w-8 h-8 rounded-full bg-[var(--grass-green)] text-white flex items-center justify-center font-bold shrink-0">
                1
              </div>
              <div>
                <h4 className="font-semibold">Estratificación del campo y diseño de un plan de muestreo</h4>
                <p className="text-sm text-gray-600 mt-1">
                  Se identifican los diferentes ambientes (estratos) del establecimiento y se
                  determina la ubicación de los sitios de monitoreo.
                </p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-gray-50 rounded-lg">
              <div className="w-8 h-8 rounded-full bg-[var(--grass-green)] text-white flex items-center justify-center font-bold shrink-0">
                2
              </div>
              <div>
                <h4 className="font-semibold">Monitoreo de Corto Plazo (MCP)</h4>
                <p className="text-sm text-gray-600 mt-1">
                  Realizado anualmente, mediante indicadores biológicos que se integran en un
                  <strong> Índice de Salud Ecológica (ISE)</strong>.
                </p>
              </div>
            </div>

            <div className="flex gap-4 p-4 bg-gray-50 rounded-lg">
              <div className="w-8 h-8 rounded-full bg-[var(--grass-green)] text-white flex items-center justify-center font-bold shrink-0">
                3
              </div>
              <div>
                <h4 className="font-semibold">Monitoreo de Largo Plazo (MLP)</h4>
                <p className="text-sm text-gray-600 mt-1">
                  Consiste en la evaluación de tres servicios ambientales de importancia global:
                  la biodiversidad de la vegetación, la tasa de infiltración de agua y el
                  stock de carbono en los suelos.
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Explicación del ISE */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl text-[var(--grass-green-dark)]">
            Índice de Salud Ecosistémica (ISE)
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-gray-700">
            La salud del ecosistema depende del óptimo funcionamiento de los procesos
            ecosistémicos como el ciclo del agua, el ciclo de los minerales, el flujo de energía y
            la dinámica de las comunidades.
          </p>

          <p className="text-gray-700">
            El ISE es un método expeditivo y económico para evaluar la situación de dichos
            procesos ecosistémicos, comparando <strong>16 indicadores biológicos</strong> con el potencial
            de la Ecorregión.
          </p>

          <div className="bg-green-50 border-l-4 border-[var(--grass-green)] p-4 rounded-r">
            <p className="text-sm text-green-800">
              <strong>Si el ISE aumenta a lo largo del tiempo</strong>, puede considerarse que el manejo es adecuado.
            </p>
          </div>

          <div className="bg-orange-50 border-l-4 border-orange-500 p-4 rounded-r">
            <p className="text-sm text-orange-800">
              <strong>Si el ISE no aumenta o disminuye</strong>, es una señal de alerta que sugiere la
              necesidad de revisar y ajustar las prácticas de manejo.
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Tabla de Indicadores Biológicos */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl text-[var(--grass-green-dark)]">
            Procesos Ecosistémicos e Indicadores
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Table className="table-fixed w-full">
            <TableHeader>
              <TableRow className="bg-gray-900">
                <TableHead className="text-white font-semibold w-[18%] whitespace-normal">Proceso Ecosistémico</TableHead>
                <TableHead className="text-white font-semibold w-[40%] whitespace-normal">Criterio de Calidad</TableHead>
                <TableHead className="text-white font-semibold w-[42%] whitespace-normal">Indicadores</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {indicadoresBiologicos.map((item, index) => (
                <TableRow key={index} className={index % 2 === 0 ? 'bg-gray-50' : ''}>
                  <TableCell className="font-semibold text-[var(--grass-green-dark)] align-top whitespace-normal break-words">
                    {item.proceso}
                  </TableCell>
                  <TableCell className="text-sm text-gray-600 align-top whitespace-normal break-words">
                    {item.criterio}
                  </TableCell>
                  <TableCell className="align-top whitespace-normal break-words">
                    <ul className="text-sm space-y-1">
                      {item.indicadores.map((ind, i) => (
                        <li key={i} className="text-gray-700">• {ind}</li>
                      ))}
                    </ul>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Nota sobre la evaluación */}
      <Card>
        <CardHeader>
          <CardTitle className="text-xl text-[var(--grass-green-dark)]">
            Metodología de Evaluación
          </CardTitle>
        </CardHeader>
        <CardContent className="prose prose-sm max-w-none">
          <p className="text-gray-700">
            Cada indicador recibe una puntuación según el grado de alejamiento del potencial
            de la ecorregión, utilizando una <strong>matriz de Evaluación</strong> específica para cada región.
          </p>
          <p className="text-gray-700">
            Los valores se suman para obtener una puntuación total en cada lugar de
            muestreo. Estas variables cuantificadas se miden en el campo y luego se procesan
            para obtener un valor por estrato y una media ponderada para el predio.
          </p>
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
