'use client';

import { memo } from 'react';
import type { ChartType } from '../constants';
import {
  EvolucionISEChart,
  ISEEstratoChart,
  ProcesosChart,
  ProcesosEvolucionChart,
} from '../charts';

interface ChartRendererProps {
  chartType: ChartType;
}

export const ChartRenderer = memo(function ChartRenderer({ chartType }: ChartRendererProps) {
  switch (chartType) {
    case 'evolucion-ise':
      return <EvolucionISEChart />;
    case 'ise-estrato':
      return <ISEEstratoChart />;
    case 'procesos':
      return <ProcesosChart />;
    case 'procesos-evolucion':
      return <ProcesosEvolucionChart />;
    default:
      return null;
  }
});
