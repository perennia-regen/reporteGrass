import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"
import { grassTheme } from "@/styles/grass-theme"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Obtiene el color de un estrato por su nombre.
 * Usa el gradiente fucsia → celeste apagado definido en grass-theme.
 *
 * @param nombre Nombre del estrato (Loma, Media Loma, Bajo)
 * @returns Color hexadecimal del estrato
 */
export function getEstratoColor(nombre: string): string {
  const map: Record<string, string> = {
    'Loma': grassTheme.colors.estratos.loma,           // #b35d8d (fucsia apagado)
    'Media Loma': grassTheme.colors.estratos.mediaLoma, // #87809f (lavanda apagado)
    'Bajo': grassTheme.colors.estratos.bajo,           // #5ba3b0 (celeste apagado)
  };
  return map[nombre] || grassTheme.colors.neutral.grayDark;
}
