/// <reference types="vitest" />

/**
What's going on with library mode?

Glad you asked, here's a quick rundown:

1. vite-plugin-ruby will automatically bring all the entrypoints like dashbord and widget as input to vite.
2. vite needs to be in library mode to build the SDK as a single file. (UMD) format and set `inlineDynamicImports` to true.
3. But when setting `inlineDynamicImports` to true, vite will not be able to handle mutliple entrypoints.

This puts us in a deadlock, now there are two ways around this, either add another separate build pipeline to
the app using vanilla rollup or rspack or something. The second option is to remove sdk building from the main pipeline
and build it separately using Vite itself, toggled by an ENV variable.

`BUILD_MODE=library bin/vite build` should build only the SDK and save it to `public/packs/js/sdk.js`
`bin/vite build` will build the rest of the app as usual. But exclude the SDK.

We need to edit the `asset:precompile` rake task to include the SDK in the precompile list.
*/
import { defineConfig } from 'vite';
import ruby from 'vite-plugin-ruby';
import path from 'path';
import vue from '@vitejs/plugin-vue';

const isLibraryMode = process.env.BUILD_MODE === 'library';
const isTestMode = process.env.TEST === 'true';

const vueOptions = {
  template: {
    compilerOptions: {
      isCustomElement: tag => ['ninja-keys'].includes(tag),
    },
  },
};

let plugins = [ruby(), vue(vueOptions)];

if (isLibraryMode) {
  plugins = [];
} else if (isTestMode) {
  plugins = [vue(vueOptions)];
}

// Development and production optimizations
const isDevelopment = process.env.NODE_ENV === 'development';

