// Asiakas- ja laitostoiminnot (ilman revisioita)
let selectedCustomer = null;
let selectedPlant = null;
let allCustomers = [];
let allPlants = [];

function loadExistingSelection() {
  const existingSelection = localStorage.getItem('customerPlantSelection');
  if (existingSelection) {
    const selection = JSON.parse(existingSelection);
    selectedCustomer = selection.customer;
    selectedPlant = selection.plant;
    if (selectedCustomer) {
      document.getElementById('collapsedCustomerName').textContent = selectedCustomer.name;
      document.getElementById('collapsedCustomerLocation').textContent = selectedCustomer.town ? `${selectedCustomer.town}, ${selectedCustomer.country || ''}`.trim().replace(/,$/, '') : 'Location not specified';
      document.getElementById('collapsedCustomer').style.display = 'block';
      document.getElementById('customerSelectionForm').style.display = 'none';
      document.getElementById('customerCardTitle').textContent = 'Selected Customer';
      document.getElementById('customerCard').classList.add('active');
      document.getElementById('plantCard').style.display = 'block';
      const plantAddBtn = document.getElementById('addPlantBtn');
      if (plantAddBtn) {
        plantAddBtn.disabled = false;
        plantAddBtn.title = 'Add new plant';
      }
    }
    if (selectedPlant) {
      document.getElementById('collapsedPlantName').textContent = selectedPlant.name;
      updatePlantDisplay();
      document.getElementById('collapsedPlant').style.display = 'block';
      document.getElementById('plantSelectionForm').style.display = 'none';
    }
  }
}

async function loadCustomers() {
  try {
    document.getElementById('customerList').innerHTML = `<div class="loading"><i class="bi bi-arrow-clockwise"></i>Loading customers...</div>`;
    const response = await fetch(`${API_BASE}/customers?limit=1000`);
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    allCustomers = await response.json();
    displayCustomers(allCustomers);
  } catch (error) {
    console.error('Error loading customers:', error);
    document.getElementById('customerList').innerHTML = `<div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i>Failed to load customers. Please check your connection and try again.<button class="btn btn-outline-theme btn-sm ms-2" onclick="loadCustomers()"><i class="bi bi-arrow-clockwise"></i> Retry</button></div>`;
    showError('Failed to load customers. Please try again.');
  }
}

async function loadPlantsForCustomer(customerId) {
  try {
    document.getElementById('plantList').innerHTML = `<div class="loading"><i class="bi bi-arrow-clockwise"></i>Loading plants...</div>`;
    const response = await fetch(`${API_BASE}/customers/${customerId}/plants`);
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    const plants = await response.json();
    allPlants = plants;
    displayPlants(plants);
  } catch (error) {
    console.error('Error loading plants:', error);
    document.getElementById('plantList').innerHTML = `<div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i>Failed to load plants. Please check your connection and try again.<button class="btn btn-outline-theme btn-sm ms-2" onclick="loadPlantsForCustomer(${customerId})"><i class="bi bi-arrow-clockwise"></i> Retry</button></div>`;
    showError('Failed to load plants. Please try again.');
  }
}

function searchCustomers() {
  const searchTerm = document.getElementById('customerSearch').value.trim();
  const addBtn = document.getElementById('addCustomerBtn');
  if (!searchTerm) {
    document.getElementById('customerList').innerHTML = '';
    addBtn.disabled = true;
    addBtn.title = 'Type customer name to add new';
    return;
  }
  if (searchTerm === '*') {
    // ...
  }
  if (allCustomers.length === 0) {
    // ...
  }
  const filtered = allCustomers.filter(c => c.name && c.name.toLowerCase().includes(searchTerm.toLowerCase()));
  displayCustomers(filtered, searchTerm);
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

// ... Lisää funktiot: handleCustomerKeyPress, showAddCustomerForm, hideAddCustomerForm, createNewCustomer, addNewCustomer, selectCustomer, searchPlants, displayPlants, handlePlantKeyPress, addNewPlant, selectPlant ...

// Huom! Revisioihin liittyvät funktiot siirretään erilliseen tiedostoon.
