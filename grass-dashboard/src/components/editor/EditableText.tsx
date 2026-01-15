'use client';

import { useState, useRef, useEffect } from 'react';
import { useDashboardStore } from '@/lib/dashboard-store';
import { Textarea } from '@/components/ui/textarea';
import { Pencil } from 'lucide-react';
import { cn } from '@/lib/utils';

interface EditableTextProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  multiline?: boolean;
  showPencilOnHover?: boolean;
}

export function EditableText({
  value,
  onChange,
  placeholder = 'Click para editar…',
  className = '',
  multiline = false,
  showPencilOnHover = false,
}: EditableTextProps) {
  const { isEditing } = useDashboardStore();
  const [isLocalEditing, setIsLocalEditing] = useState(false);
  const [localValue, setLocalValue] = useState(value);
  const inputRef = useRef<HTMLTextAreaElement | HTMLInputElement>(null);

  useEffect(() => {
    setLocalValue(value);
  }, [value]);

  useEffect(() => {
    if (isLocalEditing && inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select();
    }
  }, [isLocalEditing]);

  const handleBlur = () => {
    setIsLocalEditing(false);
    if (localValue !== value) {
      onChange(localValue);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setLocalValue(value);
      setIsLocalEditing(false);
    }
    if (e.key === 'Enter' && !multiline) {
      handleBlur();
    }
  };

  // Modo lectura - sin edición global activa
  if (!isEditing) {
    // Si showPencilOnHover está activo, mostrar lápiz centrado al hover
    if (showPencilOnHover) {
      return (
        <div
          className={cn('relative group cursor-pointer', className)}
          onClick={() => {
            // Activar modo edición global y local
            useDashboardStore.getState().setIsEditing(true);
            setIsLocalEditing(true);
          }}
        >
          <span>{value || <span className="text-gray-400 italic">{placeholder}</span>}</span>
          <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity bg-white/80 rounded">
            <Pencil className="w-4 h-4 text-gray-500" />
          </div>
        </div>
      );
    }
    return <span className={className}>{value || placeholder}</span>;
  }

  if (isLocalEditing) {
    if (multiline) {
      return (
        <Textarea
          ref={inputRef as React.RefObject<HTMLTextAreaElement>}
          value={localValue}
          onChange={(e) => setLocalValue(e.target.value)}
          onBlur={handleBlur}
          onKeyDown={handleKeyDown}
          className={cn('min-h-[100px] border-[var(--grass-green)] ring-2 ring-[var(--grass-green)]/20', className)}
          placeholder={placeholder}
        />
      );
    }

    return (
      <input
        ref={inputRef as React.RefObject<HTMLInputElement>}
        type="text"
        value={localValue}
        onChange={(e) => setLocalValue(e.target.value)}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        className={cn(
          'w-full px-2 py-1 border border-[var(--grass-green)] rounded focus:outline-none focus:ring-2 focus:ring-[var(--grass-green)]',
          className
        )}
        placeholder={placeholder}
      />
    );
  }

  return (
    <span
      data-tour="editable-text"
      className={cn(
        'cursor-text relative group inline-block',
        'border border-dashed border-amber-300 bg-amber-50/50 rounded px-2 py-1 -mx-1',
        'hover:border-amber-400 hover:bg-amber-50 transition-all',
        className
      )}
      onClick={() => setIsLocalEditing(true)}
      title="Haz click para editar este texto"
    >
      {value || <span className="text-gray-400 italic">{placeholder}</span>}
      <span
        className={cn(
          'inline-flex items-center justify-center',
          'ml-2 w-5 h-5 rounded bg-amber-200 text-amber-700',
          'group-hover:bg-amber-300 transition-colors'
        )}
      >
        <Pencil className="w-3 h-3" />
      </span>
    </span>
  );
}
