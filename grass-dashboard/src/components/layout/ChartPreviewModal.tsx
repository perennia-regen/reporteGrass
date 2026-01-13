'use client';

import { X } from 'lucide-react';
import { mockDashboardData } from '@/lib/mock-data';
import { grassTheme, ISE_THRESHOLD } from '@/styles/grass-theme';
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
  Legend,
} from 'recharts';

interface ChartPreviewModalProps {
  isOpen: boolean;
  onClose: () => void;
  chartType: string;
  title: string;
}

export function ChartPreviewModal({ isOpen, onClose, chartType, title }: ChartPreviewModalProps) {
  if (!isOpen) return null;

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={handleBackdropClick}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />

      {/* Modal */}
      <div className="relative bg-white rounded-2xl shadow-2xl p-6 max-w-3xl w-full mx-4">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5 text-gray-500" />
          </button>
        </div>

        {/* Chart */}
        <div className="h-[400px]">
          <ChartByType chartType={chartType} showLabels />
        </div>
      </div>
    </div>
  );
}

// Componente que renderiza el gráfico según su tipo
interface ChartByTypeProps {
  chartType: string;
  showLabels?: boolean;
  compact?: boolean;
}

export function ChartByType({ chartType, showLabels = true, compact = false }: ChartByTypeProps) {
  const { ise, procesos, procesosHistorico, estratos } = mockDashboardData;

  const fontSize = compact ? 8 : 12;
  const tickFontSize = compact ? 7 : 10;

  switch (chartType) {
    case 'ise-estrato-anual': {
      const data = Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
        nombre,
        ISE: valor,
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical" margin={compact ? { left: 0, right: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis type="number" domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis
              dataKey="nombre"
              type="category"
              width={compact ? 50 : 70}
              tick={{ fontSize: tickFontSize }}
            />
            {showLabels && <Tooltip />}
            <ReferenceLine x={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
            <Bar dataKey="ISE" fill={grassTheme.colors.estratos.mediaLoma} radius={[0, 4, 4, 0]} />
          </BarChart>
        </ResponsiveContainer>
      );
    }

    case 'ise-interanual-establecimiento': {
      const data = ise.historico.map((h) => ({
        fecha: h.fecha,
        ISE: h.valor,
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={compact ? { left: 0, right: 5, top: 5, bottom: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis dataKey="fecha" tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            {showLabels && <Tooltip />}
            <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
            <Line
              type="monotone"
              dataKey="ISE"
              stroke={grassTheme.colors.primary.green}
              strokeWidth={2}
              dot={{ r: compact ? 2 : 4 }}
            />
          </LineChart>
        </ResponsiveContainer>
      );
    }

    case 'ise-interanual-estrato': {
      const data = ise.historico.map((h) => ({
        fecha: h.fecha,
        Bajo: h.porEstrato?.['Bajo'] ?? 0,
        'Media Loma': h.porEstrato?.['Media Loma'] ?? 0,
        Loma: h.porEstrato?.['Loma'] ?? 0,
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={compact ? { left: 0, right: 5, top: 5, bottom: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis dataKey="fecha" tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis domain={[-20, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            {showLabels && <Tooltip />}
            {showLabels && <Legend />}
            <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
            <Line type="monotone" dataKey="Bajo" stroke={grassTheme.colors.estratos.bajo} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Media Loma" stroke={grassTheme.colors.estratos.mediaLoma} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Loma" stroke={grassTheme.colors.estratos.loma} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
          </LineChart>
        </ResponsiveContainer>
      );
    }

    case 'procesos-anual': {
      const data = [
        { nombre: 'Ciclo Agua', valor: procesos.cicloAgua, color: grassTheme.colors.procesos.cicloAgua },
        { nombre: 'Ciclo Mineral', valor: procesos.cicloMineral, color: grassTheme.colors.procesos.cicloMineral },
        { nombre: 'Flujo Energía', valor: procesos.flujoEnergia, color: grassTheme.colors.procesos.flujoEnergia },
        { nombre: 'Din. Comunidades', valor: procesos.dinamicaComunidades, color: grassTheme.colors.procesos.dinamicaComunidades },
      ];
      return (
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} layout="vertical" margin={compact ? { left: 0, right: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis type="number" domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis
              dataKey="nombre"
              type="category"
              width={compact ? 60 : 100}
              tick={{ fontSize: tickFontSize }}
            />
            {showLabels && <Tooltip />}
            <Bar dataKey="valor" radius={[0, 4, 4, 0]}>
              {data.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      );
    }

    case 'procesos-interanual': {
      const data = procesosHistorico.map((h) => ({
        fecha: h.fecha,
        'Ciclo Agua': h.valores.cicloAgua,
        'Ciclo Mineral': h.valores.cicloMineral,
        'Flujo Energía': h.valores.flujoEnergia,
        'Din. Comunidades': h.valores.dinamicaComunidades,
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={compact ? { left: 0, right: 5, top: 5, bottom: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis dataKey="fecha" tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            {showLabels && <Tooltip />}
            {showLabels && <Legend />}
            <Line type="monotone" dataKey="Ciclo Agua" stroke={grassTheme.colors.procesos.cicloAgua} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Ciclo Mineral" stroke={grassTheme.colors.procesos.cicloMineral} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Flujo Energía" stroke={grassTheme.colors.procesos.flujoEnergia} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Din. Comunidades" stroke={grassTheme.colors.procesos.dinamicaComunidades} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
          </LineChart>
        </ResponsiveContainer>
      );
    }

    case 'determinantes-interanual': {
      // Los determinantes son los indicadores que afectan los procesos
      // Usamos los procesos históricos como proxy para mostrar la evolución
      const data = procesosHistorico.map((h) => ({
        fecha: h.fecha,
        'Cobertura': Math.round((h.valores.cicloAgua + h.valores.flujoEnergia) / 2),
        'Mantillo': Math.round(h.valores.cicloMineral),
        'Diversidad': Math.round(h.valores.dinamicaComunidades),
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={compact ? { left: 0, right: 5, top: 5, bottom: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis dataKey="fecha" tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            {showLabels && <Tooltip />}
            {showLabels && <Legend />}
            <Line type="monotone" dataKey="Cobertura" stroke={grassTheme.colors.primary.green} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Mantillo" stroke={grassTheme.colors.procesos.cicloMineral} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
            <Line type="monotone" dataKey="Diversidad" stroke={grassTheme.colors.procesos.dinamicaComunidades} strokeWidth={2} dot={{ r: compact ? 2 : 3 }} />
          </LineChart>
        </ResponsiveContainer>
      );
    }

    case 'estratos-distribucion': {
      const data = estratos.map((e) => ({
        name: e.nombre,
        value: e.porcentaje,
        color: e.color,
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              nameKey="name"
              cx="50%"
              cy="50%"
              outerRadius={compact ? '65%' : '70%'}
              label={compact ? false : ({ name, value }) => `${name}: ${value}%`}
              labelLine={!compact}
            >
              {data.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Pie>
            {showLabels && <Tooltip />}
            {showLabels && <Legend />}
          </PieChart>
        </ResponsiveContainer>
      );
    }

    case 'estratos-comparativa': {
      // Comparar ISE por estrato
      const data = Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
        nombre,
        ISE: valor,
        color: estratos.find((e) => e.nombre === nombre)?.color || '#888',
      }));
      return (
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={compact ? { left: 0, right: 5, bottom: 5 } : undefined}>
            {showLabels && <CartesianGrid strokeDasharray="3 3" />}
            <XAxis dataKey="nombre" tick={{ fontSize: tickFontSize }} hide={compact} />
            <YAxis domain={[0, 100]} tick={{ fontSize: tickFontSize }} hide={compact} />
            {showLabels && <Tooltip />}
            <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
            <Bar dataKey="ISE" radius={[4, 4, 0, 0]}>
              {data.map((entry, index) => (
                <Cell key={index} fill={entry.color} />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      );
    }

    default:
      return (
        <div className="flex items-center justify-center h-full text-gray-400">
          Gráfico no disponible
        </div>
      );
  }
}
