# Guía de Personalización - Dashboard GRASS

Esta guía te ayudará a personalizar los colores, tipografías, logos y demás elementos del dashboard.

## 📁 Archivos de Configuración

### 1. Colores (`src/app/globals.css`)

Los colores se definen en las variables CSS en `:root`. Modifica estos valores:

```css
:root {
  /* Colores GRASS */
  --grass-green: #4CAF50;           /* Verde principal */
  --grass-green-dark: #2E7D32;      /* Verde oscuro */
  --grass-green-light: #81C784;     /* Verde claro */
  --grass-orange: #E65100;          /* Naranja */
  --grass-brown: #8D6E63;           /* Marrón */
  --grass-yellow: #FFC107;          /* Amarillo */
  
  /* Estratos */
  --estrato-loma: #1565C0;
  --estrato-media-loma: #42A5F5;
  --estrato-bajo: #EF9A9A;
}
```

**Cómo usar los colores en componentes:**
```tsx
// En clases de Tailwind
<div className="bg-[var(--grass-green)] text-white">

// O usando el tema TypeScript
import { grassTheme } from '@/styles/grass-theme';
<div style={{ backgroundColor: grassTheme.colors.primary.green }}>
```

### 2. Tipografías (`src/app/layout.tsx`)

Para cambiar las fuentes, modifica las importaciones en `layout.tsx`:

```tsx
// Opciones disponibles de Google Fonts:
import { Geist, Geist_Mono } from "next/font/google";
import { Inter } from "next/font/google";
import { Roboto } from "next/font/google";
import { Open_Sans } from "next/font/google";

// Configura tu fuente principal
const mainFont = Inter({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});
```

**Fuentes recomendadas:**
- **Sans-serif**: Inter, Roboto, Open Sans, Poppins
- **Mono**: JetBrains Mono, Fira Code, Source Code Pro
- **Display**: Playfair Display, Montserrat, Raleway

### 3. Logo (`src/components/ui/logo.tsx`)

#### Opción A: Usar una imagen personalizada

1. Coloca tu logo en `/public/logo.png` (o `.svg`, `.jpg`)
2. Usa el componente así:

```tsx
import { Logo } from '@/components/ui/logo';

<Logo
  logoSrc="/logo.png"
  size="md"
  showText={true}
  altText="GRASS"
/>
```

#### Opción B: Personalizar el SVG por defecto

Edita el SVG en `src/components/ui/logo.tsx`:

```tsx
// Modifica el path del SVG
<path
  d="TU_PATH_PERSONALIZADO_AQUI"
  stroke={logoColor}
  strokeWidth="2"
/>
```

### 4. Tema TypeScript (`src/styles/grass-theme.ts`)

Este archivo contiene la configuración del tema en TypeScript. Úsalo para:

- Acceder a colores en código TypeScript/JavaScript
- Mantener consistencia entre CSS y TypeScript
- Documentar la paleta de colores

```tsx
import { grassTheme } from '@/styles/grass-theme';

const color = grassTheme.colors.primary.green;
```

## 🎨 Ejemplos de Personalización

### Cambiar el color principal a azul

1. En `globals.css`:
```css
--grass-green: #2196F3;
--grass-green-dark: #1976D2;
--grass-green-light: #64B5F6;
```

2. En `grass-theme.ts`:
```ts
primary: {
  green: '#2196F3',
  greenDark: '#1976D2',
  greenLight: '#64B5F6',
}
```

### Cambiar la fuente a Inter

1. En `layout.tsx`:
```tsx
import { Inter } from "next/font/google";

const inter = Inter({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});
```

2. En `globals.css` (ya está configurado para usar la variable)

### Agregar un logo personalizado

1. Coloca `logo.png` en `/public/`
2. En `Header.tsx` o donde uses el Logo:
```tsx
<Logo
  logoSrc="/logo.png"
  size="lg"
  showText={true}
  altText="Mi Organización"
/>
```

## 🔧 Configuración Avanzada

### Variables CSS adicionales

Puedes agregar más variables en `globals.css`:

```css
:root {
  --mi-color-personalizado: #FF5733;
}
```

Luego úsalo en Tailwind:
```tsx
<div className="bg-[var(--mi-color-personalizado)]">
```

### Espaciado personalizado

Los espaciados están en `grass-theme.ts`. También puedes usar las utilidades de Tailwind:
- `p-4`, `m-4` (padding, margin)
- `gap-4` (gap en flex/grid)
- `space-y-4` (espaciado vertical)

### Border Radius

Modifica `--radius` en `globals.css`:
```css
:root {
  --radius: 0.5rem; /* Más pequeño */
  --radius: 1rem;   /* Más grande */
}
```

## 📝 Checklist de Personalización

- [ ] Colores principales modificados en `globals.css`
- [ ] Colores actualizados en `grass-theme.ts`
- [ ] Tipografías cambiadas en `layout.tsx`
- [ ] Logo personalizado agregado o SVG modificado
- [ ] Variables CSS adicionales agregadas (si es necesario)
- [ ] Border radius ajustado (si es necesario)
- [ ] Pruebas visuales realizadas

## 🚀 Próximos Pasos

1. Modifica los valores en los archivos mencionados
2. Ejecuta `npm run dev` para ver los cambios
3. Ajusta según sea necesario
4. ¡Listo! Tu dashboard está personalizado

## 💡 Tips

- Usa herramientas como [Coolors](https://coolors.co) para generar paletas de colores
- Verifica el contraste de colores para accesibilidad
- Mantén consistencia entre los archivos CSS y TypeScript
- Prueba en modo claro y oscuro si usas ambos temas
