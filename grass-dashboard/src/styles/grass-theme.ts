// Tema GRASS basado en el Template PDF
export const grassTheme = {
  colors: {
    // Colores principales
    primary: {
      green: '#4CAF50',      // Verde logo GRASS
      greenDark: '#2E7D32',  // Verde oscuro títulos
      greenLight: '#81C784', // Verde claro acentos
    },
    // Colores de estratos
    estratos: {
      loma: '#1565C0',       // Azul oscuro
      mediaLoma: '#42A5F5',  // Azul claro
      bajo: '#EF9A9A',       // Rosa/rojo claro
    },
    // Colores de procesos ecosistémicos
    procesos: {
      cicloAgua: '#E65100',     // Naranja oscuro
      cicloMineral: '#8D6E63',  // Marrón
      flujoEnergia: '#2E7D32',  // Verde oscuro
      dinamicaComunidades: '#FFC107', // Amarillo/dorado
    },
    // Neutrales
    neutral: {
      white: '#FFFFFF',
      grayLight: '#F5F5F5',
      grayMedium: '#E0E0E0',
      grayDark: '#757575',
      black: '#212121',
    },
    // Estados
    status: {
      success: '#4CAF50',
      warning: '#FF9800',
      error: '#F44336',
      info: '#2196F3',
    },
  },

  // Tipografía
  typography: {
    fontFamily: {
      sans: 'Inter, system-ui, -apple-system, sans-serif',
      mono: 'JetBrains Mono, Consolas, monospace',
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
    },
    fontWeight: {
      normal: '400',
      medium: '500',
      semibold: '600',
      bold: '700',
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
  bar: ['#8D6E63', '#A1887F', '#BCAAA4'],
  line: ['#E65100', '#8D6E63', '#2E7D32', '#FFC107'],
  pie: ['#1565C0', '#8D6E63', '#EF9A9A'],
};

// Umbral ISE deseable
export const ISE_THRESHOLD = 70;
