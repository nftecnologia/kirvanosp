// Mentions plugin for ProseMirror
import { Plugin, PluginKey } from 'prosemirror-state';
import { Decoration, DecorationSet } from 'prosemirror-view';

const mentionPluginKey = new PluginKey('mentions');

export const mentionsPlugin = new Plugin({
  key: mentionPluginKey,
  
  state: {
    init() {
      return DecorationSet.empty;
    },
    
    apply(tr, decorationSet) {
      // Simple implementation - just return empty decorations for now
      return DecorationSet.empty;
    }
  },
  
  props: {
    decorations(state) {
      return this.getState(state);
    },
    
    handleKeyDown(view, event) {
      // Handle @ key for mentions
      if (event.key === '@') {
        // In a real implementation, this would trigger mention suggestions
        console.log('Mention trigger detected');
      }
      return false;
    }
  }
});

export { mentionPluginKey }; 