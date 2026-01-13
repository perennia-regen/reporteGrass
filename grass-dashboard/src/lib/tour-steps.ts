// Pasos del tour guiado para técnicos

export interface TourStep {
  target: string; // data-tour attribute selector
  title: string;
  content: string;
  placement: 'top' | 'bottom' | 'left' | 'right' | 'center';
}

export const tourSteps: TourStep[] = [
  {
    target: 'body',
    title: 'Bienvenido al Editor de Informes',
    content:
      'Este es el modo de previsualización donde puedes personalizar el informe antes de enviarlo al productor. Lo que ves aquí es como se verá el informe final.',
    placement: 'center',
  },
  {
    target: '[data-tour="sidebar"]',
    title: 'Componentes Disponibles',
    content:
      'Aquí encontrarás todos los componentes que puedes agregar al informe: gráficos, tablas, bloques de texto y más. Solo tienes que arrastrarlos al área de contenido.',
    placement: 'right',
  },
  {
    target: '[data-tour="canvas"]',
    title: 'Área de Contenido',
    content:
      'Arrastra los componentes desde la barra lateral y suéltalos aquí para agregarlos al informe. Puedes reordenarlos y redimensionarlos.',
    placement: 'left',
  },
  {
    target: '[data-tour="editable-text"]',
    title: 'Textos Editables',
    content:
      'Los textos con el icono de lápiz son editables. Haz click para modificar observaciones, comentarios y recomendaciones.',
    placement: 'bottom',
  },
  {
    target: '[data-tour="share-button"]',
    title: 'Compartir con el Productor',
    content:
      'Cuando termines de editar, usa este botón para generar un link y compartirlo con el productor. El productor verá una versión limpia sin las herramientas de edición.',
    placement: 'bottom',
  },
];
