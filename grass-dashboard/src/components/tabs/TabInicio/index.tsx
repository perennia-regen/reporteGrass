'use client';

import { useState, useMemo, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { sitePhotosGallery, type SitePhotoWithISE } from '@/lib/mock-data';
import { useDashboardStore, type KPIType } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { SugerenciasSection } from '@/components/sugerencias';
import { PhotoGalleryModal } from '@/components/PhotoGalleryModal';
import { ArrowRight, TrendingUp, Plus, Camera } from 'lucide-react';

// Modular imports
import { QUICK_ACTIONS } from './constants';
import { useChartState } from './hooks';
import { KPICard, ChartHeader, ChartRenderer } from './components';

export function TabInicio() {
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

  // Stable callbacks for KPI changes (prevents re-renders)
  const handleKPI0Change = useCallback((v: KPIType) => updateKPI(0, v), [updateKPI]);
  const handleKPI1Change = useCallback((v: KPIType) => updateKPI(1, v), [updateKPI]);
  const handleKPI2Change = useCallback((v: KPIType) => updateKPI(2, v), [updateKPI]);

  // Photo gallery state - using real site photos with ISE
  const [showGallery, setShowGallery] = useState(false);
  const [selectedPhotoIndex, setSelectedPhotoIndex] = useState<number | null>(null);
  const [localFotos, setLocalFotos] = useState<SitePhotoWithISE[]>(() => sitePhotosGallery);

  // Photo selection handler
  const handlePhotoSelect = (foto: { url: string; sitio: string }) => {
    if (selectedPhotoIndex !== null) {
      const currentPhoto = localFotos[selectedPhotoIndex];
      const newFotos = [...localFotos];
      newFotos[selectedPhotoIndex] = {
        ...currentPhoto,
        url: foto.url,
        siteName: foto.sitio,
      };
      setLocalFotos(newFotos);
    }
    setSelectedPhotoIndex(null);
  };

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* KPI Cards Section */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <KPICard value={kpi1} onChange={handleKPI0Change} usedKPIs={usedKPIs} />
        <KPICard value={kpi2} onChange={handleKPI1Change} usedKPIs={usedKPIs} />
        <KPICard value={kpi3} onChange={handleKPI2Change} usedKPIs={usedKPIs} />
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
            placeholder="Ingrese una observación general del monitoreo…"
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
            {localFotos.map((foto, index) => {
              // ISE color based on score
              const iseColor = foto.ise >= 60 ? '#22c55e' : foto.ise >= 40 ? '#eab308' : foto.ise >= 20 ? '#f97316' : '#ef4444';

              return (
                <div key={foto.siteId} className="group">
                  {/* Photo with real image */}
                  {isEditing ? (
                    <button
                      type="button"
                      className="aspect-video w-full bg-gray-100 rounded-lg relative overflow-hidden cursor-pointer hover:ring-2 hover:ring-[var(--grass-green)] transition-all"
                      onClick={() => {
                        setSelectedPhotoIndex(index);
                        setShowGallery(true);
                      }}
                      aria-label={`Cambiar foto de ${foto.siteName}`}
                    >
                      <img
                        src={foto.url}
                        alt={`Sitio ${foto.siteName}`}
                        className="w-full h-full object-cover"
                      />
                      {/* Edit overlay */}
                      <div className="absolute inset-0 bg-black/0 group-hover:bg-black/40 flex items-center justify-center transition-colors">
                        <Camera className="w-6 h-6 text-white opacity-0 group-hover:opacity-100 transition-opacity" aria-hidden="true" />
                      </div>
                    </button>
                  ) : (
                    <div className="aspect-video bg-gray-100 rounded-lg relative overflow-hidden">
                      <img
                        src={foto.url}
                        alt={`Sitio ${foto.siteName}`}
                        className="w-full h-full object-cover"
                      />
                    </div>
                  )}
                  {/* Photo caption with site name and ISE */}
                  <div className="mt-2">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium text-[var(--grass-green-dark)]">{foto.siteName}</p>
                      <span
                        className="text-xs font-semibold px-1.5 py-0.5 rounded"
                        style={{ backgroundColor: `${iseColor}20`, color: iseColor }}
                      >
                        ISE {foto.ise}
                      </span>
                    </div>
                    <p className="text-xs text-gray-400 mb-1">{foto.estrato}</p>
                    <EditableText
                      value={editableContent[`foto_comentario_${index}`] || ''}
                      onChange={(value) => updateContent(`foto_comentario_${index}`, value)}
                      placeholder="Agregar comentario…"
                      className="text-xs text-gray-500"
                    />
                  </div>
                </div>
              );
            })}
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
