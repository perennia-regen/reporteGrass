'use client';

import { useState } from 'react';
import { Eye } from 'lucide-react';
import { ChartByType, ChartPreviewModal } from '@/components/charts/DynamicChartByType';

interface ChartThumbnailProps {
  chartType: string;
  title: string;
  showAxes?: boolean;
}

export function ChartThumbnail({ chartType, title, showAxes = true }: ChartThumbnailProps) {
  const [isHovered, setIsHovered] = useState(false);
  const [showModal, setShowModal] = useState(false);

  return (
    <>
      <div
        className="relative w-full h-[120px] bg-white rounded border border-gray-200 overflow-hidden cursor-pointer"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {/* Mini chart - showAxes determina si se muestra en modo compacto o con ejes visibles */}
        <div className="w-full h-full p-1 pointer-events-none">
          <ChartByType chartType={chartType} showLabels={false} compact={!showAxes} />
        </div>

        {/* Hover overlay with eye icon */}
        {isHovered && (
          <div
            className="absolute inset-0 bg-black/40 flex items-center justify-center transition-opacity"
            onClick={() => setShowModal(true)}
          >
            <button
              className="p-2 bg-white rounded-full shadow-lg hover:bg-gray-100 transition-colors"
              onClick={(e) => {
                e.stopPropagation();
                setShowModal(true);
              }}
            >
              <Eye className="w-5 h-5 text-gray-700" />
            </button>
          </div>
        )}
      </div>

      {/* Preview Modal */}
      <ChartPreviewModal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        chartType={chartType}
        title={title}
      />
    </>
  );
}
