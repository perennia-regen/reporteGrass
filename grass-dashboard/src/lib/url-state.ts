import type { KPIType } from './dashboard-store';
import type { SugerenciaItem } from '@/types/dashboard';
import pako from 'pako';

// Estado compartible via URL (solo lo necesario para el productor)
export interface ShareableState {
  // KPIs seleccionados
  kpis: [KPIType, KPIType, KPIType];
  // Contenido editable
  content: Record<string, string>;
  // Sugerencias
  sug: SugerenciaItem[];
  // Versión para compatibilidad futura
  v: number;
}

// Serializar estado a string comprimido para URL
export function serializeState(state: ShareableState): string {
  try {
    const json = JSON.stringify(state);
    // Comprimir con pako (gzip)
    const compressed = pako.deflate(json);
    // Convertir a base64 URL-safe
    const base64 = btoa(String.fromCharCode(...compressed))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
    return base64;
  } catch (error) {
    console.error('Error serializando estado:', error);
    return '';
  }
}

// Deserializar estado desde string de URL
export function deserializeState(encoded: string): ShareableState | null {
  try {
    // Restaurar base64 estándar
    let base64 = encoded.replace(/-/g, '+').replace(/_/g, '/');
    // Agregar padding si es necesario
    while (base64.length % 4) {
      base64 += '=';
    }
    // Decodificar base64
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    // Descomprimir
    const decompressed = pako.inflate(bytes, { to: 'string' });
    return JSON.parse(decompressed);
  } catch (error) {
    console.error('Error deserializando estado:', error);
    return null;
  }
}

// Crear URL compartible con estado
export function createShareUrl(
  baseUrl: string,
  state: ShareableState,
  establecimientoNombre: string
): string {
  const stateParam = serializeState(state);
  // ID corto para identificación (no contiene el estado)
  const shortId = btoa(establecimientoNombre).substring(0, 8);
  return `${baseUrl}/preview/${shortId}?s=${stateParam}`;
}
