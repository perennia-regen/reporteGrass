'use client';

import Image from 'next/image';
import { useState } from 'react';

interface LogoProps {
  /**
   * Tamaño del logo
   * @default "md"
   */
  size?: 'sm' | 'md' | 'lg' | 'xl';
  
  /**
   * Mostrar texto junto al logo
   * @default true
   */
  showText?: boolean;
  
  /**
   * Ruta a la imagen del logo (opcional)
   * Si no se proporciona, se usa el logo SVG por defecto
   */
  logoSrc?: string;
  
  /**
   * Texto alternativo para el logo
   * @default "GRASS"
   */
  altText?: string;
  
  /**
   * Color del logo (solo para SVG)
   * @default "#4CAF50" (grass-green)
   */
  logoColor?: string;
  
  /**
   * Color del fondo del logo
   * @default "black"
   */
  backgroundColor?: string;
  
  /**
   * Clase CSS adicional
   */
  className?: string;
}

/**
 * Componente de Logo personalizable para GRASS
 * 
 * Para personalizar el logo:
 * 1. Coloca tu imagen en /public/logo.png (o logo.svg)
 * 2. Pasa logoSrc="/logo.png" al componente
 * 3. O modifica el SVG por defecto en este archivo
 */
export function Logo({
  size = 'md',
  showText = true,
  logoSrc = '/logo-grass.png', // Logo GRASS por defecto
  altText = 'GRASS',
  logoColor = 'var(--grass-green)',
  backgroundColor = 'black',
  className = '',
}: LogoProps) {
  const [imageError, setImageError] = useState(false);

  const sizeClasses = {
    sm: 'w-8 h-8',
    md: 'w-10 h-10',
    lg: 'w-12 h-12',
    xl: 'w-16 h-16',
  };

  const textSizeClasses = {
    sm: 'text-sm',
    md: 'text-lg',
    lg: 'text-xl',
    xl: 'text-2xl',
  };

  // Si hay una imagen personalizada y no hubo error, usarla
  if (logoSrc && !imageError) {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        <div className={`${sizeClasses[size]} relative flex-shrink-0`}>
          <Image
            src={logoSrc}
            alt={altText}
            fill
            className="object-contain"
            onError={() => {
              console.error('Error cargando logo:', logoSrc);
              setImageError(true);
            }}
            priority
          />
        </div>
        {showText && (
          <span className={`font-bold text-[var(--grass-green-dark)] ${textSizeClasses[size]}`}>
            {altText}
          </span>
        )}
      </div>
    );
  }

  // Logo SVG de GRASS - Usa el logo desde /public/logo-grass.svg
  return (
    <div className={`flex items-center gap-2 ${className}`}>
      <div
        className={`${sizeClasses[size]} rounded flex items-center justify-center`}
        style={{ backgroundColor: 'transparent' }}
      >
        <svg
          viewBox="0 0 120 120"
          className={`${sizeClasses[size]}`}
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          {/* Fondo circular verde GRASS */}
          <circle cx="60" cy="60" r="58" fill="#4CAF50" stroke="#2E7D32" strokeWidth="2"/>
          
          {/* Icono de pasto/hierba estilizado */}
          <g transform="translate(60, 60)">
            {/* Hojas de pasto */}
            <path d="M-15,10 Q-10,0 -5,10 L-5,25 Q-10,15 -15,25 Z" fill="#FFFFFF" opacity="0.9"/>
            <path d="M-5,10 Q0,0 5,10 L5,25 Q0,15 -5,25 Z" fill="#FFFFFF" opacity="0.9"/>
            <path d="M5,10 Q10,0 15,10 L15,25 Q10,15 5,25 Z" fill="#FFFFFF" opacity="0.9"/>
            
            {/* Tallos */}
            <line x1="-10" y1="10" x2="-10" y2="25" stroke="#FFFFFF" strokeWidth="2" strokeLinecap="round"/>
            <line x1="0" y1="10" x2="0" y2="25" stroke="#FFFFFF" strokeWidth="2" strokeLinecap="round"/>
            <line x1="10" y1="10" x2="10" y2="25" stroke="#FFFFFF" strokeWidth="2" strokeLinecap="round"/>
            
            {/* Texto GRASS */}
            <text
              x="0"
              y="45"
              textAnchor="middle"
              fill="#FFFFFF"
              fontFamily="Arial, sans-serif"
              fontSize="18"
              fontWeight="bold"
              letterSpacing="1"
            >
              GRASS
            </text>
          </g>
        </svg>
      </div>
      {showText && (
        <span className={`font-bold text-[var(--grass-green-dark)] ${textSizeClasses[size]}`}>
          {altText}
        </span>
      )}
    </div>
  );
}
