/**
 * Tank Layout Renderer
 * 
 * Modular canvas-based tank layout visualization system
 * Can be used across different pages (sales, engineering, etc.)
 * 
 * Usage:
 * const renderer = new TankLayoutRenderer('canvasId');
 * renderer.drawLayout(tanks, options);
 */

class TankLayoutRenderer {
  constructor(canvasId, options = {}) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) {
      throw new Error(`Canvas element with id '${canvasId}' not found`);
    }
    
    this.ctx = this.canvas.getContext('2d');
    this.options = {
      theme: 'default', // 'sales', 'engineering', 'default'
      showGrid: true,
      showEditButtons: true,
      margin: 20, // Reduced margin for better space utilization
      minScale: 0.1,
      maxScale: 5, // Increased max scale for better detail when few tanks
      padding: 10, // Additional padding for tank details
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
        buttonHover: '#0056b3'
      },
      sales: {
        tankColor: '#113a4c',
        tankBorder: '#000000',
        textColor: 'white',
        gridColor: '#e0e0e0',
        buttonColor: '#113a4c',
        buttonHover: '#000000'
      },
      engineering: {
        tankColor: '#28a745',
        tankBorder: '#155724',
        textColor: 'white',
        gridColor: '#e0e0e0',
        buttonColor: '#28a745',
        buttonHover: '#1e7e34'
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
   * @param {Array} tanks - Array of tank objects
   * @param {Object} line - Line object (optional)
   * @param {Object} drawOptions - Additional drawing options
   */
  drawLayout(tanks, line = null, drawOptions = {}) {
    this.currentTanks = tanks;
    this.currentLine = line;
    this.editButtons = [];
    
    const options = { ...this.options, ...drawOptions };
    
    // Set canvas size
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
    if (options.showGrid) {
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
   * Resize canvas to fit container
   */
  resizeCanvas() {
    const container = this.canvas.parentElement;
    this.canvas.width = container.clientWidth - 4;
    this.canvas.height = container.clientHeight - 4;
  }
  
  /**
   * Calculate optimal scale for tanks
   */
  calculateScale(tanks) {
    if (tanks.length === 0) return 1;
    
    const totalWidth = this.calculateTotalWidth(tanks);
    const maxLength = Math.max(...tanks.map(t => t.length || 1000));
    
    const availableWidth = this.canvas.width - 2 * this.options.margin;
    const availableHeight = this.canvas.height - 2 * this.options.margin - 60; // Reserve space for details
    
    const scaleX = availableWidth / totalWidth;
    const scaleY = availableHeight / maxLength;
    
    // Use the more restrictive dimension but prefer larger scales for better detail
    let scale = Math.min(scaleX, scaleY);
    
    // Apply scaling limits
    scale = Math.max(scale, this.options.minScale);
    scale = Math.min(scale, this.options.maxScale);
    
    // For very small tank counts, use larger scale for better visibility
    if (tanks.length <= 3 && scale < 1.0) {
      scale = Math.min(scale * 1.5, this.options.maxScale);
    }
    
    return scale;
  }
  
  /**
   * Calculate total width of all tanks
   */
  calculateTotalWidth(tanks) {
    if (tanks.length === 0) return 0;
    return tanks.reduce((total, tank) => {
      return total + (tank.width || 1000) + (tank.space || 0);
    }, 0) - (tanks[tanks.length - 1].space || 0);
  }
  
  /**
   * Draw grid background
   */
  drawGrid(scale) {
    const theme = this.themes[this.options.theme];
    this.ctx.strokeStyle = theme.gridColor;
    this.ctx.lineWidth = 0.5;
    
    // Adaptive grid size based on scale
    let baseGridSize = 1000; // 1 meter in mm
    if (scale > 2) {
      baseGridSize = 500; // 0.5 meter grid for high zoom
    } else if (scale < 0.5) {
      baseGridSize = 2000; // 2 meter grid for low zoom
    }
    
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
      
      // Draw grid scale indicator
      this.drawGridScale(baseGridSize, scale);
    }
  }
  
  /**
   * Draw grid scale indicator
   */
  drawGridScale(baseGridSize, scale) {
    const theme = this.themes[this.options.theme];
    const scaleText = baseGridSize >= 1000 ? `${baseGridSize/1000}m` : `${baseGridSize}mm`;
    
    // Draw scale indicator in bottom-right corner
    const x = this.canvas.width - this.options.margin - 80;
    const y = this.canvas.height - this.options.margin - 20;
    
    // Background
    this.ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
    this.ctx.fillRect(x - 5, y - 15, 75, 20);
    
    // Border
    this.ctx.strokeStyle = theme.gridColor;
    this.ctx.lineWidth = 1;
    this.ctx.strokeRect(x - 5, y - 15, 75, 20);
    
    // Text
    this.ctx.fillStyle = '#666';
    this.ctx.font = '10px Arial';
    this.ctx.textAlign = 'left';
    this.ctx.fillText(`Grid: ${scaleText}`, x, y - 5);
  }
  
  /**
   * Draw all tanks
   */
  drawTanks(tanks, scale, hoveredTankId = null) {
    const totalWidth = this.calculateTotalWidth(tanks);
    const maxLength = Math.max(...tanks.map(t => t.length || 1000));
    const scaledTotalWidth = totalWidth * scale;
    const scaledMaxLength = maxLength * scale;
    
    // Calculate positioning to maximize space usage
    const availableWidth = this.canvas.width - 2 * this.options.margin;
    const availableHeight = this.canvas.height - 2 * this.options.margin - 60; // Reserve space for details
    
    // Start positions - center the layout but use available space efficiently
    const startX = this.options.margin + Math.max(0, (availableWidth - scaledTotalWidth) / 2);
    const centerY = this.options.margin + availableHeight / 2;
    
    let currentX = startX;
    tanks.forEach((tank) => {
      this.drawTank(currentX, centerY, tank, scale, hoveredTankId === tank.id);
      currentX += ((tank.width || 1000) + (tank.space || 0)) * scale;
    });
  }
  
  /**
   * Draw individual tank
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
    this.ctx.lineWidth = Math.max(1, scale * 0.5); // Scale-dependent border width
    this.ctx.strokeRect(x, y - length/2, width, length);
    
    // Calculate font sizes based on scale and tank size
    const baseFontSize = Math.min(16, Math.max(10, scale * 12));
    const detailFontSize = Math.min(12, Math.max(8, scale * 8));
    
    // Draw tank number (always visible)
    this.ctx.fillStyle = theme.textColor;
    this.ctx.font = `bold ${baseFontSize}px Arial`;
    this.ctx.textAlign = 'center';
    this.ctx.fillText(`${tank.number || '?'}`, x + width/2, y - baseFontSize/2);
    
    // Draw tank name (always visible)
    this.ctx.font = `${Math.max(baseFontSize - 2, 8)}px Arial`;
    this.ctx.fillText(tank.name || 'no name', x + width/2, y + baseFontSize/2);
    
    // Draw dimensions and edit button if tank is large enough
    if (width > 40 && length > 50 && this.options.showEditButtons) {
      this.drawTankDetails(x, y, tank, width, length, scale, isHovered, theme, detailFontSize);
    }
  }
  
  /**
   * Draw tank details and edit button
   */
  drawTankDetails(x, y, tank, width, length, scale, isHovered, theme, detailFontSize) {
    // Draw dimensions
    this.ctx.fillStyle = '#666';
    this.ctx.font = `${detailFontSize}px Arial`;
    this.ctx.fillText(`${tank.width || '?'}×${tank.length || '?'}mm`, x + width/2, y + length/2 - detailFontSize);
    
    // Draw Edit button (scaled based on tank size)
    const buttonY = y + length/2 + this.options.padding;
    const buttonWidth = Math.min(60, Math.max(30, width * 0.6));
    const buttonHeight = Math.min(25, Math.max(15, length * 0.1));
    const buttonX = x + width/2 - buttonWidth/2;
    
    // Button background
    this.ctx.fillStyle = isHovered ? theme.buttonHover : theme.buttonColor;
    this.ctx.fillRect(buttonX, buttonY, buttonWidth, buttonHeight);
    
    // Button border
    this.ctx.strokeStyle = isHovered ? theme.buttonHover : theme.buttonColor;
    this.ctx.lineWidth = isHovered ? 2 : 1;
    this.ctx.strokeRect(buttonX, buttonY, buttonWidth, buttonHeight);
    
    // Button text
    this.ctx.fillStyle = 'white';
    const buttonFontSize = Math.min(12, Math.max(8, buttonHeight * 0.6));
    this.ctx.font = isHovered ? `bold ${buttonFontSize}px Arial` : `${buttonFontSize}px Arial`;
    this.ctx.fillText('Edit', x + width/2, buttonY + buttonHeight/2 + buttonFontSize/3);
    
    // Store button for click detection
    this.editButtons.push({
      tankId: tank.id,
      x: buttonX,
      y: buttonY,
      width: buttonWidth,
      height: buttonHeight,
      tank: tank
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
    
    // Draw helpful message
    this.ctx.font = '14px Arial';
    this.ctx.fillStyle = '#999';
    this.ctx.fillText(
      'Tank layout will appear here when line contains tanks',
      this.canvas.width / 2,
      this.canvas.height / 2 + 20
    );
  }
  
  /**
   * Export current layout as image
   */
  exportAsImage(format = 'png') {
    return this.canvas.toDataURL(`image/${format}`);
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
