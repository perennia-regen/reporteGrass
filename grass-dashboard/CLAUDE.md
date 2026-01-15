# GRASS Dashboard - Development Guidelines

## React/Next.js Best Practices

Este proyecto sigue las Vercel React Best Practices. Antes de implementar nuevas funcionalidades:

1. Invocar skill: `/vercel-react-best-practices`
2. Verificar el checklist abajo antes de hacer PR

## Checklist Pre-Commit

### Data Fetching
- [ ] No hay `await` secuenciales que puedan ejecutarse en paralelo
- [ ] `Promise.all()` para operaciones independientes
- [ ] `Suspense` boundaries para async components
- [ ] Usar `React.cache()` para deduplicar requests en Server Components

### Bundle Size
- [ ] `next/dynamic` para componentes >50KB
- [ ] Named imports de librerias (no barrel imports de paquetes externos)
- [ ] Analytics/third-party cargados post-hydration con `ssr: false`
- [ ] Preload en hover/focus para componentes pesados

### Re-renders
- [ ] `useMemo` para computaciones costosas
- [ ] `useCallback` para handlers pasados como props
- [ ] Functional `setState(prev => ...)` cuando depende del estado anterior
- [ ] `React.memo()` para componentes con props estables
- [ ] `useTransition` para updates no urgentes

### Performance
- [ ] No crear RegExp dentro de render (hoistear a nivel de modulo)
- [ ] No objetos/arrays inline en dependency arrays de hooks
- [ ] Cache de localStorage/sessionStorage reads
- [ ] Usar `Set`/`Map` para lookups O(1) en lugar de arrays

## Patrones Ya Implementados (Mantener)

El proyecto ya tiene estas optimizaciones implementadas:

| Patron | Implementacion |
|--------|----------------|
| Code Splitting | Todos los tabs usan `next/dynamic` en [Canvas.tsx](src/components/layout/Canvas.tsx) |
| Maps Lazy Load | Leaflet cargado dinamicamente con `ssr: false` en [DynamicMaps.tsx](src/components/maps/DynamicMaps.tsx) |
| Charts Memoization | Todos los charts en [TabInicio/charts/](src/components/tabs/TabInicio/charts/) usan `memo()` + `useMemo()` |
| State Management | Zustand con persist middleware en [dashboard-store.ts](src/lib/dashboard-store.ts) |
| Bulk Updates | `updateBulkContent()` para actualizar multiples campos en una sola operacion |
| Package Optimization | `optimizePackageImports` en next.config.ts para lucide-react y recharts |

## Estructura de Componentes

### Cuando usar `next/dynamic`
- Componentes con librerias pesadas (charts, maps, PDF)
- Modales que no se muestran en initial render
- Tabs que no son visibles al inicio

### Cuando usar `React.memo()`
- Componentes que reciben las mismas props frecuentemente
- Componentes hijos de listas
- Charts y visualizaciones

### Cuando usar `useMemo`/`useCallback`
- Computaciones derivadas de props/state
- Handlers pasados como props a componentes memoizados
- Valores usados en dependency arrays de otros hooks
