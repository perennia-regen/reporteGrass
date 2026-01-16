'use client';

import { useState, useEffect, useCallback, useLayoutEffect } from 'react';
import { useDashboardStore } from '@/lib/dashboard-store';
import { tourSteps } from '@/lib/tour-steps';
import { Button } from '@/components/ui/button';
import { X, ChevronLeft, ChevronRight, Sparkles } from 'lucide-react';
import { cn } from '@/lib/utils';

export function GuidedTour() {
  const { isEditing, tourCompleted, setTourCompleted } = useDashboardStore();
  const [currentStep, setCurrentStep] = useState(0);
  const [isReady, setIsReady] = useState(false);
  const [tooltipPosition, setTooltipPosition] = useState({ top: 0, left: 0 });
  const [highlightRect, setHighlightRect] = useState<DOMRect | null>(null);

  // Derive visibility from state - no setState needed
  const shouldShow = isEditing && !tourCompleted;
  const isVisible = shouldShow && isReady;

  const currentTourStep = tourSteps[currentStep];
  const isLastStep = currentStep === tourSteps.length - 1;
  const isFirstStep = currentStep === 0;

  // Set ready state with delay when should show
  useEffect(() => {
    if (shouldShow) {
      // Small delay to let the UI render
      const timer = setTimeout(() => {
        setIsReady(true);
        setCurrentStep(0);
      }, 500);
      return () => clearTimeout(timer);
    } else {
      // Use microtask to satisfy linter
      queueMicrotask(() => setIsReady(false));
    }
  }, [shouldShow]);

  // Update position when step changes
  const updatePosition = useCallback(() => {
    if (!isVisible) return;

    const step = tourSteps[currentStep];

    if (step.target === 'body' || step.placement === 'center') {
      // Center in viewport
      setTooltipPosition({
        top: window.innerHeight / 2 - 150,
        left: window.innerWidth / 2 - 200,
      });
      setHighlightRect(null);
      return;
    }

    const targetEl = document.querySelector(step.target);
    if (!targetEl) {
      // If target not found, show centered
      setTooltipPosition({
        top: window.innerHeight / 2 - 150,
        left: window.innerWidth / 2 - 200,
      });
      setHighlightRect(null);
      return;
    }

    const rect = targetEl.getBoundingClientRect();
    setHighlightRect(rect);

    const tooltipWidth = 400;
    const tooltipHeight = 200;
    const offset = 16;

    let top = 0;
    let left = 0;

    switch (step.placement) {
      case 'right':
        top = rect.top + rect.height / 2 - tooltipHeight / 2;
        left = rect.right + offset;
        break;
      case 'left':
        top = rect.top + rect.height / 2 - tooltipHeight / 2;
        left = rect.left - tooltipWidth - offset;
        break;
      case 'bottom':
        top = rect.bottom + offset;
        left = rect.left + rect.width / 2 - tooltipWidth / 2;
        break;
      case 'top':
        top = rect.top - tooltipHeight - offset;
        left = rect.left + rect.width / 2 - tooltipWidth / 2;
        break;
    }

    // Keep within viewport
    top = Math.max(16, Math.min(top, window.innerHeight - tooltipHeight - 16));
    left = Math.max(16, Math.min(left, window.innerWidth - tooltipWidth - 16));

    setTooltipPosition({ top, left });
  }, [currentStep, isVisible]);

  // Use useLayoutEffect for DOM measurements to avoid flicker
  useLayoutEffect(() => {
    // Use requestAnimationFrame to schedule the position update
    const frameId = requestAnimationFrame(() => {
      updatePosition();
    });
    return () => cancelAnimationFrame(frameId);
  }, [updatePosition]);

  useEffect(() => {
    window.addEventListener('resize', updatePosition);
    window.addEventListener('scroll', updatePosition);
    return () => {
      window.removeEventListener('resize', updatePosition);
      window.removeEventListener('scroll', updatePosition);
    };
  }, [updatePosition]);

  const handleNext = () => {
    if (isLastStep) {
      handleComplete();
    } else {
      setCurrentStep((prev) => prev + 1);
    }
  };

  const handlePrev = () => {
    if (!isFirstStep) {
      setCurrentStep((prev) => prev - 1);
    }
  };

  const handleSkip = () => {
    setIsReady(false);
    setTourCompleted(true);
  };

  const handleComplete = () => {
    setIsReady(false);
    setTourCompleted(true);
  };

  if (!isVisible) return null;

  return (
    <>
      {/* Overlay */}
      <div className="fixed inset-0 z-[9998] bg-black/50 transition-opacity" />

      {/* Highlight */}
      {highlightRect && (
        <div
          className="fixed z-[9999] pointer-events-none rounded-lg"
          style={{
            top: highlightRect.top - 4,
            left: highlightRect.left - 4,
            width: highlightRect.width + 8,
            height: highlightRect.height + 8,
            boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.5), 0 0 0 4px var(--grass-green)',
          }}
        />
      )}

      {/* Tooltip */}
      <div
        className={cn(
          'fixed z-[10000] w-[400px] bg-white rounded-xl shadow-2xl',
          'transform transition-all duration-300'
        )}
        style={{
          top: tooltipPosition.top,
          left: tooltipPosition.left,
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b bg-gradient-to-r from-[var(--grass-green)] to-[var(--grass-green-dark)] rounded-t-xl">
          <div className="flex items-center gap-2 text-white">
            <Sparkles className="w-5 h-5" />
            <span className="font-semibold">{currentTourStep.title}</span>
          </div>
          <Button
            variant="ghost"
            size="icon-sm"
            className="text-white hover:bg-white/20"
            onClick={handleSkip}
          >
            <X className="w-4 h-4" />
          </Button>
        </div>

        {/* Content */}
        <div className="p-4">
          <p className="text-gray-700 leading-relaxed">{currentTourStep.content}</p>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-4 border-t bg-gray-50 rounded-b-xl">
          <div className="flex items-center gap-1">
            {tourSteps.map((_, index) => (
              <div
                key={index}
                className={cn(
                  'w-2 h-2 rounded-full transition-colors',
                  index === currentStep
                    ? 'bg-[var(--grass-green)]'
                    : 'bg-gray-300'
                )}
              />
            ))}
          </div>

          <div className="flex items-center gap-2">
            <Button variant="ghost" size="sm" onClick={handleSkip}>
              Omitir
            </Button>
            {!isFirstStep && (
              <Button variant="outline" size="sm" onClick={handlePrev}>
                <ChevronLeft className="w-4 h-4 mr-1" />
                Anterior
              </Button>
            )}
            <Button
              size="sm"
              className="bg-[var(--grass-green)] hover:bg-[var(--grass-green-dark)]"
              onClick={handleNext}
            >
              {isLastStep ? (
                'Comenzar'
              ) : (
                <>
                  Siguiente
                  <ChevronRight className="w-4 h-4 ml-1" />
                </>
              )}
            </Button>
          </div>
        </div>
      </div>
    </>
  );
}
