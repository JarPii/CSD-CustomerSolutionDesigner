// API-pohjaosoite (päivitetty 24.7.2025: backend ei käytä enää /api-prefixiä, vaan reitit ovat suoraan juuresta)
// Muutos tehty, koska backendin reitit ovat nyt muodossa /customers eikä /api/customers
const API_BASE = '';
// Asiakashaku ja suodatus
async function searchCustomers() {
  const searchTerm = document.getElementById('customerSearch').value.trim();
  const addBtn = document.getElementById('addCustomerBtn');
  if (!searchTerm) {
    document.getElementById('customerList').innerHTML = '';
    addBtn.disabled = true;
    addBtn.title = 'Type customer name to add new';
    return;
  }
  // Jos '*', haetaan kaikki asiakkaat backendistä
  if (searchTerm === '*') {
    try {
      document.getElementById('customerList').innerHTML = `<div class="loading"><i class="bi bi-arrow-clockwise"></i> Loading all customers...</div>`;
      addBtn.disabled = true;
      addBtn.title = 'Loading...';
      const response = await fetch(`${API_BASE}/customers?limit=1000`);
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status} ${response.statusText}`);
      allCustomers = await response.json();
      displayCustomers(allCustomers, '*');
      addBtn.disabled = true;
      addBtn.title = 'Select from list or clear search to add new';
    } catch (error) {
      document.getElementById('customerList').innerHTML = `<div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i> Failed to load customers. ${error.message}</div>`;
      addBtn.disabled = true;
      addBtn.title = 'Loading failed';
      showError('Failed to load customers. ' + error.message);
    }
    return;
  }
  // Muulloin suodatetaan allCustomers-listaa frontendissä
  // Jos allCustomers ei ole ladattu, lataa se ensin (vain kerran)
  if (allCustomers.length === 0) {
    try {
      document.getElementById('customerList').innerHTML = `<div class="loading"><i class="bi bi-arrow-clockwise"></i> Loading customers...</div>`;
      addBtn.disabled = true;
      addBtn.title = 'Loading...';
      const response = await fetch(`${API_BASE}/customers?limit=1000`);
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status} ${response.statusText}`);
      allCustomers = await response.json();
    } catch (error) {
      document.getElementById('customerList').innerHTML = `<div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i> Failed to load customers. ${error.message}</div>`;
      addBtn.disabled = true;
      addBtn.title = 'Loading failed';
      showError('Failed to load customers. ' + error.message);
      return;
    }
  }
  // Suodata asiakkaat hakukentän mukaan
  const filtered = allCustomers.filter(c => c.name && c.name.toLowerCase().includes(searchTerm.toLowerCase()));
  displayCustomers(filtered, searchTerm);
  // Lisää-nappi: jos ei yhtään osumaa, mahdollista lisätä uusi
  if (filtered.length === 0) {
    addBtn.disabled = false;
    addBtn.title = `Add "${searchTerm}" as new customer`;
    document.getElementById('newCustomerName').value = searchTerm;
  } else {
    addBtn.disabled = true;
    addBtn.title = 'Customer found - select from list';
    hideAddCustomerForm();
  }
}

function displayCustomers(customerList, searchTerm) {
  const listContainer = document.getElementById('customerList');
  listContainer.innerHTML = '';
  if (customerList.length === 0) {
    listContainer.innerHTML = '<p class="text-muted">No customers found.</p>';
    return;
  }
  customerList.forEach(customer => {
    const item = document.createElement('div');
    item.className = 'list-item';
    item.onclick = () => selectCustomer(customer);
    item.innerHTML = `<span>${customer.name}</span><i class="bi bi-chevron-right"></i>`;
    listContainer.appendChild(item);
  });
}

// Kytketään searchCustomers inputin tapahtumiin
document.addEventListener('DOMContentLoaded', () => {
  const input = document.getElementById('customerSearch');
  if (input) {
    input.addEventListener('input', searchCustomers);
  }
});

// --- THEME & HEADER HANDLING ---
function getQueryParam(name, fallback) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(name) || fallback;
}
const currentTheme = getQueryParam('theme', 'sales');
const returnUrl = getQueryParam('return', 'index.html');
const THEMES = {
  sales:   { 'primary': '#113a4c', 'primary-dark': '#0d2a3a', 'text': '#ffffff', name: 'Sales' },
  engineering: { 'primary': '#9de2e7', 'primary-dark': '#7dd5db', 'text': '#000000', name: 'Engineering' },
  simulation:  { 'primary': '#e5dddf', 'primary-dark': '#d9d0d3', 'text': '#000000', name: 'Simulation' },
};
const config = THEMES[currentTheme] || THEMES.sales;
Object.entries(config).forEach(([key, value]) => {
  if (key !== 'name') {
    document.documentElement.style.setProperty(`--theme-${key}`, value);
  }
});

document.addEventListener('DOMContentLoaded', () => {
  if (typeof createHeader === 'function') {
    createHeader({ theme: currentTheme });
  }
});

// Asiakas- ja laitostoiminnot sekä kaikki HTML:ssä viitatut funktiot
let selectedCustomer = null;
let selectedPlant = null;
let allCustomers = [];
let allPlants = [];

function handleCustomerKeyPress(event) {
  if (event.key === 'Enter') {
    const searchTerm = event.target.value.trim();
    if (searchTerm) {
      const customerItems = document.querySelectorAll('#customerList .list-item');
      if (customerItems.length === 1) {
        customerItems[0].click();
      } else if (customerItems.length === 0) {
        showAddCustomerForm();
      }
    }
  }
}

function showAddCustomerForm() {
  document.getElementById('addCustomerForm').style.display = 'block';
  const searchTerm = document.getElementById('customerSearch').value.trim();
  if (searchTerm) {
    document.getElementById('newCustomerName').value = searchTerm;
  }
  document.getElementById('newCustomerName').focus();
}

function hideAddCustomerForm() {
  document.getElementById('addCustomerForm').style.display = 'none';
  if (selectedCustomer) {
    document.getElementById('customerSelectionForm').style.display = 'none';
    document.getElementById('collapsedCustomer').style.display = 'block';
  }
  document.getElementById('newCustomerName').value = '';
  document.getElementById('newCustomerTown').value = '';
  document.getElementById('newCustomerCountry').value = '';
  const createButton = document.querySelector('#addCustomerForm .btn-theme-primary');
  if (createButton) {
    createButton.innerHTML = '<i class="bi bi-plus"></i> Create Customer';
    createButton.onclick = () => createNewCustomer();
  }
  const titleElement = document.querySelector('#addCustomerForm .card-header h6');
  if (titleElement) {
    titleElement.textContent = 'Add New Customer';
  }
}

async function createNewCustomer() {
  const name = document.getElementById('newCustomerName').value.trim();
  const town = document.getElementById('newCustomerTown').value.trim();
  const country = document.getElementById('newCustomerCountry').value.trim();
  if (!name) {
    showError('Please enter a customer name.');
    return;
  }
  try {
    const customerData = { name };
    if (town) customerData.town = town;
    if (country) customerData.country = country;
    const response = await fetch(`${API_BASE}/customers`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(customerData),
    });
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    const newCustomer = await response.json();
    allCustomers.push(newCustomer);
    hideAddCustomerForm();
    selectCustomer(newCustomer);
  } catch (error) {
    showError('Failed to create customer. Please try again.');
  }
}

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
  setTimeout(() => { if (errorDiv.parentElement) errorDiv.remove(); }, 5000);
}

// Lisää muut tarvittavat funktiot tähän (esim. selectCustomer, searchCustomers, displayCustomers, jne.)

