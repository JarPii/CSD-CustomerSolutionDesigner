/**
 * Tank Layout Renderer - Fixed Version
 * 
 * Optimized for basic line layout creation with:
 * - Larger, more readable text inside tanks
 * - Consistent edit button styling
 * - Horizontal scrolling for long lines (>6000mm)
 * - Simple tank display (no numbers, "no name" default)
 */

class TankLayoutRenderer {
  constructor(canvasId, options = {}) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) {
      throw new Error(`Canvas element with id '${canvasId}' not found`);
    }
    
    this.ctx = this.canvas.getContext('2d');
    this.options = {
      theme: 'sales',
      showGrid: true,
      showEditButtons: true,
      margin: 20,
      minScale: 0.1,
      maxScale: 5,
      padding: 10,
      fontSizeMultiplier: 1.5, // Larger fonts for better readability
      ...options
    };
    
    // Store current data for resize events
    this.currentTanks = [];
    this.currentLine = null;
    this.editButtons = [];
    this.lastHoveredButton = null;
    
    // Event handlers
    this.setupEventHandlers();
    
    // Theme configurations
    this.themes = {
      default: {
        tankColor: '#4a90e2',
        tankBorder: '#2c5282',
        textColor: 'white',
        gridColor: '#e0e0e0',
        buttonColor: '#007bff',
        buttonHover: '#0056b3',
        fontSize: 14,
      },
      sales: {
        tankColor: '#113a4c',
        tankBorder: '#000000',
        textColor: 'white',
        gridColor: '#e0e0e0',
        buttonColor: '#113a4c',
        buttonHover: '#000000',
        fontSize: 18, // Larger font for better readability
      },
      engineering: {
        tankColor: '#28a745',
        tankBorder: '#155724',
        textColor: 'white',
        gridColor: '#e0e0e0',
        buttonColor: '#28a745',
        buttonHover: '#1e7e34',
        fontSize: 12,
      }
    };
  }
  
  /**
   * Set up canvas event handlers
   */
  setupEventHandlers() {
    // Click handler for edit buttons
    this.canvas.onclick = (event) => {
      const rect = this.canvas.getBoundingClientRect();
      const x = event.clientX - rect.left;
      const y = event.clientY - rect.top;
      
      for (const button of this.editButtons) {
        if (x >= button.x && x <= button.x + button.width &&
            y >= button.y && y <= button.y + button.height) {
          this.onTankEdit(button.tank);
          break;
        }
      }
    };
    
    // Mouse move handler for hover effects
    this.canvas.onmousemove = (event) => {
      const rect = this.canvas.getBoundingClientRect();
      const x = event.clientX - rect.left;
      const y = event.clientY - rect.top;
      
      let overButton = false;
      let hoveredTankId = null;
      
      for (const button of this.editButtons) {
        if (x >= button.x && x <= button.x + button.width &&
            y >= button.y && y <= button.y + button.height) {
          overButton = true;
          hoveredTankId = button.tankId;
          
          if (this.lastHoveredButton !== button.tankId) {
            this.lastHoveredButton = button.tankId;
            this.redraw(hoveredTankId);
          }
          break;
        }
      }
      
      this.canvas.style.cursor = overButton ? 'pointer' : 'default';
      
      if (!overButton && this.lastHoveredButton) {
        this.redraw();
        this.lastHoveredButton = null;
      }
    };
    
    // Window resize handler
    window.addEventListener('resize', () => {
      if (this.currentTanks.length > 0) {
        setTimeout(() => this.redraw(), 100);
      }
    });
  }
  
  /**
   * Main drawing function
   */
  drawLayout(tanks, line = null, drawOptions = {}) {
    this.currentTanks = tanks;
    this.currentLine = line;
    this.editButtons = [];
    
    // Set canvas size with horizontal scrolling support
    this.resizeCanvas();
    
    if (tanks.length === 0) {
      this.drawEmptyState();
      return;
    }
    
    // Calculate layout
    const scale = this.calculateScale(tanks);
    
    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    // Draw components
    if (this.options.showGrid) {
      this.drawGrid(scale);
    }
    
    this.drawTanks(tanks, scale, drawOptions.hoveredTankId);
    
    // Call layout drawn callback
    if (this.onLayoutDrawn) {
      this.onLayoutDrawn(tanks, line);
    }
  }
  
  /**
   * Redraw current layout
   */
  redraw(hoveredTankId = null) {
    if (this.currentTanks.length > 0) {
      this.drawLayout(this.currentTanks, this.currentLine, { hoveredTankId });
    }
  }
  
  /**
   * Resize canvas with horizontal scrolling support for long lines
   */
  resizeCanvas() {
    const container = this.canvas.parentElement;
    
    // Calculate total width needed for the layout
    const tanks = this.currentTanks || [];
    const totalWidth = this.calculateTotalWidth(tanks);
    const scale = this.calculateScale(tanks);
    const requiredWidth = Math.max(
      container.clientWidth - 4,
      (totalWidth * scale) + (2 * this.options.margin) + 100 // Extra space for edit buttons
    );
    
    // Set canvas dimensions
    this.canvas.width = requiredWidth;
    this.canvas.height = container.clientHeight - 4;
    
    // Enable horizontal scrolling if line is longer than container
    if (requiredWidth > container.clientWidth) {
      container.style.overflowX = 'auto';
      container.style.overflowY = 'hidden';
    } else {
      container.style.overflow = 'hidden';
    }
  }
  
  /**
   * Calculate total width of all tanks
   */
  calculateTotalWidth(tanks) {
    return tanks.reduce((total, tank) => {
      return total + (tank.width || 1000) + (tank.spacing || 100);
    }, 0);
  }
  
  /**
   * Calculate optimal scale for tanks
   */
  calculateScale(tanks) {
    if (tanks.length === 0) return 1;
    
    const totalWidth = this.calculateTotalWidth(tanks);
    const maxLength = Math.max(...tanks.map(t => t.length || 1000));
    
    const availableWidth = this.canvas.width - 2 * this.options.margin;
    const availableHeight = this.canvas.height - 2 * this.options.margin - 100; // Reserve space for edit buttons
    
    const scaleForWidth = availableWidth / totalWidth;
    const scaleForHeight = availableHeight / maxLength;
    
    // Use the smaller scale to ensure everything fits, but respect min/max bounds
    const optimalScale = Math.min(scaleForWidth, scaleForHeight);
    return Math.max(this.options.minScale, Math.min(this.options.maxScale, optimalScale));
  }
  
  /**
   * Draw grid
   */
  drawGrid(scale) {
    const theme = this.themes[this.options.theme];
    this.ctx.strokeStyle = theme.gridColor;
    this.ctx.lineWidth = 1;
    
    // Dynamic grid size based on scale
    const baseGridSize = scale > 0.5 ? 500 : scale > 0.2 ? 1000 : 2000;
    const gridSize = baseGridSize * scale;
    
    // Only draw grid if it's visible enough
    if (gridSize > 5) {
      // Vertical lines
      for (let x = this.options.margin; x <= this.canvas.width - this.options.margin; x += gridSize) {
        this.ctx.beginPath();
        this.ctx.moveTo(x, this.options.margin);
        this.ctx.lineTo(x, this.canvas.height - this.options.margin);
        this.ctx.stroke();
      }
      
      // Horizontal lines
      for (let y = this.options.margin; y <= this.canvas.height - this.options.margin; y += gridSize) {
        this.ctx.beginPath();
        this.ctx.moveTo(this.options.margin, y);
        this.ctx.lineTo(this.canvas.width - this.options.margin, y);
        this.ctx.stroke();
      }
    }
  }
  
  /**
   * Draw all tanks
   */
  drawTanks(tanks, scale, hoveredTankId = null) {
    const totalWidth = this.calculateTotalWidth(tanks);
    const scaledTotalWidth = totalWidth * scale;
    
    // Calculate positioning
    const availableWidth = this.canvas.width - 2 * this.options.margin;
    const availableHeight = this.canvas.height - 2 * this.options.margin - 80; // Reserve space for edit buttons
    
    // Start positions
    const startX = this.options.margin + Math.max(0, (availableWidth - scaledTotalWidth) / 2);
    const centerY = this.options.margin + availableHeight / 2;
    
    let currentX = startX;
    tanks.forEach((tank) => {
      this.drawTank(currentX, centerY, tank, scale, hoveredTankId === tank.id);
      currentX += ((tank.width || 1000) + (tank.spacing || 100)) * scale;
    });
  }
  
  /**
   * Draw individual tank with large, readable text
   */
  drawTank(x, y, tank, scale, isHovered = false) {
    const theme = this.themes[this.options.theme];
    const width = (tank.width || 1000) * scale;
    const length = (tank.length || 1000) * scale;

    // Draw tank rectangle (centered vertically on y position)
    this.ctx.fillStyle = theme.tankColor;
    this.ctx.fillRect(x, y - length/2, width, length);

    // Draw tank border
    this.ctx.strokeStyle = theme.tankBorder;
    this.ctx.lineWidth = Math.max(1, scale * 0.5);
    this.ctx.strokeRect(x, y - length/2, width, length);

    // Calculate font sizes - much larger for better readability
    const nameFont = Math.min(28, Math.max(16, scale * theme.fontSize * this.options.fontSizeMultiplier));
    const detailFont = Math.min(18, Math.max(12, scale * theme.fontSize * this.options.fontSizeMultiplier * 0.8));

    // Draw tank name (large and prominent)
    this.ctx.fillStyle = theme.textColor;
    this.ctx.font = `bold ${nameFont}px Arial`;
    this.ctx.textAlign = 'center';
    this.ctx.fillText(tank.name || 'no name', x + width/2, y - nameFont/3);

    // Draw dimensions below name (if there's space)
    if (width > 80 && length > 80) {
      this.ctx.font = `${detailFont}px Arial`;
      this.ctx.fillStyle = theme.textColor;
      const dimensionText = `${tank.width || '?'} × ${tank.length || '?'} mm`;
      this.ctx.fillText(dimensionText, x + width/2, y + nameFont/2);
    }

    // Draw edit button if tank is large enough
    if (width > 60 && length > 60 && this.options.showEditButtons) {
      this.drawTankEditButton(x, y, tank, width, length, scale, isHovered, theme);
    }
  }
  
  /**
   * Draw tank edit button with consistent styling
   */
  drawTankEditButton(x, y, tank, width, length, scale, isHovered, theme) {
    // Button position - below the tank
    const buttonY = y + length/2 + 15;
    const buttonWidth = 80;
    const buttonHeight = 32;
    const buttonX = x + width/2 - buttonWidth/2;
    
    // Button background
    this.ctx.fillStyle = isHovered ? theme.buttonHover : theme.buttonColor;
    this.ctx.fillRect(buttonX, buttonY, buttonWidth, buttonHeight);
    
    // Button border
    this.ctx.strokeStyle = isHovered ? theme.buttonHover : theme.buttonColor;
    this.ctx.lineWidth = 1;
    this.ctx.strokeRect(buttonX, buttonY, buttonWidth, buttonHeight);
    
    // Button text
    this.ctx.fillStyle = 'white';
    this.ctx.font = 'bold 14px Arial';
    this.ctx.textAlign = 'center';
    this.ctx.fillText('Edit', buttonX + buttonWidth/2, buttonY + buttonHeight/2 + 5);
    
    // Store button for click handling
    this.editButtons.push({
      x: buttonX,
      y: buttonY,
      width: buttonWidth,
      height: buttonHeight,
      tank: tank,
      tankId: tank.id
    });
  }
  
  /**
   * Draw empty state message
   */
  drawEmptyState() {
    this.ctx.fillStyle = '#666';
    this.ctx.font = '20px Arial';
    this.ctx.textAlign = 'center';
    this.ctx.fillText(
      'No tanks found for this line',
      this.canvas.width / 2,
      this.canvas.height / 2 - 10
    );
    
    this.ctx.font = '14px Arial';
    this.ctx.fillStyle = '#999';
    this.ctx.fillText(
      'Create tanks to see the layout here',
      this.canvas.width / 2,
      this.canvas.height / 2 + 20
    );
  }
  
  /**
   * Set theme
   */
  setTheme(theme) {
    if (this.themes[theme]) {
      this.options.theme = theme;
      this.redraw();
    }
  }
  
  /**
   * Export as image
   */
  exportAsImage(format = 'png') {
    return this.canvas.toDataURL(`image/${format}`);
  }
  
  /**
   * Event callbacks - override these in your implementation
   */
  onTankEdit(tank) {
    console.log('Tank edit requested:', tank);
  }
  
  onLayoutDrawn(tanks, line) {
    console.log('Layout drawn:', tanks.length, 'tanks');
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = TankLayoutRenderer;
} else if (typeof window !== 'undefined') {
  window.TankLayoutRenderer = TankLayoutRenderer;
}
