// Re-exports from official ProseMirror packages to replace @kirvano/prosemirror-schema
export { schema } from 'prosemirror-schema-basic';
export { 
  EditorState,
  Plugin,
  PluginKey,
  Transaction 
} from 'prosemirror-state';
export { 
  EditorView,
  Decoration,
  DecorationSet 
} from 'prosemirror-view';
export {
  Node,
  Fragment,
  Slice,
  Mark,
  Schema,
  NodeType,
  MarkType
} from 'prosemirror-model';

// Common utilities that might have been in the @kirvano package
export function createEditor(place, options = {}) {
  const state = EditorState.create({
    schema: options.schema || schema,
    plugins: options.plugins || []
  });
  
  return new EditorView(place, {
    state,
    ...options
  });
}

// Image paste plugin stub (would need to be implemented)
export const imagePastePlugin = new Plugin({
  key: new PluginKey('imagePaste'),
  props: {
    handlePaste(view, event, slice) {
      // Basic image paste handling
      return false;
    }
  }
});

// Mentions plugin stub  
export const mentionsPlugin = {
  plugin: new Plugin({
    key: new PluginKey('mentions'),
    props: {
      handleKeyDown(view, event) {
        return false;
      }
    }
  })
}; 