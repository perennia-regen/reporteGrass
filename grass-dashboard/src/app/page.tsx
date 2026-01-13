'use client';

import { Header } from '@/components/layout/Header';
import { Sidebar } from '@/components/layout/Sidebar';
import { Canvas } from '@/components/layout/Canvas';

export default function Home() {
  return (
    <div className="h-screen flex flex-col overflow-hidden">
      <Header />
      <div className="flex flex-1 overflow-hidden relative">
        <Sidebar />
        <Canvas />
      </div>
    </div>
  );
}
