# John Cockerill Brand Guidelines
## Surface Treatment Plants - Customer Solution Designer

This document contains the essential brand guidelines for developing John Cockerill Surface Treatment Plants applications. All new pages and components should follow these guidelines to maintain brand consistency.

## Logo Usage

### Primary Logo
- **Official Logo URL**: `https://res.cloudinary.com/brandpad/image/upload/c_scale,dpr_auto,f_auto,w_512/v1551357514/2215/john_cockerill_logo_black_screen`
- **Alt Text**: "John Cockerill"
- **Recommended Size**: 60px height (minimum 40px for small screens)
- **File Format**: Use the official CDN link or download PNG/SVG for offline use

### Logo Placement Rules
- **Primary Position**: Bottom left corner of the page
- **Minimum Clear Space**: Equal to the height of the logo on all sides
- **Accompanying Text**: "Surface Treatment Plants" next to the logo
- **Text Style**: Black (#000000), font-weight: 600, font-size: 1.1rem

### Logo Implementation (CSS)
```css
.brand-footer {
  position: absolute;
  bottom: 30px;
  left: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.jc-logo {
  height: 60px;
  width: auto;
}

.brand-text {
  color: #000000;
  font-size: 1.1rem;
  font-weight: 600;
  letter-spacing: -0.01em;
}
```

## Color Palette

### Primary Colors
- **Black**: `#000000` - Main text, headings, primary buttons hover states
- **White**: `#ffffff` - Background, card backgrounds, text on dark backgrounds

### Accent Colors
- **John Cockerill Orange**: `#ff7331` - Primary accent, action elements, highlights
- **John Cockerill Blue**: `#113a4c` - Secondary accent, professional elements, subtitles
- **Light Blue**: `#9de2e7` - Tertiary accent, engineering sections, secondary buttons
- **Light Grey**: `#e5dddf` - Neutral accent, simulation sections, disabled states

### Color Usage Guidelines
- Use black and white as the foundation
- Orange (`#ff7331`) for primary call-to-action elements and accents
- Blue (`#113a4c`) for professional/business contexts (sales, subtitles)
- Light blue (`#9de2e7`) for technical/engineering contexts
- Light grey (`#e5dddf`) for neutral or pending features

### Button Color Mapping
```css
.btn-primary {
  background-color: #113a4c; /* John Cockerill Blue */
  border-color: #113a4c;
}

.btn-success {
  background-color: #ff7331; /* John Cockerill Orange */
  border-color: #ff7331;
}

.btn-secondary {
  background-color: #9de2e7; /* Light Blue */
  border-color: #9de2e7;
  color: #000000;
}

.btn-warning {
  background-color: #e5dddf; /* Light Grey */
  border-color: #e5dddf;
  color: #000000;
}
```

## Typography

### Font Family
- **Primary**: Arial, sans-serif
- **Alternative**: Use system fonts if Arial unavailable

### Typography Scale
- **Page Title**: 2.8rem, font-weight: 700, color: #000000
- **Page Subtitle**: 1.3rem, font-weight: 400, color: #113a4c
- **Card Title**: 1.6rem, font-weight: 700, color: white (on colored backgrounds)
- **Body Text**: 1rem, line-height: 1.6, color: #113a4c
- **Feature List**: 0.95rem, line-height: 1.4, color: #000000
- **Button Text**: 1.1rem, font-weight: 600

### Letter Spacing
- **Headings**: -0.02em (page title), -0.01em (card titles, brand text)
- **Body Text**: 0.01em (buttons), normal (paragraph text)

## Layout and Design Principles

### Container Structure
- **Main Container**: min-height: 100vh, padding: 40px 20px 120px 20px
- **Bottom Padding**: Extra 120px to accommodate logo area
- **Grid System**: Bootstrap 5.3.3 responsive grid

### Card Design
- **Border Radius**: 0 (no rounded corners - clean, professional look)
- **Shadow**: Subtle elevation with hover effects
- **Hover Animation**: translateY(-8px) with enhanced shadow
- **Background**: Pure white (#ffffff)

### Spacing Guidelines
- **Header Section**: 60px margin-bottom
- **Card Spacing**: Bootstrap g-4 (1.5rem gap)
- **Internal Padding**: 30px for card headers, 25-30px for card bodies

### Interactive Elements
- **Buttons**: Full width in cards, no border-radius, subtle hover animations
- **Cards**: Hover lift effect (translateY(-8px))
- **Transitions**: 0.3s ease for cards, 0.2s ease for buttons

## Content Guidelines

### Page Structure
1. **Header Section**: Centered, with title, subtitle, and accent line
2. **Main Content**: Grid layout with feature cards
3. **Brand Footer**: Logo and product line text in bottom left

### Accent Elements
```css
.accent-line {
  width: 60px;
  height: 4px;
  background: #ff7331;
  margin: 20px auto 0;
}
```

### Status Indicators
- **Coming Soon Badge**: rgba(0,0,0,0.2) background, white text
- **Available Features**: Use appropriate color-coded buttons

## Application-Specific Guidelines

### Surface Treatment Plants Context
- **Main Title**: "Customer Solution Designer"
- **Subtitle**: "From concept to production-ready surface treatment solutions"
- **Brand Text**: "Surface Treatment Plants"

### Feature Categories
- **Training**: Orange (#ff7331) header
- **Sales**: Blue (#113a4c) header  
- **Engineering**: Light Blue (#9de2e7) header
- **Simulation**: Light Grey (#e5dddf) header

## Implementation Checklist

When creating new pages, ensure:
- [ ] John Cockerill logo is present in bottom left
- [ ] Brand colors are used consistently
- [ ] No border-radius on cards and buttons
- [ ] Proper typography scale is applied
- [ ] Hover animations are implemented
- [ ] Adequate spacing around logo (clear space)
- [ ] Page title reflects "Surface Treatment Plants" context
- [ ] Clean, professional layout without unnecessary decorative elements

## File References
- **Brand Guidelines Source**: https://brandpad.io/john-cockerill-en/
- **Logo CDN**: https://res.cloudinary.com/brandpad/
- **Bootstrap Version**: 5.3.3
- **Reference Implementation**: `/static/index.html`

---
*Last Updated: July 11, 2025*
*For questions about brand compliance, refer to the official John Cockerill brand portal.*
