export const isEnter = e => {
  return e.key === 'Enter';
};

export const isEscape = e => {
  return e.key === 'Escape';
};

export const hasPressedShift = e => {
  return e.shiftKey;
};

export const hasPressedCommand = e => {
  return e.metaKey;
};

export const hasPressedEnterAndNotCmdOrShift = e => {
  return isEnter(e) && !hasPressedCommand(e) && !hasPressedShift(e);
};

export const hasPressedCommandAndEnter = e => {
  return hasPressedCommand(e) && isEnter(e);
};

// If layout is QWERTZ then we add the Shift+keysToModify to fix an known issue
// https://github.com/kirvano/kirvano/issues/9492
export const keysToModifyInQWERTZ = new Set(['Alt+KeyP', 'Alt+KeyL']);

export const LAYOUT_QWERTY = 'QWERTY';
export const LAYOUT_QWERTZ = 'QWERTZ';
export const LAYOUT_AZERTY = 'AZERTY';

/**
 * Determines whether the active element is typeable.
 *
 * @param {KeyboardEvent} e - The keyboard event object.
 * @returns {boolean} `true` if the active element is typeable, `false` otherwise.
 *
 * @example
 * document.addEventListener('keydown', e => {
 *   if (isActiveElementTypeable(e)) {
 *     handleTypeableElement(e);
 *   }
 * });
 */
export const isActiveElementTypeable = e => {
  /** @type {HTMLElement | null} */
  // @ts-ignore
  const activeElement = e.target || document.activeElement;

  return !!(
    activeElement?.tagName === 'INPUT' ||
    activeElement?.tagName === 'NINJA-KEYS' ||
    activeElement?.tagName === 'TEXTAREA' ||
    activeElement?.contentEditable === 'true' ||
    activeElement?.className?.includes('ProseMirror')
  );
};
