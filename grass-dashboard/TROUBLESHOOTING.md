# Solución de Problemas - Servidor Next.js

## Si el servidor no inicia

### 1. Verificar que Node.js y npm estén instalados
```bash
node --version
npm --version
```

Si no están instalados, instálalos desde [nodejs.org](https://nodejs.org/)

### 2. Instalar dependencias
```bash
cd grass-dashboard
npm install
```

### 3. Verificar que el puerto 3000 esté libre
```bash
lsof -ti:3000
```

Si hay un proceso usando el puerto, puedes:
- Detenerlo: `kill -9 $(lsof -ti:3000)`
- O usar otro puerto: `npm run dev -- -p 3001`

### 4. Limpiar caché y reinstalar
```bash
rm -rf .next
rm -rf node_modules
npm install
npm run dev
```

### 5. Verificar errores de compilación
Si hay errores de TypeScript o compilación, revisa la consola donde ejecutaste `npm run dev`

### 6. Verificar que el logo esté en la ubicación correcta
El logo debe estar en: `grass-dashboard/public/logo-grass.png`

## Comandos útiles

- Iniciar servidor: `npm run dev`
- Compilar para producción: `npm run build`
- Ejecutar producción: `npm start`
- Linter: `npm run lint`
