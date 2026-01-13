import type { Config } from 'tailwindcss';

/**
 * Configuración de Tailwind CSS v4
 * 
 * NOTA: Tailwind v4 usa principalmente CSS para la configuración.
 * La mayoría de las personalizaciones están en globals.css usando @theme.
 * 
 * Este archivo se mantiene para compatibilidad y configuración adicional.
 */
const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      // Las fuentes se configuran en globals.css y layout.tsx
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-geist-mono)', 'monospace'],
        display: ['var(--font-display)', 'var(--font-geist-sans)', 'sans-serif'],
      },
      
      // Los colores se configuran en globals.css como variables CSS
      // Aquí puedes agregar colores adicionales si es necesario
      colors: {
        // Estos colores están disponibles como variables CSS
        // Úsalos así: bg-[var(--grass-green)]
        grass: {
          green: 'var(--grass-green)',
          'green-dark': 'var(--grass-green-dark)',
          'green-light': 'var(--grass-green-light)',
          orange: 'var(--grass-orange)',
          brown: 'var(--grass-brown)',
          yellow: 'var(--grass-yellow)',
        },
        estrato: {
          loma: 'var(--estrato-loma)',
          'media-loma': 'var(--estrato-media-loma)',
          bajo: 'var(--estrato-bajo)',
        },
      },
      
      // Border radius se configura en globals.css
      borderRadius: {
        'sm': 'var(--radius-sm)',
        'md': 'var(--radius-md)',
        'lg': 'var(--radius-lg)',
        'xl': 'var(--radius-xl)',
        '2xl': 'var(--radius-2xl)',
        '3xl': 'var(--radius-3xl)',
        '4xl': 'var(--radius-4xl)',
      },
    },
  },
  plugins: [],
};

export default config;
