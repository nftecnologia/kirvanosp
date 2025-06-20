// Re-exports from official ProseMirror packages to replace @kirvano/prosemirror-schema
import { schema as basicSchema } from 'prosemirror-schema-basic';
export { schema } from 'prosemirror-schema-basic';
export { 
  EditorState,
  Plugin,
  PluginKey,
  Transaction,
  Selection 
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
export { MarkdownParser, MarkdownSerializer } from 'prosemirror-markdown';

// Export messageSchema as alias for basic schema
export const messageSchema = basicSchema;

// Export fullSchema as alias for basic schema
export const fullSchema = basicSchema;

// Basic markdown transformer implementation
export class MessageMarkdownTransformer {
  constructor(schema) {
    this.schema = schema;
    this.parser = new MarkdownParser(schema, {
      blockquote: { block: "blockquote" },
      paragraph: { block: "paragraph" },
      list_item: { block: "list_item" },
      bullet_list: { block: "bullet_list" },
      ordered_list: { block: "ordered_list" },
      heading: { block: "heading", getAttrs: token => ({ level: +token.attrGet("level") || 1 }) },
      code_block: { block: "code_block" },
      hard_break: { node: "hard_break" },
    }, {
      em: { mark: "em" },
      strong: { mark: "strong" },
      code: { mark: "code" },
    });
  }

  parse(markdown) {
    return this.parser.parse(markdown);
  }
}

// Basic markdown serializer implementation  
export class MessageMarkdownSerializer {
  static serialize(doc) {
    const serializer = new MarkdownSerializer({
      blockquote: (state, node) => {
        state.wrapBlock("> ", null, node, () => state.renderContent(node));
      },
      code_block: (state, node) => {
        state.write("```\n");
        state.text(node.textContent);
        state.write("\n```");
        state.closeBlock(node);
      },
      heading: (state, node) => {
        state.write("#".repeat(node.attrs.level) + " ");
        state.renderInline(node);
        state.closeBlock(node);
      },
      horizontal_rule: (state, node) => {
        state.write("---");
        state.closeBlock(node);
      },
      bullet_list: (state, node) => {
        state.renderList(node, "  ", () => "* ");
      },
      ordered_list: (state, node) => {
        let start = node.attrs.order || 1;
        let maxW = String(start + node.childCount - 1).length;
        let space = " ".repeat(maxW + 2);
        state.renderList(node, space, i => {
          let nStr = String(start + i);
          return nStr + ". " + " ".repeat(maxW - nStr.length);
        });
      },
      list_item: (state, node) => {
        state.renderContent(node);
      },
      paragraph: (state, node) => {
        state.renderInline(node);
        state.closeBlock(node);
      },
      hard_break: (state) => {
        state.write("\\\n");
      },
    }, {
      em: { open: "*", close: "*" },
      strong: { open: "**", close: "**" },
      code: { open: "`", close: "`" },
    });
    
    return serializer.serialize(doc);
  }
}

// Article markdown transformer (for articles/knowledge base)
export class ArticleMarkdownTransformer {
  constructor(schema) {
    this.schema = schema;
    this.parser = new MarkdownParser(schema, {
      blockquote: { block: "blockquote" },
      paragraph: { block: "paragraph" },
      list_item: { block: "list_item" },
      bullet_list: { block: "bullet_list" },
      ordered_list: { block: "ordered_list" },
      heading: { block: "heading", getAttrs: token => ({ level: +token.attrGet("level") || 1 }) },
      code_block: { block: "code_block" },
      hard_break: { node: "hard_break" },
    }, {
      em: { mark: "em" },
      strong: { mark: "strong" },
      code: { mark: "code" },
    });
  }

  parse(markdown) {
    return this.parser.parse(markdown);
  }
}

// Article markdown serializer (alias for MessageMarkdownSerializer for now)
export const ArticleMarkdownSerializer = MessageMarkdownSerializer;

// Common utilities that might have been in the @kirvano package
export function createEditor(place, options = {}) {
  const state = EditorState.create({
    schema: options.schema || basicSchema,
    plugins: options.plugins || []
  });
  
  return new EditorView(place, {
    state,
    ...options
  });
}

// buildEditor as alias for createEditor
export const buildEditor = createEditor;

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