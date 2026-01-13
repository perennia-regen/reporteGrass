import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center max-w-md px-4">
        <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
          <span className="text-3xl font-bold text-gray-400">404</span>
        </div>
        <h2 className="text-xl font-semibold text-gray-900 mb-2">
          Página no encontrada
        </h2>
        <p className="text-gray-600 mb-6">
          El recurso que buscas no existe o ha sido movido.
        </p>
        <Link
          href="/"
          className="inline-block px-4 py-2 bg-[var(--grass-green)] text-white rounded-lg hover:bg-[var(--grass-green-dark)] transition-colors"
        >
          Volver al inicio
        </Link>
      </div>
    </div>
  );
}
