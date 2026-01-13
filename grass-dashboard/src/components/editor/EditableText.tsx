'use client';

import { useState, useRef, useEffect } from 'react';
import { useDashboardStore } from '@/lib/dashboard-store';
import { Textarea } from '@/components/ui/textarea';

interface EditableTextProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  multiline?: boolean;
}

export function EditableText({
  value,
  onChange,
  placeholder = 'Click para editar...',
  className = '',
  multiline = false,
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

  if (!isEditing) {
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
          className={`min-h-[100px] ${className}`}
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
        className={`w-full px-2 py-1 border rounded focus:outline-none focus:ring-2 focus:ring-[var(--grass-green)] ${className}`}
        placeholder={placeholder}
      />
    );
  }

  return (
    <span
      className={`cursor-text hover:bg-yellow-50 px-1 -mx-1 rounded transition-colors ${className}`}
      onClick={() => setIsLocalEditing(true)}
      title="Click para editar"
    >
      {value || <span className="text-gray-400 italic">{placeholder}</span>}
      <svg
        className="inline-block w-3 h-3 ml-1 text-gray-400"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={2}
          d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
        />
      </svg>
    </span>
  );
}
