/**
 * API Utility Functions for Surface Treatment Plants Frontend
 * John Cockerill - Surface Treatment Plants Solution
 */

// API Base Configuration
const API_BASE = window.location.origin;

// Error handling utility
function handleApiError(error, context = '') {
    console.error(`API Error ${context}:`, error);
    
    let errorMessage = 'An unexpected error occurred';
    
    if (error.response) {
        // Server responded with error status
        errorMessage = error.response.data?.detail || `Server error: ${error.response.status}`;
    } else if (error.request) {
        // Network error
        errorMessage = 'Network error. Please check your connection.';
    } else {
        // Other error
        errorMessage = error.message || 'Unknown error occurred';
    }
    
    showErrorMessage(errorMessage);
    return null;
}

// Show error message to user
function showErrorMessage(message) {
    // Create or update error alert
    let alertContainer = document.getElementById('error-alert-container');
    if (!alertContainer) {
        alertContainer = document.createElement('div');
        alertContainer.id = 'error-alert-container';
        alertContainer.className = 'position-fixed top-0 start-50 translate-middle-x';
        alertContainer.style.zIndex = '9999';
        alertContainer.style.marginTop = '20px';
        document.body.appendChild(alertContainer);
    }
    
    alertContainer.innerHTML = `
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        const alert = alertContainer.querySelector('.alert');
        if (alert) {
            alert.classList.remove('show');
            setTimeout(() => alertContainer.innerHTML = '', 150);
        }
    }, 5000);
}

// Show success message to user
function showSuccessMessage(message) {
    let alertContainer = document.getElementById('success-alert-container');
    if (!alertContainer) {
        alertContainer = document.createElement('div');
        alertContainer.id = 'success-alert-container';
        alertContainer.className = 'position-fixed top-0 start-50 translate-middle-x';
        alertContainer.style.zIndex = '9999';
        alertContainer.style.marginTop = '20px';
        document.body.appendChild(alertContainer);
    }
    
    alertContainer.innerHTML = `
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle me-2"></i>
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    // Auto-dismiss after 3 seconds
    setTimeout(() => {
        const alert = alertContainer.querySelector('.alert');
        if (alert) {
            alert.classList.remove('show');
            setTimeout(() => alertContainer.innerHTML = '', 150);
        }
    }, 3000);
}

