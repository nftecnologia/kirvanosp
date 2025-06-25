import { config } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import i18nMessages from 'dashboard/i18n';
import FloatingVue from 'floating-vue';

// Enhanced test setup with better performance and debugging
const i18n = createI18n({
  legacy: false,
  locale: 'en',
  messages: i18nMessages,
  warnHtmlMessage: false, // Disable HTML warnings in tests
  missing: (locale, key) => {
    if (process.env.NODE_ENV === 'test') {
      console.warn(`Missing translation for ${key} in ${locale}`);
    }
    return key;
  },
});

config.global.plugins = [i18n, FloatingVue];
config.global.stubs = {
  WootModal: { template: '<div><slot/></div>' },
  WootModalHeader: { template: '<div><slot/></div>' },
  NextButton: { template: '<button><slot/></button>' },
  RouterLink: { template: '<a><slot/></a>' },
  RouterView: { template: '<div><slot/></div>' },
  Teleport: { template: '<div><slot/></div>' },
  Transition: { template: '<div><slot/></div>' },
  TransitionGroup: { template: '<div><slot/></div>' },
};

// Global test configuration
config.global.mocks = {
  $t: (key) => key,
  $tc: (key) => key,
  $route: {
    path: '/test',
    params: {},
    query: {},
    meta: {},
  },
  $router: {
    push: vi.fn(),
    replace: vi.fn(),
    go: vi.fn(),
    back: vi.fn(),
    forward: vi.fn(),
  },
};

// Global test utilities
config.global.config.globalProperties.$bus = {
  $emit: vi.fn(),
  $on: vi.fn(),
  $off: vi.fn(),
};

// Performance monitoring for slow tests
if (process.env.TEST_PERFORMANCE) {
  const originalTest = global.test;
  global.test = (name, fn, timeout) => {
    return originalTest(name, async () => {
      const start = performance.now();
      await fn();
      const duration = performance.now() - start;
      if (duration > 1000) {
        console.warn(`Slow test detected: ${name} took ${duration.toFixed(2)}ms`);
      }
    }, timeout);
  };
}
