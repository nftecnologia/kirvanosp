import Auth from '../api/auth';

const parseErrorCode = error => Promise.reject(error);

export default axios => {
  const { apiHost = '' } = window.kirvanoConfig || {};
  const wootApi = axios.create({ 
    baseURL: `${apiHost}/`,
    timeout: 15000, // 15 seconds timeout
    headers: {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache'
    }
  });
  // Add Auth Headers to requests if logged in
  if (Auth.hasAuthCookie()) {
    const {
      'access-token': accessToken,
      'token-type': tokenType,
      client,
      expiry,
      uid,
    } = Auth.getAuthData();
    Object.assign(wootApi.defaults.headers.common, {
      'access-token': accessToken,
      'token-type': tokenType,
      client,
      expiry,
      uid,
    });
  }
  // Request interceptor for loading states
  wootApi.interceptors.request.use(
    config => {
      // Add request timeout warning for development
      if (process.env.NODE_ENV === 'development') {
        const timeoutWarning = setTimeout(() => {
          // Slow API request detected - could add monitoring here
        }, 5000);
        config.timeoutWarning = timeoutWarning;
      }
      return config;
    },
    error => Promise.reject(error)
  );

  // Response parsing interceptor
  wootApi.interceptors.response.use(
    response => {
      // Clear timeout warning on success
      if (process.env.NODE_ENV === 'development' && response.config.timeoutWarning) {
        clearTimeout(response.config.timeoutWarning);
      }
      return response;
    },
    error => {
      // Clear timeout warning on error
      if (process.env.NODE_ENV === 'development' && error.config?.timeoutWarning) {
        clearTimeout(error.config.timeoutWarning);
      }
      if (error.code === 'ECONNABORTED' && error.message.includes('timeout')) {
        error.message = 'Request timed out. Please check your connection and try again.';
      }
      return parseErrorCode(error);
    }
  );
  return wootApi;
};
