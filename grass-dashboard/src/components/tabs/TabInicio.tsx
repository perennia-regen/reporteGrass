'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import { useDashboardStore } from '@/lib/dashboard-store';
import { GridEditor, EditableText } from '@/components/editor';

export function TabInicio() {
  const { establecimiento, ise, estratos, eventos, fotos } = mockDashboardData;
  const { tabs, isEditing, editableContent, updateContent } = useDashboardStore();
  const currentTab = tabs.find((t) => t.id === 'inicio');
  const customWidgets = currentTab?.widgets || [];

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* Identificación del Predio */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Identificación del Predio
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
              <p className="text-xs text-gray-500">Establecimiento</p>
              <p className="font-semibold">{establecimiento.nombre}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Código</p>
              <p className="font-semibold">{establecimiento.codigo}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Nodo / Técnico</p>
              <p className="font-semibold">{establecimiento.nodo}</p>
              <p className="text-sm text-gray-600">{establecimiento.tecnico}</p>
            </div>
            <div>
              <p className="text-xs text-gray-500">Fecha de Monitoreo</p>
              <p className="font-semibold">{establecimiento.fecha}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Datos Destacados - KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--grass-green-dark)]">
                {ise.promedio.toFixed(1)}
              </p>
              <p className="text-sm text-gray-500 mt-1">ISE Promedio</p>
              <div className="mt-2 text-xs">
                <span className={ise.promedio >= ISE_THRESHOLD ? 'text-green-600' : 'text-orange-500'}>
                  {ise.promedio >= ISE_THRESHOLD ? 'Deseable' : `${(ISE_THRESHOLD - ise.promedio).toFixed(1)} pts bajo umbral`}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--grass-brown)]">
                {establecimiento.areaTotal}
              </p>
              <p className="text-sm text-gray-500 mt-1">Hectáreas</p>
              <p className="text-xs text-gray-400 mt-2">Área total monitoreada</p>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--estrato-loma)]">
                {estratos.reduce((sum, e) => sum + e.estaciones, 0)}
              </p>
              <p className="text-sm text-gray-500 mt-1">Sitios MCP</p>
              <p className="text-xs text-gray-400 mt-2">Puntos de monitoreo</p>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--grass-orange)]">
                {estratos.length}
              </p>
              <p className="text-sm text-gray-500 mt-1">Estratos</p>
              <p className="text-xs text-gray-400 mt-2">Ambientes diferenciados</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* ISE por Estrato - Vista rápida */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            ISE por Estrato
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {Object.entries(ise.porEstrato).map(([estrato, valor]) => {
              const porcentaje = (valor / 100) * 100;
              return (
                <div key={estrato} className="flex items-center gap-4">
                  <span className="w-24 text-sm font-medium">{estrato}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-6 relative overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{
                        width: `${Math.max(porcentaje, 0)}%`,
                        backgroundColor: valor >= ISE_THRESHOLD ? 'var(--grass-green)' : 'var(--grass-brown)',
                      }}
                    />
                    {/* Línea de umbral deseable */}
                    <div
                      className="absolute top-0 bottom-0 w-0.5 bg-gray-400"
                      style={{ left: `${ISE_THRESHOLD}%` }}
                    />
                  </div>
                  <span className="w-12 text-right font-semibold">{valor.toFixed(1)}</span>
                </div>
              );
            })}
            <p className="text-xs text-gray-500 mt-2">
              Línea vertical indica umbral deseable (70 puntos)
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Observación General */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Observación General
          </CardTitle>
        </CardHeader>
        <CardContent>
          <EditableText
            value={editableContent.observacionGeneral}
            onChange={(value) => updateContent('observacionGeneral', value)}
            placeholder="Ingrese una observación general del monitoreo..."
            className="text-gray-700 leading-relaxed"
            multiline
          />
        </CardContent>
      </Card>

      {/* Historial de Monitoreos */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Historial de Monitoreos
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="relative">
            {/* Línea del tiempo */}
            <div className="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200" />

            <div className="space-y-4">
              {eventos.map((evento, index) => (
                <div key={evento.id} className="flex gap-4 relative">
                  {/* Punto en la línea */}
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center shrink-0 z-10 ${
                      index === eventos.length - 1
                        ? 'bg-[var(--grass-green)] text-white'
                        : 'bg-white border-2 border-gray-300'
                    }`}
                  >
                    <span className="text-xs font-bold">{eventos.length - index}</span>
                  </div>

                  {/* Contenido */}
                  <div className="flex-1 bg-white rounded-lg border p-3">
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="font-medium text-sm">{evento.fecha}</p>
                        <p className="text-xs text-gray-500 mt-1">{evento.descripcion}</p>
                      </div>
                      {evento.iseResultado && (
                        <span className="text-lg font-bold text-[var(--grass-brown)]">
                          ISE: {evento.iseResultado}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Galería de Fotos (Placeholder) */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Fotos del Monitoreo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {fotos.map((_, index) => (
              <div
                key={index}
                className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center text-gray-400"
              >
                <div className="text-center">
                  <svg
                    className="w-8 h-8 mx-auto mb-2"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={1.5}
                      d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                    />
                  </svg>
                  <span className="text-xs">Foto {index + 1}</span>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Área de widgets personalizables */}
      {(isEditing || customWidgets.length > 0) && (
        <div className="mt-8">
          <h3 className="text-lg font-semibold text-[var(--grass-green-dark)] mb-4">
            {isEditing ? 'Widgets Personalizables' : 'Contenido Adicional'}
          </h3>
          <GridEditor widgets={customWidgets} tabId="inicio" />
        </div>
      )}
    </div>
  );
}
