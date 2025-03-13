import React, { useState, cloneElement, forwardRef } from 'react';
import {
  useFloating,
  autoUpdate,
  offset,
  shift,
  autoPlacement,
  useHover,
  useFocus,
  useDismiss,
  useRole,
  useInteractions,
  FloatingPortal,
} from '@floating-ui/react';

// Use className to override default styles
const Tooltip = ({
  width = 'max-w-56',
  className = 'bg-gray-700 text-white text-xs rounded p-2',
  children,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const { refs, floatingStyles, context } = useFloating({
    open: isOpen,
    onOpenChange: setIsOpen,
    placement: 'bottom',
    whileElementsMounted: autoUpdate,
    middleware: [
      offset(5),
      autoPlacement({
        fallbackAxisSideDirection: 'start',
      }),
      shift(),
    ],
  });

  // https://floating-ui.com/docs/useInteractions
  const hover = useHover(context, { move: false });
  const focus = useFocus(context);
  const dismiss = useDismiss(context);
  const role = useRole(context, { role: 'tooltip' });

  const { getReferenceProps, getFloatingProps } = useInteractions([hover, focus, dismiss, role]);

  const trigger = React.Children.toArray(children).find((child) => child.type === TooltipButton);
  const content = React.Children.toArray(children).find((child) => child.type === TooltipPanel);

  return (
    <>
      {trigger && (
        <div ref={refs.setReference} {...getReferenceProps()} className="relative">
          {cloneElement(trigger, { ref: refs.setReference })}
        </div>
      )}

      <FloatingPortal>
        {isOpen && content && (
          <div
            className={`${width} ${className}`}
            ref={refs.setFloating}
            style={floatingStyles}
            {...getFloatingProps()}
          >
            {content}
          </div>
        )}
      </FloatingPortal>
    </>
  );
};

const TooltipButton = forwardRef(({ children, ...props }, ref) => {
  return (
    <button ref={ref} {...props}>
      {children}
    </button>
  );
});
TooltipButton.displayName = 'TooltipButton';

const TooltipPanel = ({ children, ...props }) => {
  return <div {...props}>{children}</div>;
};

export { Tooltip, TooltipButton, TooltipPanel };