// Generic API request function
async function apiRequest(endpoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });
        
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.detail || `HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    } catch (error) {
        handleApiError(error, endpoint);
        throw error;
    }
}

// Customer API functions
const CustomerAPI = {
    // Get all customers
    async getAll() {
        return await apiRequest('/customers');
    },
    
    // Get customer by ID
    async getById(customerId) {
        return await apiRequest(`/customers/${customerId}`);
    },
    
    // Create new customer
    async create(customerData) {
        return await apiRequest('/customers', {
            method: 'POST',
            body: JSON.stringify(customerData)
        });
    },
    
    // Update customer
    async update(customerId, customerData) {
        return await apiRequest(`/customers/${customerId}`, {
            method: 'PUT',
            body: JSON.stringify(customerData)
        });
    },
    
    // Delete customer
    async delete(customerId) {
        return await apiRequest(`/customers/${customerId}`, {
            method: 'DELETE'
        });
    },
    
    // Check if customer can be deleted
    async canDelete(customerId) {
        return await apiRequest(`/customers/${customerId}/can-delete`);
    },
    
    // Get customer's plants
    async getPlants(customerId) {
        return await apiRequest(`/customers/${customerId}/plants`);
    }
};

// Plant API functions
const PlantAPI = {
    // Get all plants
    async getAll() {
        return await apiRequest('/plants');
    },
    
    // Get plant by ID
    async getById(plantId) {
        return await apiRequest(`/plants/${plantId}`);
    },
    
    // Create new plant
    async create(plantData) {
        return await apiRequest('/plants', {
            method: 'POST',
            body: JSON.stringify(plantData)
        });
    },
    
    // Update plant
    async update(plantId, plantData) {
        return await apiRequest(`/plants/${plantId}`, {
            method: 'PUT',
            body: JSON.stringify(plantData)
        });
    },
    
    // Delete plant
    async delete(plantId) {
        return await apiRequest(`/plants/${plantId}`, {
            method: 'DELETE'
        });
    },
    
    // Get plant's lines
    async getLines(plantId) {
        return await apiRequest(`/plants/${plantId}/lines`);
    }
};

// Line API functions
const LineAPI = {
    // Get line by ID
    async getById(lineId) {
        return await apiRequest(`/lines/${lineId}`);
    },
    
    // Create new line
    async create(lineData) {
        return await apiRequest('/lines', {
            method: 'POST',
            body: JSON.stringify(lineData)
        });
    },
    
    // Update line
    async update(lineId, lineData) {
        return await apiRequest(`/lines/${lineId}`, {
            method: 'PUT',
            body: JSON.stringify(lineData)
        });
    },
    
    // Delete line
    async delete(lineId) {
        return await apiRequest(`/lines/${lineId}`, {
            method: 'DELETE'
        });
    },
    
    // Get line's tank groups
    async getTankGroups(lineId) {
        return await apiRequest(`/lines/${lineId}/tank-groups`);
    },
    
    // Get line's tanks (simplified view)
    async getTanks(lineId) {
        return await apiRequest(`/lines/${lineId}/tanks`);
    }
};

// Product API functions
const ProductAPI = {
    // Get all customer products
    async getAll() {
        return await apiRequest('/products');
    },
    
    // Get product by ID
    async getById(productId) {
        return await apiRequest(`/products/${productId}`);
    },
    
    // Create new product
    async create(productData) {
        return await apiRequest('/products', {
            method: 'POST',
            body: JSON.stringify(productData)
        });
    },
    
    // Update product
    async update(productId, productData) {
        return await apiRequest(`/products/${productId}`, {
            method: 'PUT',
            body: JSON.stringify(productData)
        });
    },
    
    // Delete product
    async delete(productId) {
        return await apiRequest(`/products/${productId}`, {
            method: 'DELETE'
        });
    }
};

// Production Requirements API functions
const RequirementAPI = {
    // Get all production requirements
    async getAll() {
        return await apiRequest('/production-requirements');
    },
    
    // Get requirement by ID
    async getById(requirementId) {
        return await apiRequest(`/production-requirements/${requirementId}`);
    },
    
    // Create new requirement
    async create(requirementData) {
        return await apiRequest('/production-requirements', {
            method: 'POST',
            body: JSON.stringify(requirementData)
        });
    },
    
    // Update requirement
    async update(requirementId, requirementData) {
        return await apiRequest(`/production-requirements/${requirementId}`, {
            method: 'PUT',
            body: JSON.stringify(requirementData)
        });
    },
    
    // Delete requirement
    async delete(requirementId) {
        return await apiRequest(`/production-requirements/${requirementId}`, {
            method: 'DELETE'
        });
    }
};

// Device API functions
const DeviceAPI = {
    // Get all devices
    async getAll() {
        return await apiRequest('/devices');
    },
    
    // Search devices
    async search(query) {
        return await apiRequest(`/devices/search?q=${encodeURIComponent(query)}`);
    },
    
    // Create new device
    async create(deviceData) {
        return await apiRequest('/devices', {
            method: 'POST',
            body: JSON.stringify(deviceData)
        });
    }
};

// Function API functions
const FunctionAPI = {
    // Get all functions
    async getAll() {
        return await apiRequest('/functions');
    },
    
    // Get function by ID
    async getById(functionId) {
        return await apiRequest(`/functions/${functionId}`);
    },
    
    // Create new function
    async create(functionData) {
        return await apiRequest('/functions', {
            method: 'POST',
            body: JSON.stringify(functionData)
        });
    }
};

// Tank and Tank Group API functions
const TankAPI = {
    // Get tank by ID
    async getById(tankId) {
        return await apiRequest(`/tanks/${tankId}`);
    },
    
    // Create new tank
    async create(tankData) {
        return await apiRequest('/tanks', {
            method: 'POST',
            body: JSON.stringify(tankData)
        });
    },
    
    // Update tank
    async update(tankId, tankData) {
        return await apiRequest(`/tanks/${tankId}`, {
            method: 'PUT',
            body: JSON.stringify(tankData)
        });
    },
    
    // Delete tank
    async delete(tankId) {
        return await apiRequest(`/tanks/${tankId}`, {
            method: 'DELETE'
        });
    }
};

const TankGroupAPI = {
    // Get tank group by ID
    async getById(tankGroupId) {
        return await apiRequest(`/tank-groups/${tankGroupId}`);
    },
    
    // Create new tank group
    async create(tankGroupData) {
        return await apiRequest('/tank-groups', {
            method: 'POST',
            body: JSON.stringify(tankGroupData)
        });
    },
    
    // Update tank group
    async update(tankGroupId, tankGroupData) {
        return await apiRequest(`/tank-groups/${tankGroupId}`, {
            method: 'PUT',
            body: JSON.stringify(tankGroupData)
        });
    },
    
    // Delete tank group
    async delete(tankGroupId) {
        return await apiRequest(`/tank-groups/${tankGroupId}`, {
            method: 'DELETE'
        });
    },
    
    // Get tank group's tanks
    async getTanks(tankGroupId) {
        return await apiRequest(`/tank-groups/${tankGroupId}/tanks`);
    }
};

// Chat API functions (for Knowledge Hub)
const ChatAPI = {
    // Get all chat sessions
    async getSessions() {
        return await apiRequest('/chat/sessions');
    },
    
    // Create new chat session
    async createSession(sessionData) {
        return await apiRequest('/chat/sessions', {
            method: 'POST',
            body: JSON.stringify(sessionData)
        });
    },
    
    // Get session messages
    async getMessages(sessionId) {
        return await apiRequest(`/chat/sessions/${sessionId}/messages`);
    },
    
    // Send message to session
    async sendMessage(sessionId, messageData) {
        return await apiRequest(`/chat/sessions/${sessionId}/messages`, {
            method: 'POST',
            body: JSON.stringify(messageData)
        });
    },
    
    // Delete session (soft delete)
    async deleteSession(sessionId) {
        return await apiRequest(`/chat/sessions/${sessionId}`, {
            method: 'DELETE'
        });
    }
};

// Export all APIs for use in other scripts
window.API = {
    Customer: CustomerAPI,
    Plant: PlantAPI,
    Line: LineAPI,
    Product: ProductAPI,
    Requirement: RequirementAPI,
    Device: DeviceAPI,
    Function: FunctionAPI,
    Tank: TankAPI,
    TankGroup: TankGroupAPI,
    Chat: ChatAPI
};

// Utility functions for common operations
window.APIUtils = {
    handleApiError,
    showErrorMessage,
    showSuccessMessage,
    apiRequest
};
