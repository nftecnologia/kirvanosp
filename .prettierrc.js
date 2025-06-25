module.exports = {
  // Basic formatting rules
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 120,
  tabWidth: 2,
  useTabs: false,
  
  // Vue-specific formatting
  vueIndentScriptAndStyle: false,
  
  // Override rules for specific file types
  overrides: [
    {
      files: '*.vue',
      options: {
        parser: 'vue',
        singleQuote: true,
        semi: true,
      },
    },
    {
      files: '*.scss',
      options: {
        parser: 'scss',
        singleQuote: true,
      },
    },
    {
      files: '*.json',
      options: {
        parser: 'json',
        printWidth: 80,
      },
    },
    {
      files: '*.md',
      options: {
        parser: 'markdown',
        printWidth: 100,
        proseWrap: 'always',
      },
    },
  ],
};