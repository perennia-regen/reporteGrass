import type { Metadata } from "next";
import { Geist, Geist_Mono, Inter, Roboto, Open_Sans } from "next/font/google";
import "./globals.css";

/* ============================================
   CONFIGURACIÓN DE TIPOGRAFÍAS
   Modifica aquí para cambiar las fuentes
   ============================================ */

// Fuente principal (sans-serif)
// Opciones disponibles: Geist, Inter, Roboto, Open_Sans
// Para usar otra fuente de Google Fonts, importa y configura aquí
const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap", // Mejora el rendimiento
});

// Fuente monoespaciada (para código)
const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
  display: "swap",
});

// Fuente para títulos/display (opcional)
// Descomenta y configura si quieres una fuente diferente para títulos
// const displayFont = Inter({
//   variable: "--font-display",
//   subsets: ["latin"],
//   weight: ["600", "700", "800"],
//   display: "swap",
// });

export const metadata: Metadata = {
  title: "Dashboard GRASS - Monitoreo Ambiental",
  description: "Herramienta de dashboards para monitoreo ambiental GRASS",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
