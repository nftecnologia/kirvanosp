// Test helpers and utilities for Vue components and JavaScript modules

import { mount, shallowMount } from '@vue/test-utils';
import { createI18n } from 'vue-i18n';
import i18nMessages from 'dashboard/i18n';

// Enhanced test wrapper factory
export function createTestWrapper(component, options = {}) {
  const defaultOptions = {
    global: {
      plugins: [
        createI18n({
          legacy: false,
          locale: 'en',
          messages: i18nMessages,
          warnHtmlMessage: false,
        })
      ],
      mocks: {
        $t: (key) => key,
        $tc: (key) => key,
        $route: {
          path: '/test',
          params: {},
          query: {},
          meta: {},
          ...options.route,
        },
        $router: {
          push: vi.fn(),
          replace: vi.fn(),
          go: vi.fn(),
          back: vi.fn(),
          forward: vi.fn(),
          ...options.router,
        },
      },
      stubs: {
        WootModal: { template: '<div><slot/></div>' },
        WootModalHeader: { template: '<div><slot/></div>' },
        NextButton: { template: '<button><slot/></button>' },
        RouterLink: { template: '<a><slot/></a>' },
        RouterView: { template: '<div><slot/></div>' },
        Teleport: { template: '<div><slot/></div>' },
        Transition: { template: '<div><slot/></div>' },
        TransitionGroup: { template: '<div><slot/></div>' },
        ...options.stubs,
      },
    },
    ...options,
  };

  // Merge global options properly
  if (options.global) {
    defaultOptions.global = {
      ...defaultOptions.global,
      ...options.global,
      mocks: {
        ...defaultOptions.global.mocks,
        ...options.global.mocks,
      },
      stubs: {
        ...defaultOptions.global.stubs,
        ...options.global.stubs,
      },
    };
  }

  return mount(component, defaultOptions);
}

// Shallow mount wrapper for unit tests
export function createShallowWrapper(component, options = {}) {
  const mountOptions = createTestWrapper(component, options);
  return shallowMount(component, mountOptions.options);
}

// Mock API response helper
export function createMockApiResponse(data, status = 200, headers = {}) {
  return {
    data,
    status,
    statusText: status === 200 ? 'OK' : 'Error',
    headers,
    config: {},
  };
}

// Wait for next tick utility
export function nextTick() {
  return new Promise(resolve => {
    setTimeout(resolve, 0);
  });
}

// Async test utility
export async function waitFor(callback, timeout = 1000) {
  const start = Date.now();
  
  while (Date.now() - start < timeout) {
    try {
      const result = await callback();
      if (result) return result;
    } catch (error) {
      // Continue waiting
    }
    await nextTick();
  }
  
  throw new Error(`Timeout waiting for condition after ${timeout}ms`);
}

// Mock Vuex store creator
export function createMockStore(modules = {}) {
  const store = {
    state: {},
    getters: {},
    mutations: {},
    actions: {},
    commit: vi.fn(),
    dispatch: vi.fn(),
    subscribe: vi.fn(),
    subscribeAction: vi.fn(),
    watch: vi.fn(),
    replaceState: vi.fn(),
    ...modules,
  };

  return {
    install(app) {
      app.config.globalProperties.$store = store;
      app.provide('store', store);
    },
    ...store,
  };
}

// Mock console methods for testing
export function mockConsole() {
  const originalConsole = { ...console };
  
  beforeEach(() => {
    console.log = vi.fn();
    console.warn = vi.fn();
    console.error = vi.fn();
    console.info = vi.fn();
    console.debug = vi.fn();
  });

  afterEach(() => {
    Object.assign(console, originalConsole);
  });

  return {
    expectLog: (message) => expect(console.log).toHaveBeenCalledWith(message),
    expectWarn: (message) => expect(console.warn).toHaveBeenCalledWith(message),
    expectError: (message) => expect(console.error).toHaveBeenCalledWith(message),
  };
}

// Performance testing utility
export function measurePerformance(fn, threshold = 100) {
  return async (...args) => {
    const start = performance.now();
    const result = await fn(...args);
    const duration = performance.now() - start;
    
    if (duration > threshold) {
      console.warn(`Performance warning: operation took ${duration.toFixed(2)}ms`);
    }
    
    return { result, duration };
  };
}

// File upload mock helper
export function createMockFile(name = 'test.txt', size = 1024, type = 'text/plain') {
  const file = new File(['test content'], name, { type, size });
  Object.defineProperty(file, 'size', { value: size });
  return file;
}

// LocalStorage mock
export function mockLocalStorage() {
  const store = {};
  
  return {
    getItem: vi.fn((key) => store[key] || null),
    setItem: vi.fn((key, value) => {
      store[key] = String(value);
    }),
    removeItem: vi.fn((key) => {
      delete store[key];
    }),
    clear: vi.fn(() => {
      Object.keys(store).forEach(key => delete store[key]);
    }),
    key: vi.fn((index) => Object.keys(store)[index] || null),
    get length() {
      return Object.keys(store).length;
    },
  };
}

// Form testing utilities
export function fillForm(wrapper, formData) {
  Object.entries(formData).forEach(([field, value]) => {
    const input = wrapper.find(`[data-testid="${field}"], input[name="${field}"], textarea[name="${field}"], select[name="${field}"]`);
    if (input.exists()) {
      input.setValue(value);
    }
  });
}

export function submitForm(wrapper, formSelector = 'form') {
  const form = wrapper.find(formSelector);
  if (form.exists()) {
    form.trigger('submit');
  }
}

// Component testing utilities
export function expectComponentToRender(wrapper) {
  expect(wrapper.exists()).toBe(true);
  expect(wrapper.html()).toBeTruthy();
}

export function expectComponentToEmit(wrapper, eventName, payload = undefined) {
  const emitted = wrapper.emitted();
  expect(emitted[eventName]).toBeTruthy();
  if (payload !== undefined) {
    expect(emitted[eventName][0]).toEqual([payload]);
  }
}

// API testing utilities
export function mockAxios() {
  const mockAxios = {
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    patch: vi.fn(),
    delete: vi.fn(),
    create: vi.fn(() => mockAxios),
    defaults: {
      headers: {
        common: {},
        post: {},
        put: {},
        patch: {},
        delete: {},
      },
    },
    interceptors: {
      request: {
        use: vi.fn(),
        eject: vi.fn(),
      },
      response: {
        use: vi.fn(),
        eject: vi.fn(),
      },
    },
  };

  return mockAxios;
}

// Error boundary testing
export function expectToThrow(fn, errorMessage) {
  expect(() => fn()).toThrow(errorMessage);
}

export function expectAsyncToThrow(asyncFn, errorMessage) {
  return expect(asyncFn()).rejects.toThrow(errorMessage);
}