export default defineConfig({
  plugins: plugins,
  
  // Development server configuration
  server: {
    hmr: {
      port: 3036,
      overlay: false, // Disable error overlay for better performance in development
      clientPort: process.env.HMR_CLIENT_PORT ? parseInt(process.env.HMR_CLIENT_PORT) : 3036,
    },
    port: 3036,
    host: '0.0.0.0',
    strictPort: false,
    fs: {
      // Allow serving files from parent directories
      allow: ['..'],
      strict: false,
    },
    watch: {
      // Enhanced file watching for better performance
      ignored: [
        '**/node_modules/**', 
        '**/tmp/**', 
        '**/log/**', 
        '**/coverage/**', 
        '**/public/packs/**',
        '**/dist/**',
        '**/.git/**'
      ],
      usePolling: process.env.VITE_USE_POLLING === 'true',
      interval: 100,
    },
    cors: true,
    middlewareMode: false,
    
    // Proxy configuration for API calls during development
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false,
        timeout: 10000,
      },
      '/rails': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        secure: false,
        timeout: 10000,
      },
    },
  },
  // Development optimizations
  optimizeDeps: {
    // Enhanced dependency pre-bundling for faster cold starts
    force: false, // Don't force re-optimization every time
    
    include: [
      'vue',
      'vue-router',
      'vuex',
      'axios',
      '@vueuse/core',
      '@vueuse/components',
      'date-fns',
      'lodash.debounce',
      'chart.js',
      'markdown-it',
      'prosemirror-model',
      'prosemirror-state',
      'prosemirror-view'
    ],
    exclude: [
      '@vite/client', 
      '@vitejs/plugin-vue', 
      '@rails/actioncable'
    ],
    
    // Enable esbuild for faster dependency processing
    esbuildOptions: {
      target: 'es2020',
      keepNames: true,
    }
  },
  
  // Enable build caching for faster subsequent builds
  cacheDir: 'node_modules/.vite',

  // CSS configuration
  css: {
    devSourcemap: true,
    preprocessorOptions: {
      scss: {
        additionalData: `@import "app/javascript/dashboard/assets/scss/variables.scss";`,
        silenceDeprecations: ['legacy-js-api'],
      },
    },
  },

  build: {
    // Production build optimizations
    target: 'es2020',
    minify: process.env.NODE_ENV === 'production' ? 'terser' : false,
    cssMinify: process.env.NODE_ENV === 'production',
    sourcemap: process.env.NODE_ENV === 'production' ? false : 'inline',
    
    // Chunk size warnings
    chunkSizeWarningLimit: 1000,
    
    // Terser options for better compression
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production',
        drop_debugger: process.env.NODE_ENV === 'production',
        pure_funcs: process.env.NODE_ENV === 'production' ? ['console.log'] : [],
      },
      format: {
        comments: false,
      },
    },
    
    rollupOptions: {
      output: {
        // [NOTE] when not in library mode, no new keys will be addedd or overwritten
        // setting dir: isLibraryMode ? 'public/packs' : undefined will not work
        ...(isLibraryMode
          ? {
              dir: 'public/packs',
              entryFileNames: chunkInfo => {
                if (chunkInfo.name === 'sdk') {
                  return 'js/sdk.js';
                }
                return '[name].js';
              },
            }
          : {
              // Production optimizations for non-library builds
              manualChunks: {
                // Vendor chunks for better caching
                vue: ['vue', 'vue-router', 'vuex'],
                vendor: ['axios', 'lodash.debounce', 'date-fns'],
                ui: ['@vueuse/core', '@vueuse/components', 'floating-vue'],
              },
              chunkFileNames: 'assets/[name]-[hash].js',
              entryFileNames: 'assets/[name]-[hash].js',
              assetFileNames: (assetInfo) => {
                const info = assetInfo.name.split('.');
                const extType = info[info.length - 1];
                if (/\.(woff|woff2|eot|ttf|otf)$/.test(assetInfo.name)) {
                  return 'assets/fonts/[name]-[hash].[ext]';
                }
                if (/\.(png|jpe?g|gif|svg|ico|webp)$/.test(assetInfo.name)) {
                  return 'assets/images/[name]-[hash].[ext]';
                }
                if (extType === 'css') {
                  return 'assets/[name]-[hash].[ext]';
                }
                return 'assets/[name]-[hash].[ext]';
              },
            }),
        inlineDynamicImports: isLibraryMode, // Disable code-splitting for SDK
      },
      
      // External dependencies (for library mode)
      external: isLibraryMode ? [] : undefined,
      
      // Tree shaking optimizations
      treeshake: {
        moduleSideEffects: false,
        propertyReadSideEffects: false,
        unknownGlobalSideEffects: false,
      },
    },
    
    lib: isLibraryMode
      ? {
          entry: path.resolve(__dirname, './app/javascript/entrypoints/sdk.js'),
          formats: ['iife'], // IIFE format for single file
          name: 'sdk',
        }
      : undefined,
  },
  resolve: {
    alias: {
      vue: 'vue/dist/vue.esm-bundler.js',
      '@kirvano/utils': path.resolve('./app/javascript/shared/utils'),
      '@kirvano/prosemirror-schema': path.resolve('./app/javascript/shared/prosemirror'),
      '@kirvano/ninja-keys': 'ninja-keys',
      components: path.resolve('./app/javascript/dashboard/components'),
      next: path.resolve('./app/javascript/dashboard/components-next'),
      v3: path.resolve('./app/javascript/v3'),
      dashboard: path.resolve('./app/javascript/dashboard'),
      helpers: path.resolve('./app/javascript/shared/helpers'),
      shared: path.resolve('./app/javascript/shared'),
      survey: path.resolve('./app/javascript/survey'),
      widget: path.resolve('./app/javascript/widget'),
      assets: path.resolve('./app/javascript/dashboard/assets'),
      'reset': path.resolve('./app/javascript/widget/assets/scss/reset.scss'),
    },
  },
  test: {
    environment: 'jsdom',
    include: ['app/**/*.{test,spec}.?(c|m)[jt]s?(x)'],
    coverage: {
      reporter: ['lcov', 'text'],
      include: ['app/**/*.js', 'app/**/*.vue'],
      exclude: [
        'app/**/*.@(spec|stories|routes).js',
        '**/specs/**/*',
        '**/i18n/**/*',
      ],
    },
    globals: true,
    outputFile: 'coverage/sonar-report.xml',
    server: {
      deps: {
        inline: ['tinykeys', '@material/mwc-icon'],
      },
    },
    setupFiles: ['fake-indexeddb/auto', 'vitest.setup.js'],
    mockReset: true,
    clearMocks: true,
  },
});
