// sales.js
// Kaikki sales-sivun JavaScript siirretty tänne ulkoiseen tiedostoon

// Check for existing customer/plant selection
function updateCustomerPlantCard() {
  const selection = JSON.parse(sessionStorage.getItem('customerPlantSelection') || 'null');
  const card = document.querySelector('.tool-card[onclick="openCustomerPlantSelection()"]');
  
  if (selection && card) {
    const cardBody = card.querySelector('.card-body');
    const button = card.querySelector('.btn');
    
    // Add selected class for visual highlighting
    card.classList.add('selected');
    
    // Update card content to show current selection with enhanced formatting
    // Customer without location, plant with location on same line using town and country
    let plantLocationText = '';
    if (selection.plant.town && selection.plant.country) {
      plantLocationText = ` - ${selection.plant.town}, ${selection.plant.country}`;
    } else if (selection.plant.town) {
      plantLocationText = ` - ${selection.plant.town}`;
    } else if (selection.plant.country) {
      plantLocationText = ` - ${selection.plant.country}`;
    } else {
      plantLocationText = ' - Location not specified';
    }
    
    cardBody.querySelector('p').innerHTML = `
      <strong style="color: #000; font-size: 0.9rem;">Current Selection:</strong><br>
      <div style="margin-bottom: 8px; margin-top: 8px;">
        <i class="bi bi-building me-1" style="color: #113a4c;"></i> 
        <span style="font-size: 1rem; font-weight: 600; color: #000;">${selection.customer.name}</span>
      </div>
      <div style="margin-bottom: 4px;">
        <i class="bi bi-building-gear me-1" style="color: #113a4c;"></i> 
        <span style="font-size: 1rem; font-weight: 600; color: #000;">${selection.plant.name}</span>
        <span style="margin-left: 8px; font-size: 0.8rem; color: #6c757d;">${plantLocationText}</span>
      </div>
    `;
    
    button.innerHTML = '<i class="bi bi-arrow-repeat"></i> Change Selection';
  } else {
    // Remove selected class if no selection
    if (card) {
      card.classList.remove('selected');
    }
  }
}
// --- THEME & RETURN PARAMETER HANDLING ---
function getQueryParam(name, fallback) {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get(name) || fallback;
}
const currentTheme = getQueryParam('theme', 'sales');
const returnUrl = getQueryParam('return', 'index.html');
// Aseta CSS custom properties teeman mukaan
const THEMES = {
  sales:   { 'primary': '#113a4c', 'primary-dark': '#0d2a3a', 'text': '#ffffff', name: 'Sales' },
  engineering: { 'primary': '#9de2e7', 'primary-dark': '#7dd5db', 'text': '#000000', name: 'Engineering' },
  simulation:  { 'primary': '#e5dddf', 'primary-dark': '#d9d0d3', 'text': '#000000', name: 'Simulation' },
};
const config = THEMES[currentTheme] || THEMES.sales;
Object.entries(config).forEach(([key, value]) => {
  if (key !== 'name') {
    document.documentElement.style.setProperty(`--theme-${key}`, value);
    console.log(`Set --theme-${key}:`, value);
  }
});

// Open customer and plant selection
function openCustomerPlantSelection() {
  const selectionUrl = `/static/customer-plant-selection.html?theme=${encodeURIComponent(currentTheme)}&return=sales.html`;
  window.location.href = selectionUrl;
}

// Open basic line & layout design
function openBasicLineLayout() {
  const layoutUrl = `/static/basic-line-layout.html?theme=${encodeURIComponent(currentTheme)}&return=sales.html`;
  window.location.href = layoutUrl;
}

// Open products management
function openProducts() {
  window.location.href = `/static/products.html?theme=${encodeURIComponent(currentTheme)}&return=sales.html`;
}

// Open requirements management
function openRequirements() {
  window.location.href = `/static/requirements.html?theme=${encodeURIComponent(currentTheme)}&return=sales.html`;
}

// Open treatment programs with sales theme
function openTreatmentPrograms() {
  // Check if customer and plant are selected
  const selection = JSON.parse(sessionStorage.getItem('customerPlantSelection') || 'null');

  if (selection && selection.customer && selection.plant) {
    const programsUrl = `/static/treatment-programs.html?customerId=${selection.customer.id}&plantId=${selection.plant.id}&theme=${encodeURIComponent(currentTheme)}&return=sales.html`;
    window.open(programsUrl, '_blank');
  } else {
    // If no selection, prompt to select first
    alert('Please select a customer and plant first.');
    openCustomerPlantSelection();
  }
}

// Save customer and plant selection to sessionStorage
function saveCustomerPlantSelection(customer, plant) {
  const selection = {
    customer: customer,
    plant: plant
  };
  sessionStorage.setItem('customerPlantSelection', JSON.stringify(selection));
}

// Initialize universal header when page loads
document.addEventListener('DOMContentLoaded', () => {
  createHeader({ theme: currentTheme });
  // Debug: tulosta custom properties arvot
  ['primary','primary-dark','text'].forEach(k=>{
    console.log(`Computed --theme-${k}:`, getComputedStyle(document.documentElement).getPropertyValue(`--theme-${k}`));
  });
  // updateCustomerPlantCard(); // Jos käytössä, päivitä valintakortti
});
