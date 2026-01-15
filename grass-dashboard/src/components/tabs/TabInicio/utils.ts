import { CHART_OPTIONS, type ChartType } from './constants';

/**
 * Calculate percentage evolution between two values
 */
export const calcularEvolucion = (actual: number, anterior: number): number => {
  if (anterior === 0) return actual > 0 ? 100 : 0;
  return ((actual - anterior) / Math.abs(anterior)) * 100;
};

/**
 * Get the display name for a chart type
 */
export const getChartName = (chartType: ChartType): string => {
  return CHART_OPTIONS.find(opt => opt.id === chartType)?.name || '';
};

/**
 * Calculate ISE gradient color based on value (0-100)
 * Uses GRASS palette: estrato-loma (#313b2e) -> grass-green (#8aca53) -> grass-green-light (#b1ff6d)
 */
export const getISEGradientColor = (valor: number): string => {
  const normalized = Math.max(0, Math.min(100, valor)) / 100;

  if (normalized < 0.5) {
    // From estrato-loma (#313b2e) to grass-green (#8aca53)
    const t = normalized * 2;
    const r = Math.round(49 + (138 - 49) * t);
    const g = Math.round(59 + (202 - 59) * t);
    const b = Math.round(46 + (83 - 46) * t);
    return `rgb(${r}, ${g}, ${b})`;
  } else {
    // From grass-green (#8aca53) to grass-green-light (#b1ff6d)
    const t = (normalized - 0.5) * 2;
    const r = Math.round(138 + (177 - 138) * t);
    const g = Math.round(202 + (255 - 202) * t);
    const b = Math.round(83 + (109 - 83) * t);
    return `rgb(${r}, ${g}, ${b})`;
  }
};
