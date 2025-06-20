// Utilitários que substituem @kirvano/utils
import debounce from 'lodash.debounce';
import { getContrast, readableColor } from 'color2k';
import { formatDistanceToNow, parseISO, isAfter, isBefore } from 'date-fns';

// Debounce function
export { debounce };

// Color utilities
export function getContrastingTextColor(backgroundColor) {
  try {
    return readableColor(backgroundColor);
  } catch {
    return '#000000'; // fallback
  }
}

// Date utilities  
export function coerceToDate(dateString) {
  if (!dateString) return null;
  try {
    return parseISO(dateString);
  } catch {
    return new Date(dateString);
  }
}

export function formatTime(seconds) {
  if (!seconds || seconds === 0) return '0s';
  
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  
  if (hours > 0) {
    return `${hours}h ${minutes}m ${secs}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${secs}s`;
  } else {
    return `${secs}s`;
  }
}

// String utilities
export function replaceVariablesInMessage(message, variables = {}) {
  if (!message || typeof message !== 'string') return message;
  
  return message.replace(/\{\{\s*(\w+)\s*\}\}/g, (match, variable) => {
    return variables[variable] || match;
  });
}

export function trimContent(content) {
  if (!content) return '';
  return content.trim();
}

export function splitName(fullName) {
  if (!fullName) return { firstName: '', lastName: '' };
  
  const parts = fullName.trim().split(' ');
  return {
    firstName: parts[0] || '',
    lastName: parts.slice(1).join(' ') || ''
  };
}

export function fileNameWithEllipsis(fileName, maxLength = 30) {
  if (!fileName || fileName.length <= maxLength) return fileName;
  
  const extension = fileName.split('.').pop();
  const name = fileName.slice(0, fileName.lastIndexOf('.'));
  const ellipsisLength = maxLength - extension.length - 3; // 3 for "..."
  
  return `${name.slice(0, ellipsisLength)}...${extension}`;
}

export function formatNumber(number) {
  if (typeof number !== 'number') return number;
  return new Intl.NumberFormat().format(number);
}

// File utilities
export function getFileInfo(file) {
  if (!file) return {};
  
  return {
    name: file.name,
    size: file.size,
    type: file.type,
    lastModified: file.lastModified
  };
}

export function downloadFile(url, filename) {
  const link = document.createElement('a');
  link.href = url;
  link.download = filename || 'download';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// Typing indicator
export function createTypingIndicator(callback, delay = 1000) {
  return debounce(callback, delay);
}

// Recipients utility
export function getRecipients(contacts = []) {
  return contacts.map(contact => ({
    id: contact.id,
    name: contact.name,
    email: contact.email
  }));
}

// Host utility
export function isSameHost(url1, url2) {
  try {
    const host1 = new URL(url1).hostname;
    const host2 = new URL(url2).hostname;
    return host1 === host2;
  } catch {
    return false;
  }
}

// Boolean parser
export function parseBoolean(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true';
  }
  return !!value;
}

// SLA utilities
export function evaluateSLAStatus(sla, currentTime) {
  if (!sla) return 'unknown';
  
  const deadline = new Date(sla.deadline);
  const now = new Date(currentTime);
  
  if (isAfter(now, deadline)) return 'breached';
  if (isBefore(now, deadline)) return 'on_track';
  return 'at_risk';
}

export function convertSecondsToTimeUnit(seconds) {
  if (seconds < 60) return { value: seconds, unit: 'seconds' };
  if (seconds < 3600) return { value: Math.floor(seconds / 60), unit: 'minutes' };
  if (seconds < 86400) return { value: Math.floor(seconds / 3600), unit: 'hours' };
  return { value: Math.floor(seconds / 86400), unit: 'days' };
}

// Reports utilities
export function getQuantileIntervals(data, quantiles = 5) {
  if (!data || !data.length) return [];
  
  const sorted = [...data].sort((a, b) => a - b);
  const intervals = [];
  
  for (let i = 1; i <= quantiles; i++) {
    const index = Math.ceil((i / quantiles) * sorted.length) - 1;
    intervals.push(sorted[index]);
  }
  
  return intervals;
}

// Image zoom utilities
export function createImageZoom(imageElement, options = {}) {
  return {
    zoom: (scale = 2) => {
      imageElement.style.transform = `scale(${scale})`;
    },
    reset: () => {
      imageElement.style.transform = 'scale(1)';
    }
  };
} 