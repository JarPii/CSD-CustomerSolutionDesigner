/**
 * Universal Header System for STL Project
 * 
 * Usage: Include this script and call createHeader() with theme and page info
 * Themes: sales, engineering, training, simulation
 */

// Theme configurations
const HEADER_THEMES = {
    sales: {
        primary: '#113a4c',
        primaryDark: '#0d2a3a',
        text: 'white',
        name: 'Sales'
    },
    engineering: {
        primary: '#9de2e7',
        primaryDark: '#7dd5db', 
        text: '#000000',
        name: 'Design'
    },
    training: {
        primary: '#ff7331',
        primaryDark: '#e65a1c',
        text: 'white',
        name: 'Training'
    },
    simulation: {
        primary: '#e5dddf',
        primaryDark: '#d9d0d3',
        text: '#000000',
        name: 'Simulation'
    },
    default: {
        primary: '#113a4c',
        primaryDark: '#0d2a3a',
        text: 'white',
        name: 'System'
    }
};

// Page-specific configurations
const PAGE_CONFIGS = {
    'sales.html': {
        title: 'Customer\'s Plant Manager',
        subtitle: 'Customer and production facility management',
        icon: 'bi-buildings'
    },
    'engineering.html': {
        title: 'Design',
        subtitle: 'Design and layout management',
        icon: 'bi-tools'
    },
    'customer-plant-selection.html': {
        title: 'Customer & Plant',
        subtitle: 'Select customer and plant for your work',
        icon: 'bi-buildings'
    },
    'treatment-programs.html': {
        title: 'Treatment Programs Manager', 
        subtitle: 'Manage treatment programs for your selected plant',
        icon: 'bi-table'
    },
    'plant_layout.html': {
        title: 'Plant Layout Designer',
        subtitle: 'Design and configure production line layouts',
        icon: 'bi-diagram-3'
    },
    'basic-line-layout.html': {
        title: 'Basic Line & Layout',
        subtitle: 'Design basic production line layouts and tank positioning',
        icon: 'bi-grid-3x3-gap'
    },
    'knowledge-hub.html': {
        title: 'Knowledge Hub',
        subtitle: 'AI-powered technical assistant for surface treatment plants',
        icon: 'bi-lightbulb'
    },
    'simulation.html': {
        title: 'Simulation',
        subtitle: 'Production process simulation and optimization',
        icon: 'bi-graph-up'
    }
};

/**
 * Create standardized header
 * @param {Object} options - Header configuration
 * @param {string} options.theme - Theme name (sales, engineering, training, simulation)
 * @param {string} options.pageTitle - Custom page title (optional)
 * @param {string} options.pageSubtitle - Custom page subtitle (optional)  
 * @param {string} options.pageIcon - Custom icon class (optional)
 * @param {string} options.backUrl - Custom back URL (optional)
 */
