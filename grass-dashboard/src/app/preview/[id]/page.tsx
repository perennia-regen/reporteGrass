import type { Metadata } from 'next';
import PreviewClient from './preview-client';

type PageProps = {
  params: Promise<{ id: string }>;
};

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;

  return {
    title: `Preview ${id} | Dashboard GRASS`,
    description: 'Vista previa del informe de monitoreo ambiental GRASS',
    openGraph: {
      title: `Informe de Monitoreo GRASS`,
      description: 'Vista previa del informe de monitoreo ambiental',
      type: 'website',
    },
  };
}

export default async function PreviewPage({ params }: PageProps) {
  const { id } = await params;

  return <PreviewClient id={id} />;
}
