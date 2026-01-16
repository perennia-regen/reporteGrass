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
    
    // Colores de estratos
    estratos: {
      loma: '#313b2e',       // Verde oscuro - var(--estrato-loma)
      mediaLoma: '#6cb460',  // Verde medio - var(--estrato-media-loma)
      bajo: '#75e192',       // Verde claro - var(--estrato-bajo)
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
  pie: ['#313b2e', '#6cb460', '#75e192'], // Usa colores de estratos
};

// Umbral ISE deseable
export const ISE_THRESHOLD = 70;
