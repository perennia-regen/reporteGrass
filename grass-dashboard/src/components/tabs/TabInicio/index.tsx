'use client';

import { useState, useMemo } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { mockDashboardData } from '@/lib/mock-data';
import { useDashboardStore } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { SugerenciasSection } from '@/components/sugerencias';
import { PhotoGalleryModal } from '@/components/PhotoGalleryModal';
import type { FotoMonitoreo } from '@/types/dashboard';
import { ArrowRight, TrendingUp, Plus, Camera } from 'lucide-react';

// Modular imports
import { QUICK_ACTIONS } from './constants';
import { useChartState } from './hooks';
import { KPICard, ChartHeader, ChartRenderer } from './components';

export function TabInicio() {
  const { establecimiento, fotos } = mockDashboardData;
  const { isEditing, editableContent, updateContent, setActiveTab, selectedKPIs, updateKPI } = useDashboardStore();

  // Chart state management
  const {
    chart1,
    setChart1,
    chart2,
    setChart2,
    additionalCharts,
    usedCharts,
    availableCharts,
    addChart,
    removeChart,
    updateAdditionalChart,
  } = useChartState();

  // KPIs from store (persisted)
  const [kpi1, kpi2, kpi3] = selectedKPIs;
  const usedKPIs = useMemo(() => [kpi1, kpi2, kpi3], [kpi1, kpi2, kpi3]);

  // Photo gallery state
  const [showGallery, setShowGallery] = useState(false);
  const [selectedPhotoIndex, setSelectedPhotoIndex] = useState<number | null>(null);
  const [localFotos, setLocalFotos] = useState<FotoMonitoreo[]>(fotos);

  // Photo selection handler
  const handlePhotoSelect = (foto: FotoMonitoreo) => {
    if (selectedPhotoIndex !== null) {
      const newFotos = [...localFotos];
      newFotos[selectedPhotoIndex] = foto;
      setLocalFotos(newFotos);
    }
    setSelectedPhotoIndex(null);
  };

  // Location string for gallery
  const ubicacionStr = `${establecimiento.ubicacion.distrito}, ${establecimiento.ubicacion.departamento}`;

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* KPI Cards Section */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <KPICard value={kpi1} onChange={(v) => updateKPI(0, v)} usedKPIs={usedKPIs} />
        <KPICard value={kpi2} onChange={(v) => updateKPI(1, v)} usedKPIs={usedKPIs} />
        <KPICard value={kpi3} onChange={(v) => updateKPI(2, v)} usedKPIs={usedKPIs} />
      </div>

      {/* Main Results - Charts */}
      <Card>
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg text-[var(--grass-green-dark)] flex items-center gap-2">
              <TrendingUp className="w-5 h-5" />
              Principales Resultados
            </CardTitle>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setActiveTab('resultados')}
              className="text-[var(--grass-green-dark)] border-[var(--grass-green)] hover:bg-[var(--grass-green-light)]"
            >
              Ver resultados completos
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {/* Main charts (2 columns) */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Chart 1 */}
            <div className="border rounded-lg overflow-hidden">
              <ChartHeader
                value={chart1}
                onChange={setChart1}
                usedCharts={usedCharts}
              />
              <ChartRenderer chartType={chart1} />
            </div>

            {/* Chart 2 */}
            <div className="border rounded-lg overflow-hidden">
              <ChartHeader
                value={chart2}
                onChange={setChart2}
                usedCharts={usedCharts}
              />
              <ChartRenderer chartType={chart2} />
            </div>
          </div>

          {/* Additional charts */}
          {additionalCharts.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
              {additionalCharts.map((chartType, index) => (
                <div key={index} className="border rounded-lg overflow-hidden">
                  <ChartHeader
                    value={chartType}
                    onChange={(newType) => updateAdditionalChart(index, newType)}
                    usedCharts={usedCharts}
                    canRemove={true}
                    onRemove={() => removeChart(index)}
                  />
                  <ChartRenderer chartType={chartType} />
                </div>
              ))}
            </div>
          )}

          {/* Add chart button - only in edit mode and max 4 charts total */}
          {isEditing && availableCharts.length > 0 && additionalCharts.length < 2 && (
            <div className="mt-6 flex justify-center p-6 border-2 border-dashed rounded-lg border-gray-300 hover:border-gray-400 transition-colors">
              <Button
                variant="ghost"
                onClick={() => addChart()}
                className="text-gray-500 hover:text-[var(--grass-green-dark)]"
              >
                <Plus className="w-4 h-4 mr-2" />
                Agregar grafico ({2 + additionalCharts.length}/4)
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* General Observation */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Observacion General
          </CardTitle>
        </CardHeader>
        <CardContent>
          <EditableText
            value={editableContent.observacionGeneral}
            onChange={(value) => updateContent('observacionGeneral', value)}
            placeholder="Ingrese una observacion general del monitoreo..."
            className="text-gray-700 leading-relaxed"
            multiline
          />
        </CardContent>
      </Card>

      {/* Suggestions and Recommendations */}
      <SugerenciasSection />

      {/* Monitoring Photos */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Fotos del Monitoreo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {localFotos.map((foto, index) => (
              <div key={index} className="group">
                {/* Photo with edit option */}
                <div
                  className={`aspect-video bg-gray-100 rounded-lg flex items-center justify-center text-gray-400 relative overflow-hidden ${
                    isEditing ? 'cursor-pointer hover:bg-gray-200 transition-colors' : ''
                  }`}
                  onClick={() => {
                    if (isEditing) {
                      setSelectedPhotoIndex(index);
                      setShowGallery(true);
                    }
                  }}
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
                  </div>
                  {/* Edit overlay */}
                  {isEditing && (
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 flex items-center justify-center transition-colors">
                      <Camera className="w-6 h-6 text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                    </div>
                  )}
                </div>
                {/* Photo caption with editable comment */}
                <div className="mt-2">
                  <p className="text-sm font-medium text-[var(--grass-green-dark)]">{foto.sitio}</p>
                  <p className="text-xs text-gray-400 mb-1">{ubicacionStr}</p>
                  <EditableText
                    value={editableContent[`foto_comentario_${index}`] || foto.comentario}
                    onChange={(value) => updateContent(`foto_comentario_${index}`, value)}
                    placeholder="Agregar comentario..."
                    className="text-xs text-gray-500"
                  />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Footer with Quick Actions */}
      <div className="mt-8 pt-6 pb-8 border-t border-gray-200">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
          {QUICK_ACTIONS.map((action) => (
            <Button
              key={action.id}
              variant="outline"
              size="sm"
              className="text-gray-600 hover:text-gray-900 hover:bg-gray-50 border-gray-200 w-full"
              onClick={() => setActiveTab(action.id)}
            >
              {action.name}
            </Button>
          ))}
        </div>
        <p className="text-center text-xs text-gray-400">
          Grassland Regeneration and Sustainable Standard - 2025
        </p>
      </div>

      {/* Photo Gallery Modal */}
      <PhotoGalleryModal
        isOpen={showGallery}
        onClose={() => {
          setShowGallery(false);
          setSelectedPhotoIndex(null);
        }}
        onSelect={handlePhotoSelect}
        currentPhotoUrl={selectedPhotoIndex !== null ? localFotos[selectedPhotoIndex]?.url : undefined}
      />
    </div>
  );
}
