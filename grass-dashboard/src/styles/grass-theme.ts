/**
 * Tema GRASS - Configuración centralizada
 * 
 * NOTA: Los colores también están definidos en globals.css como variables CSS.
 * Modifica ambos archivos para mantener la consistencia.
 * 
 * Para personalizar:
 * 1. Modifica los valores de colores abajo
 * 2. Actualiza las variables CSS en globals.css
 * 3. Los cambios se reflejarán en todo el dashboard
 */

// ============================================
// CONFIGURACIÓN DE COLORES - MODIFICA AQUÍ
// ============================================
export const grassTheme = {
  colors: {
    // Colores principales GRASS
    primary: {
      green: '#8aca53',      // Verde logo GRASS - var(--grass-green)
      greenDark: '#507531',  // Verde oscuro títulos - var(--grass-green-dark)
      greenLight: '#b1ff6d', // Verde claro acentos - var(--grass-green-light)
    },
    
    // Colores de estratos (gradiente fucsia apagado → celeste apagado)
    estratos: {
      // Colores base del gradiente
      gradientStart: '#b35d8d',  // Fucsia apagado - var(--estrato-gradient-start)
      gradientEnd: '#5ba3b0',    // Celeste apagado - var(--estrato-gradient-end)
      // Colores predefinidos para 3 estratos (interpolados del gradiente)
      loma: '#b35d8d',       // Fucsia apagado - var(--estrato-loma)
      mediaLoma: '#87809f',  // Lavanda apagado - var(--estrato-media-loma)
      bajo: '#5ba3b0',       // Celeste apagado - var(--estrato-bajo)
    },
    
    // Colores de procesos ecosistémicos (paleta GRASS sobria)
    procesos: {
      cicloAgua: '#5a9a8a',        // Verde azulado/teal apagado
      cicloMineral: '#313b2e',     // Verde muy oscuro - var(--estrato-loma)
      flujoEnergia: '#8aca53',     // Verde grass - var(--grass-green)
      dinamicaComunidades: '#c4b896', // Beige/oliva apagado (tierra)
    },

    // Colores de intensidad de pastoreo (basados en Grafana)
    pastoreo: {
      intenso: '#dc2626',   // Rojo - pastoreo intenso
      moderado: '#facc15',  // Amarillo - pastoreo moderado
      leve: '#22c55e',      // Verde - pastoreo leve
      nulo: '#3b82f6',      // Azul - sin pastoreo
    },

    // Colores de calidad forrajera (1-5 scale)
    calidadForraje: {
      1: '#dc2626',  // Muy baja - rojo
      2: '#f97316',  // Baja - naranja
      3: '#facc15',  // Media - amarillo
      4: '#22c55e',  // Buena - verde
      5: '#16a34a',  // Muy buena - verde oscuro
    },
    
    // Colores neutrales
    neutral: {
      white: '#FFFFFF',
      grayLight: '#F5F5F5',
      grayMedium: '#E0E0E0',
      grayDark: '#757575',
      black: '#212121',
    },
    
    // Estados del sistema
    status: {
      success: '#8aca53',    // Verde - éxito (usa primary.green)
      warning: '#FF9800',    // Naranja - advertencia
      error: '#F44336',      // Rojo - error
      info: '#2196F3',       // Azul - información
    },
  },

  // ============================================
  // CONFIGURACIÓN DE TIPOGRAFÍAS - MODIFICA AQUÍ
  // ============================================
  typography: {
    fontFamily: {
      // Fuente principal (sans-serif)
      // Debe coincidir con la fuente importada en layout.tsx
      sans: 'var(--font-geist-sans), Inter, system-ui, -apple-system, sans-serif',
      // Fuente monoespaciada (para código)
      mono: 'var(--font-geist-mono), JetBrains Mono, Consolas, monospace',
      // Fuente para títulos/display (opcional)
      display: 'var(--font-display, var(--font-geist-sans)), Inter, system-ui, sans-serif',
    },
    fontSize: {
      xs: '0.75rem',    // 12px
      sm: '0.875rem',   // 14px
      base: '1rem',     // 16px
      lg: '1.125rem',   // 18px
      xl: '1.25rem',    // 20px
      '2xl': '1.5rem',  // 24px
      '3xl': '1.875rem', // 30px
      '4xl': '2.25rem', // 36px
      '5xl': '3rem',    // 48px
      '6xl': '3.75rem', // 60px
    },
    fontWeight: {
      light: '300',
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
      extrabold: '800',
    },
    lineHeight: {
      tight: '1.25',
      normal: '1.5',
      relaxed: '1.75',
      loose: '2',
    },
  },

  // Espaciado
  spacing: {
    xs: '0.25rem',  // 4px
    sm: '0.5rem',   // 8px
    md: '1rem',     // 16px
    lg: '1.5rem',   // 24px
    xl: '2rem',     // 32px
    '2xl': '3rem',  // 48px
  },

  // Border radius
  borderRadius: {
    sm: '0.25rem',  // 4px
    md: '0.5rem',   // 8px
    lg: '0.75rem',  // 12px
    xl: '1rem',     // 16px
    full: '9999px',
  },

  // Sombras
  shadows: {
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
  },
} as const;

// Colores para gráficos de Recharts
export const chartColors = {
  bar: ['#252525', '#507531', '#8aca53'], // Usa brown, greenDark, green
  line: ['#ff5900', '#252525', '#507531', '#FFC107'], // orange, brown, greenDark, yellow
  pie: ['#b35d8d', '#87809f', '#5ba3b0'], // Usa colores de estratos (fucsia → celeste apagado)
};

/**
 * Interpola linealmente entre dos valores
 */
function lerp(a: number, b: number, t: number): number {
  return a + (b - a) * t;
}

/**
 * Convierte un color hexadecimal a RGB
 */
function hexToRgb(hex: string): { r: number; g: number; b: number } {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  if (!result) return { r: 0, g: 0, b: 0 };
  return {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16),
  };
}

/**
 * Convierte RGB a hexadecimal
 */
function rgbToHex(r: number, g: number, b: number): string {
  return '#' + [r, g, b].map(x => {
    const hex = Math.round(x).toString(16);
    return hex.length === 1 ? '0' + hex : hex;
  }).join('');
}

/**
 * Genera un array de colores interpolados entre fucsia y azul claro
 * para cualquier cantidad de estratos.
 *
 * @param count Número de estratos
 * @returns Array de colores hexadecimales
 *
 * @example
 * generateEstratoColors(3) // ['#d946ef', '#a097f2', '#67e8f9']
 * generateEstratoColors(5) // ['#d946ef', '#bc6ef3', '#a097f2', '#83bff6', '#67e8f9']
 */
export function generateEstratoColors(count: number): string[] {
  if (count <= 0) return [];
  if (count === 1) return [grassTheme.colors.estratos.gradientStart];

  const startColor = hexToRgb(grassTheme.colors.estratos.gradientStart);
  const endColor = hexToRgb(grassTheme.colors.estratos.gradientEnd);

  const colors: string[] = [];

  for (let i = 0; i < count; i++) {
    const t = i / (count - 1);
    const r = lerp(startColor.r, endColor.r, t);
    const g = lerp(startColor.g, endColor.g, t);
    const b = lerp(startColor.b, endColor.b, t);
    colors.push(rgbToHex(r, g, b));
  }

  return colors;
}

// Umbral ISE deseable
export const ISE_THRESHOLD = 70;
