// eslint-disable-next-line
function toggleSecretField(e) {
  e.preventDefault();
  e.stopPropagation();

  const toggler = e.currentTarget;
  const secretField = toggler.parentElement;
  const textElement = secretField.querySelector('[data-secret-masked]');

  if (!textElement) return;

  if (textElement.dataset.secretMasked === 'false') {
    const maskedLength = secretField.dataset.secretText?.length || 10;
    textElement.textContent = '•'.repeat(maskedLength);
    textElement.dataset.secretMasked = 'true';
    toggler.querySelector('svg use').setAttribute('xlink:href', '#eye-show');

    return;
  }

  textElement.textContent = secretField.dataset.secretText;
  textElement.dataset.secretMasked = 'false';
  toggler.querySelector('svg use').setAttribute('xlink:href', '#eye-hide');
}

// eslint-disable-next-line
function copySecretField(e) {
  e.preventDefault();
  e.stopPropagation();

  const toggler = e.currentTarget;
  const secretField = toggler.parentElement;

  navigator.clipboard.writeText(secretField.dataset.secretText);
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.cell-data__secret-field').forEach(field => {
    const span = field.querySelector('[data-secret-masked]');
    if (span && span.dataset.secretMasked === 'true') {
      const len = field.dataset.secretText?.length || 10;
      span.textContent = '•'.repeat(len);
    }
  });
});
