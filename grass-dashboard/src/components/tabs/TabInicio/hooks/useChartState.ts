import { useState, useCallback, useMemo } from 'react';
import { CHART_OPTIONS, type ChartType } from '../constants';

export function useChartState() {
  // State for main charts (always 2) and additional charts (max 2 more = 4 total)
  const [chart1, setChart1] = useState<ChartType>('evolucion-ise');
  const [chart2, setChart2] = useState<ChartType>('ise-estrato');
  const [additionalCharts, setAdditionalCharts] = useState<ChartType[]>([]);

  const usedCharts = useMemo(() => {
    return [chart1, chart2, ...additionalCharts];
  }, [chart1, chart2, additionalCharts]);

  const availableCharts = useMemo(() => {
    return CHART_OPTIONS.filter(opt => !usedCharts.includes(opt.id));
  }, [usedCharts]);

  const addChart = useCallback((chartType?: ChartType) => {
    if (chartType) {
      // If specific type is given, verify it's not in use
      if (!usedCharts.includes(chartType)) {
        setAdditionalCharts(prev => [...prev, chartType]);
      }
    } else {
      // If not specified, use first available
      const available = CHART_OPTIONS.filter(opt => !usedCharts.includes(opt.id));
      if (available.length > 0) {
        setAdditionalCharts(prev => [...prev, available[0].id]);
      }
    }
  }, [usedCharts]);

  const removeChart = useCallback((index: number) => {
    setAdditionalCharts(prev => prev.filter((_, i) => i !== index));
  }, []);

  const updateAdditionalChart = useCallback((index: number, newType: ChartType) => {
    setAdditionalCharts(prev => {
      const newCharts = [...prev];
      newCharts[index] = newType;
      return newCharts;
    });
  }, []);

  return {
    chart1,
    setChart1,
    chart2,
    setChart2,
    additionalCharts,
    usedCharts,
    availableCharts,
    addChart,
    removeChart,
    updateAdditionalChart,
  };
}
