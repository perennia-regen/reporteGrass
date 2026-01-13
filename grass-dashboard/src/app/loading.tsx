export default function Loading() {
  return (
    <div className="h-screen flex items-center justify-center bg-gray-50">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 border-4 border-[var(--grass-green)] border-t-transparent rounded-full animate-spin" />
        <p className="text-sm text-gray-500">Cargando dashboard...</p>
      </div>
    </div>
  );
}
