// Image paste plugin for ProseMirror
import { Plugin, PluginKey } from 'prosemirror-state';

const imagePluginKey = new PluginKey('imagePaste');

export default new Plugin({
  key: imagePluginKey,
  
  props: {
    handlePaste(view, event, slice) {
      // Basic image paste handling
      const items = Array.from(event.clipboardData?.items || []);
      
      for (const item of items) {
        if (item.type.indexOf('image') === 0) {
          event.preventDefault();
          
          const file = item.getAsFile();
          if (file) {
            // In a real implementation, this would upload the image and insert it
            console.log('Image pasted:', file.name);
            
            // For now, just prevent the default paste behavior
            return true;
          }
        }
      }
      
      return false;
    },
    
    handleDrop(view, event, slice, moved) {
      // Basic image drop handling
      const files = Array.from(event.dataTransfer?.files || []);
      
      for (const file of files) {
        if (file.type.indexOf('image') === 0) {
          event.preventDefault();
          
          // In a real implementation, this would upload the image and insert it
          console.log('Image dropped:', file.name);
          
          return true;
        }
      }
      
      return false;
    }
  }
});

export { imagePluginKey }; 