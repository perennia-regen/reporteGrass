import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Habilita React Strict Mode para detectar problemas potenciales
  reactStrictMode: true,

  // Configuración de imágenes
  images: {
    remotePatterns: [
      // Agrega aquí los dominios de imágenes externas si es necesario
      // {
      //   protocol: 'https',
      //   hostname: 'example.com',
      // },
    ],
  },

  // Headers de seguridad
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
        ],
      },
    ];
  },

  // Configuración experimental (Next.js 15+)
  experimental: {
    // Optimiza el tamaño del bundle
    optimizePackageImports: ['lucide-react', 'recharts'],
  },
};

export default nextConfig;