function createHeader(options = {}) {
    // Get theme from URL parameters if not provided
    const urlParams = new URLSearchParams(window.location.search);
    const theme = options.theme || urlParams.get('theme') || 'default';
    const themeConfig = HEADER_THEMES[theme] || HEADER_THEMES.default;
    
    // Get current page configuration
    const currentPage = window.location.pathname.split('/').pop();
    const pageConfig = PAGE_CONFIGS[currentPage] || {};
    
    console.log('Current page:', currentPage);
    console.log('Page config:', pageConfig);
    
    // Use provided options or fall back to page config or defaults
    const title = options.pageTitle || pageConfig.title || 'STL System';
    const subtitle = options.pageSubtitle || pageConfig.subtitle || 'Surface Treatment Line Management';
    const icon = options.pageIcon || pageConfig.icon || 'bi-gear-fill';
    
    console.log('Final values - Title:', title, 'Icon:', icon);
    
    // Create header HTML
    const headerHTML = `
        <div class="universal-header" style="
            background: linear-gradient(135deg, ${themeConfig.primary} 0%, ${themeConfig.primaryDark} 100%);
            color: ${themeConfig.text};
            padding: 2rem 0;
            margin-bottom: 2rem;
        ">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col">
                        <h1 class="universal-header-title" style="
                            font-size: 2.5rem;
                            color: ${themeConfig.text};
                            margin-bottom: 10px;
                            font-weight: 700;
                            letter-spacing: -0.02em;
                        ">
                            <i class="${icon} me-2"></i>
                            ${title}
                        </h1>
                        <p class="universal-header-subtitle" style="
                            font-size: 1.2rem;
                            color: ${themeConfig.text === 'white' ? 'rgba(255, 255, 255, 0.85)' : 'rgba(0, 0, 0, 0.7)'};
                            margin-bottom: 0;
                            font-weight: 400;
                        ">
                            ${subtitle}
                        </p>
                    </div>
                    <div class="col-auto">
                        <button id="universal-back-btn" class="btn btn-outline-light universal-back-btn" style="
                            border-color: ${themeConfig.text === 'white' ? 'rgba(255, 255, 255, 0.5)' : 'rgba(0, 0, 0, 0.3)'};
                            color: ${themeConfig.text};
                        ">
                            <i class="bi bi-arrow-left me-1"></i> Back
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Insert header at the beginning of body
    document.body.insertAdjacentHTML('afterbegin', headerHTML);
    // Back-napin universaali toiminnallisuus
    setTimeout(function() {
        const backBtn = document.getElementById('universal-back-btn');
        if (backBtn) {
            if (typeof options.onBack === 'function') {
                backBtn.onclick = function(e) { e.preventDefault(); options.onBack(); };
            } else if (typeof options.backUrl === 'string') {
                backBtn.onclick = function(e) { e.preventDefault(); window.location.href = options.backUrl; };
            } else {
                backBtn.onclick = function(e) {
                    e.preventDefault();
                    // Hierarkinen paluu: jos historiaa on, käytä sitä, muuten etusivulle
                    if (document.referrer && document.referrer !== window.location.href) {
                        window.history.back();
                        // Tarkistus: jos paluu ei muuta sivua, ohjaa etusivulle
                        setTimeout(function() {
                            if (window.location.pathname === location.pathname) {
                                window.location.href = '/static/index.html';
                            }
                        }, 500);
                    } else {
                        window.location.href = '/static/index.html';
                    }
                };
            }
        }
    }, 50);
    
    // Apply theme CSS variables to root for other components
    const root = document.documentElement;
    root.style.setProperty('--theme-primary', themeConfig.primary);
    root.style.setProperty('--theme-primary-dark', themeConfig.primaryDark);
    root.style.setProperty('--theme-text', themeConfig.text);
    
    // Update page title
    if (themeConfig.name !== 'System') {
        document.title = `${title} - ${themeConfig.name} Context`;
    }
}

/**
 * Universal back navigation
 * @param {string} theme - Current theme to determine back destination
 */
function universalGoBack(theme) {
    // Map themes to their main pages
    const themePages = {
        sales: '/static/sales.html',
        engineering: '/static/engineering.html', 
        training: '/static/training.html',
        simulation: '/static/simulation.html'
    };
    
    const currentPath = window.location.pathname;
    
    // If we're on a main page (sales, engineering, etc.), go to index
    if (currentPath === '/static/sales.html' || 
        currentPath === '/static/engineering.html' ||
        currentPath === '/static/training.html' ||
        currentPath === '/static/simulation.html' ||
        currentPath === '/static/knowledge-hub.html') {
        window.location.href = '/static/index.html';
        return;
    }
    
    // If we have a known theme and we're on a sub-page, go to that theme's main page
    if (theme && themePages[theme]) {
        window.location.href = themePages[theme];
    } else {
        // Fallback to browser history
        history.back();
    }
}

/**
 * Initialize header on page load
 * Can be called manually or automatically
 */
function initializeHeader(options = {}) {
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => createHeader(options));
    } else {
        createHeader(options);
    }
}
