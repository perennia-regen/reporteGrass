'use client';

import { useState } from 'react';
import { Plus, X, MapPin } from 'lucide-react';
import { PhotoGalleryModal } from '@/components/PhotoGalleryModal';
import { useIsEditing, useEditableContent, useUpdateContent } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import type { CustomSectionPhoto, CustomSectionItem } from '@/types/dashboard';

interface PhotoGalleryWidgetProps {
  item: CustomSectionItem;
  onUpdatePhotos: (photos: CustomSectionPhoto[]) => void;
}

const MAX_PHOTOS = 4;

export function PhotoGalleryWidget({ item, onUpdatePhotos }: PhotoGalleryWidgetProps) {
  const isEditing = useIsEditing();
  const editableContent = useEditableContent();
  const updateContent = useUpdateContent();
  const [showGallery, setShowGallery] = useState(false);
  const [editingSlot, setEditingSlot] = useState<number | null>(null);

  const photos = item.photos || [];

  const handleSelectPhoto = (foto: { url: string; sitio: string; ise?: number; estrato?: string }) => {
    const newPhoto: CustomSectionPhoto = {
      url: foto.url,
      sitio: foto.sitio,
      ise: foto.ise,
      estrato: foto.estrato,
    };

    let newPhotos: CustomSectionPhoto[];
    if (editingSlot !== null && editingSlot < photos.length) {
      // Reemplazar foto existente
      newPhotos = [...photos];
      newPhotos[editingSlot] = newPhoto;
    } else {
      // Agregar nueva foto
      newPhotos = [...photos, newPhoto];
    }
    onUpdatePhotos(newPhotos);
    setEditingSlot(null);
  };

  const handleRemovePhoto = (index: number) => {
    const newPhotos = photos.filter((_, i) => i !== index);
    onUpdatePhotos(newPhotos);
  };

  const openGalleryForSlot = (slotIndex: number) => {
    setEditingSlot(slotIndex);
    setShowGallery(true);
  };

  // Calcular slots disponibles (siempre mostrar grid 2x2 o menos)
  const slots = [];
  for (let i = 0; i < MAX_PHOTOS; i++) {
    if (i < photos.length) {
      slots.push({ type: 'photo' as const, photo: photos[i], index: i });
    } else if (i === photos.length && isEditing && photos.length < MAX_PHOTOS) {
      slots.push({ type: 'add' as const, index: i });
    }
  }

  // Si no hay fotos y estamos en modo edición, mostrar un slot de agregar
  if (slots.length === 0 && isEditing) {
    slots.push({ type: 'add' as const, index: 0 });
  }

  // En modo lectura sin fotos, mostrar placeholder
  if (slots.length === 0 && !isEditing) {
    return (
      <div className="h-32 flex items-center justify-center bg-gray-50 rounded-lg text-gray-400 text-sm">
        No hay fotos agregadas
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {/* Grid de fotos 2x2 */}
      <div className={`grid gap-2 ${slots.length === 1 ? 'grid-cols-1' : 'grid-cols-2'}`}>
        {slots.map((slot, idx) => (
          <div key={idx} className="relative aspect-video">
            {slot.type === 'photo' ? (
              <div className="relative group w-full h-full">
                {isEditing ? (
                  <button
                    type="button"
                    onClick={() => openGalleryForSlot(slot.index)}
                    className="w-full h-full"
                    aria-label={`Cambiar foto de ${slot.photo.sitio}`}
                  >
                    <img
                      src={slot.photo.url}
                      alt={`Sitio ${slot.photo.sitio}`}
                      className="w-full h-full object-cover rounded-lg cursor-pointer"
                    />
                  </button>
                ) : (
                  <img
                    src={slot.photo.url}
                    alt={`Sitio ${slot.photo.sitio}`}
                    className="w-full h-full object-cover rounded-lg"
                  />
                )}
                {/* Overlay con info */}
                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-2 rounded-b-lg">
                  <p className="text-white text-xs font-medium truncate">{slot.photo.sitio}</p>
                  {slot.photo.estrato && (
                    <div className="flex items-center gap-1 text-white/80 text-xs">
                      <MapPin className="w-3 h-3" />
                      <span>{slot.photo.estrato}</span>
                    </div>
                  )}
                </div>
                {/* Botón eliminar */}
                {isEditing && (
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleRemovePhoto(slot.index);
                    }}
                    className="absolute top-1 right-1 p-1 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
                    aria-label={`Eliminar foto de ${slot.photo.sitio}`}
                  >
                    <X className="w-3 h-3" aria-hidden="true" />
                  </button>
                )}
              </div>
            ) : (
              // Slot para agregar foto
              <button
                onClick={() => openGalleryForSlot(slot.index)}
                className="w-full h-full flex flex-col items-center justify-center bg-gray-100 hover:bg-gray-200 border-2 border-dashed border-gray-300 hover:border-[var(--grass-green)] rounded-lg transition-colors"
              >
                <Plus className="w-6 h-6 text-gray-400" />
                <span className="text-xs text-gray-500 mt-1">Agregar foto</span>
              </button>
            )}
          </div>
        ))}
      </div>

      {/* Comentario editable */}
      <EditableText
        value={editableContent[`photo_gallery_comment_${item.id}`] || ''}
        onChange={(value) => updateContent(`photo_gallery_comment_${item.id}`, value)}
        placeholder="Agregar un comentario sobre las fotos..."
        className="text-xs text-gray-500"
        showPencilOnHover
        multiline
      />

      {/* Modal de galería */}
      <PhotoGalleryModal
        isOpen={showGallery}
        onClose={() => {
          setShowGallery(false);
          setEditingSlot(null);
        }}
        onSelect={handleSelectPhoto}
        currentPhotoUrl={editingSlot !== null && editingSlot < photos.length ? photos[editingSlot].url : undefined}
      />
    </div>
  );
}
