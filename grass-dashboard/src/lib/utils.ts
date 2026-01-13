import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"
import { grassTheme } from "@/styles/grass-theme"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

/**
 * Obtiene el color de un estrato por su nombre
 * @param nombre Nombre del estrato (Loma, Media Loma, Bajo)
 * @returns Color hexadecimal del estrato
 */
export function getEstratoColor(nombre: string): string {
  const map: Record<string, string> = {
    'Loma': grassTheme.colors.estratos.loma,
    'Media Loma': grassTheme.colors.estratos.mediaLoma,
    'Bajo': grassTheme.colors.estratos.bajo,
  };
  return map[nombre] || grassTheme.colors.neutral.grayDark;
}
