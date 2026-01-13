'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import type { WidgetConfig } from '@/types/dashboard';
import { ChartByType } from '@/components/layout/ChartPreviewModal';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  ReferenceLine,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
} from 'recharts';

// Mapa de tipos de widget a títulos por defecto
const widgetTitles: Record<string, string> = {
  'ise-estrato-anual': 'ISE del año por estrato',
  'ise-interanual-establecimiento': 'ISE interanual establecimiento',
  'ise-interanual-estrato': 'ISE interanual por estrato',
  'procesos-anual': 'Procesos del año de monitoreo',
  'procesos-interanual': 'Procesos interanual',
  'determinantes-interanual': 'Determinantes interanual',
  'estratos-distribucion': 'Distribución de área por estrato',
  'estratos-comparativa': 'Comparativa por estrato',
};

interface WidgetRendererProps {
  widget: WidgetConfig;
}

export function WidgetRenderer({ widget }: WidgetRendererProps) {
  const { ise, procesos, procesosHistorico, estratos, establecimiento } = mockDashboardData;

  switch (widget.type) {
    case 'bar-chart':
      return <BarChartWidget widget={widget} ise={ise} />;

    case 'line-chart':
      return <LineChartWidget widget={widget} procesosHistorico={procesosHistorico} />;

    case 'pie-chart':
      return <PieChartWidget widget={widget} estratos={estratos} />;

    case 'kpi-card':
      return <KPICardWidget widget={widget} ise={ise} establecimiento={establecimiento} />;

    case 'text-block':
      return <TextBlockWidget widget={widget} />;

    case 'data-table':
      return <DataTableWidget widget={widget} />;

    // Nuevos tipos de gráficos por categoría
    case 'ise-estrato-anual':
    case 'ise-interanual-establecimiento':
    case 'ise-interanual-estrato':
    case 'procesos-anual':
    case 'procesos-interanual':
    case 'determinantes-interanual':
    case 'estratos-distribucion':
    case 'estratos-comparativa':
      return (
        <Card className="h-full">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm">{widget.title || widgetTitles[widget.type]}</CardTitle>
          </CardHeader>
          <CardContent className="h-[calc(100%-60px)]">
            <ChartByType chartType={widget.type} showLabels />
          </CardContent>
        </Card>
      );

    default:
      return (
        <Card className="h-full">
          <CardContent className="flex items-center justify-center h-full">
            <p className="text-gray-400">Widget: {widget.type}</p>
          </CardContent>
        </Card>
      );
  }
}

// Widget de gráfico de barras
function BarChartWidget({ widget, ise }: { widget: WidgetConfig; ise: typeof mockDashboardData.ise }) {
  const data = Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
    nombre,
    ISE: valor,
  }));

  return (
    <Card className="h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm">{widget.title}</CardTitle>
      </CardHeader>
      <CardContent className="h-[calc(100%-60px)]">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical">
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis type="number" domain={[0, 100]} />
            <YAxis dataKey="nombre" type="category" width={70} fontSize={12} />
            <Tooltip />
            <ReferenceLine x={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
            <Bar dataKey="ISE" fill="#8D6E63" radius={[0, 4, 4, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Widget de gráfico de líneas
function LineChartWidget({
  widget,
  procesosHistorico,
}: {
  widget: WidgetConfig;
  procesosHistorico: typeof mockDashboardData.procesosHistorico;
}) {
  const data = procesosHistorico.map((h) => ({
    fecha: h.fecha,
    'Ciclo Agua': h.valores.cicloAgua,
    'Ciclo Mineral': h.valores.cicloMineral,
    'Flujo Energía': h.valores.flujoEnergia,
    'Din. Comunidades': h.valores.dinamicaComunidades,
  }));

  return (
    <Card className="h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm">{widget.title}</CardTitle>
      </CardHeader>
      <CardContent className="h-[calc(100%-60px)]">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="fecha" fontSize={10} />
            <YAxis domain={[0, 100]} fontSize={10} />
            <Tooltip />
            <Line type="monotone" dataKey="Ciclo Agua" stroke="#E65100" strokeWidth={2} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="Ciclo Mineral" stroke="#8D6E63" strokeWidth={2} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="Flujo Energía" stroke="#2E7D32" strokeWidth={2} dot={{ r: 3 }} />
            <Line type="monotone" dataKey="Din. Comunidades" stroke="#FFC107" strokeWidth={2} dot={{ r: 3 }} />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Widget de gráfico circular
function PieChartWidget({
  widget,
  estratos,
}: {
  widget: WidgetConfig;
  estratos: typeof mockDashboardData.estratos;
}) {
  const data = estratos.map((e) => ({
    name: e.nombre,
    value: e.porcentaje,
    color: e.color,
  }));

  return (
    <Card className="h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm">{widget.title}</CardTitle>
      </CardHeader>
      <CardContent className="h-[calc(100%-60px)]">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              outerRadius="70%"
              label={({ name, value }) => `${name}: ${value}%`}
              labelLine={false}
            >
              {data.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Pie>
            <Tooltip />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}

// Widget KPI Card
function KPICardWidget({
  widget,
  ise,
  establecimiento,
}: {
  widget: WidgetConfig;
  ise: typeof mockDashboardData.ise;
  establecimiento: typeof mockDashboardData.establecimiento;
}) {
  const config = widget.config as { metric?: string; label?: string };
  let value: string | number = '-';
  let label = config.label || 'Métrica';

  switch (config.metric) {
    case 'isePromedio':
      value = ise.promedio.toFixed(1);
      label = 'ISE Promedio';
      break;
    case 'areaTotal':
      value = establecimiento.areaTotal;
      label = 'Hectáreas';
      break;
    default:
      value = ise.promedio.toFixed(1);
  }

  return (
    <Card className="h-full">
      <CardContent className="h-full flex flex-col items-center justify-center">
        <p className="text-3xl font-bold text-[var(--grass-green-dark)]">{value}</p>
        <p className="text-sm text-gray-500 mt-1">{label}</p>
      </CardContent>
    </Card>
  );
}

// Widget de bloque de texto
function TextBlockWidget({ widget }: { widget: WidgetConfig }) {
  const config = widget.config as { content?: string };

  return (
    <Card className="h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm">{widget.title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-gray-700">{config.content || 'Contenido del comentario...'}</p>
      </CardContent>
    </Card>
  );
}

// Widget de tabla de datos
function DataTableWidget({ widget }: { widget: WidgetConfig }) {
  const { estratos } = mockDashboardData;

  return (
    <Card className="h-full overflow-auto">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm">{widget.title}</CardTitle>
      </CardHeader>
      <CardContent>
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b">
              <th className="text-left py-2">Estrato</th>
              <th className="text-right py-2">Superficie</th>
              <th className="text-right py-2">%</th>
            </tr>
          </thead>
          <tbody>
            {estratos.map((e) => (
              <tr key={e.id} className="border-b">
                <td className="py-2">{e.nombre}</td>
                <td className="text-right py-2">{e.superficie} has</td>
                <td className="text-right py-2">{e.porcentaje}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </CardContent>
    </Card>
  );
}
