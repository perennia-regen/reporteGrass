'use client';

import dynamic from 'next/dynamic';
import { ChartLoading } from './ChartLoading';

// Dynamic import of ChartByType with loading state
const ChartByType = dynamic(
  () => import('@/components/layout/ChartPreviewModal').then((mod) => mod.ChartByType),
  {
    loading: () => <ChartLoading />,
    ssr: false,
  }
);

// Dynamic import of ChartPreviewModal
const ChartPreviewModal = dynamic(
  () => import('@/components/layout/ChartPreviewModal').then((mod) => mod.ChartPreviewModal),
  {
    loading: () => null,
    ssr: false,
  }
);

export { ChartByType, ChartPreviewModal };
