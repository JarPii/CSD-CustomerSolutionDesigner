// Yleiset apufunktiot ja notifikaatiot
function showError(message) {
  const errorDiv = document.createElement('div');
  errorDiv.className = 'alert alert-danger';
  errorDiv.style.position = 'fixed';
  errorDiv.style.top = '20px';
  errorDiv.style.right = '20px';
  errorDiv.style.zIndex = '9999';
  errorDiv.innerHTML = `
    <i class="bi bi-exclamation-triangle"></i>
    ${message}
    <button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
  `;
  document.body.appendChild(errorDiv);
  setTimeout(() => {
    if (errorDiv.parentElement) errorDiv.remove();
  }, 5000);
}

function showSuccess(message) {
  const successDiv = document.createElement('div');
  successDiv.className = 'alert alert-success';
  successDiv.style.position = 'fixed';
  successDiv.style.top = '20px';
  successDiv.style.right = '20px';
  successDiv.style.zIndex = '9999';
  successDiv.style.backgroundColor = '#d4edda';
  successDiv.style.borderColor = '#c3e6cb';
  successDiv.style.color = '#155724';
  successDiv.innerHTML = `
    <i class="bi bi-check-circle"></i>
    ${message}
    <button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
  `;
  document.body.appendChild(successDiv);
  setTimeout(() => {
    if (successDiv.parentElement) successDiv.remove();
  }, 3000);
}

// Debounce utility
function debounce(fn, delay) {
  let timeout;
  return function(...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => fn.apply(this, args), delay);
  };
}
