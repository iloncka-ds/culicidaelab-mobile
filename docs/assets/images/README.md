# Documentation Images

This directory contains all images used in the CulicidaeLab documentation, including screenshots, diagrams, and visual aids.

## Directory Structure

```
docs/assets/images/
├── screenshots/           # App interface screenshots
│   ├── android/          # Android-specific screenshots
│   ├── ios/              # iOS-specific screenshots
│   └── common/           # Cross-platform screenshots
├── diagrams/             # Flowcharts and process diagrams
├── examples/             # Example photos and comparisons
├── icons/                # UI icons and symbols
└── logos/                # App logos and branding
```

## Image Guidelines

### Screenshots
- **Format**: PNG for UI elements
- **Resolution**: Minimum 1080p
- **File Size**: Under 500KB each
- **Naming**: Descriptive kebab-case names

### Diagrams
- **Format**: SVG preferred, PNG acceptable
- **Style**: Consistent with app branding
- **Colors**: Use app color palette
- **Text**: Readable at various sizes

### Examples
- **Format**: JPEG for photos, PNG for UI
- **Quality**: High quality but web-optimized
- **Content**: Clear, relevant examples
- **Annotations**: Helpful callouts and highlights

## Required Images

### Home Screen and Navigation
- [ ] `home-screen-overview.png` - Complete home screen
- [ ] `bottom-navigation-bar.png` - Navigation bar with labels
- [ ] `language-selection.png` - Language menu dropdown
- [ ] `app-permissions.png` - Permission request dialogs

### Classification Feature
- [ ] `classification-empty-state.png` - Before image selection
- [ ] `camera-interface.png` - Camera viewfinder
- [ ] `image-analysis-progress.png` - AI processing indicator
- [ ] `classification-results.png` - Results with species info
- [ ] `disease-risks-modal.png` - Disease information modal

### Gallery and Species
- [ ] `species-gallery-grid.png` - Gallery grid view
- [ ] `species-search.png` - Search functionality
- [ ] `species-detail-page.png` - Detailed species information
- [ ] `species-comparison.png` - Side-by-side species comparison

### Disease Information
- [ ] `disease-list-view.png` - Disease information screen
- [ ] `disease-detail-page.png` - Individual disease details
- [ ] `disease-prevention-tips.png` - Prevention information
- [ ] `vector-species-info.png` - Vector species associations

### Troubleshooting
- [ ] `error-messages.png` - Common error dialogs
- [ ] `settings-permissions.png` - Device settings screens
- [ ] `app-performance-tips.png` - Performance optimization

### Photo Quality Examples
- [ ] `good-mosquito-photo.jpg` - Example of ideal photo
- [ ] `poor-mosquito-photo.jpg` - Example of poor quality photo
- [ ] `photo-composition-guide.png` - Annotated composition tips
- [ ] `lighting-examples.png` - Good vs poor lighting

### Process Diagrams
- [ ] `identification-workflow.svg` - Complete identification process
- [ ] `app-navigation-flow.svg` - User navigation paths
- [ ] `data-flow-diagram.svg` - How data moves through the app
- [ ] `disease-transmission-cycle.svg` - Vector-pathogen-host cycle

## Image Optimization

### Before Adding Images
1. **Resize**: Optimize for web display
2. **Compress**: Reduce file size without quality loss
3. **Format**: Choose appropriate format (PNG/JPEG/SVG)
4. **Alt Text**: Prepare descriptive alt text
5. **Captions**: Write informative captions

### Quality Checklist
- [ ] Image is clear and high resolution
- [ ] File size is optimized for web
- [ ] Alt text is descriptive and helpful
- [ ] Image adds value to documentation
- [ ] Consistent with visual style guide

## Accessibility

### Alt Text Guidelines
- Describe the content and purpose of the image
- Keep descriptions concise but informative
- Don't start with "Image of" or "Picture of"
- Include relevant context for understanding

### Visual Design
- Ensure sufficient color contrast
- Don't rely solely on color to convey information
- Make text in images readable
- Consider users with visual impairments

## Maintenance

### Regular Updates
- Update screenshots when app UI changes
- Refresh examples with better quality images
- Add new images for new features
- Remove outdated or irrelevant images

### Version Control
- Use descriptive commit messages for image changes
- Archive old versions before replacing
- Document reasons for image updates
- Maintain consistent naming conventions

## Contributing Images

### For Screenshots
1. Use clean device state (no notifications, full battery)
2. Consistent device orientation and settings
3. High resolution and good lighting
4. Include relevant UI elements only

### For Diagrams
1. Use consistent colors and fonts
2. Ensure text is readable at various sizes
3. Follow app branding guidelines
4. Export in appropriate format (SVG preferred)

### For Examples
1. Use high-quality, clear examples
2. Ensure examples are relevant and helpful
3. Include both good and poor examples where appropriate
4. Add annotations to highlight key points

## Tools and Resources

### Recommended Tools
- **Screenshot Tools**: Built-in device tools, browser dev tools
- **Image Editing**: GIMP, Photoshop, or similar
- **Diagram Creation**: Draw.io, Lucidchart, or similar
- **Optimization**: TinyPNG, ImageOptim, or similar

### Style Resources
- App color palette: Teal (#009688), Orange (#FF9800), Red (#F44336)
- Typography: Roboto font family
- Icon style: Material Design icons
- Spacing: 8px grid system

For questions about images or to contribute new visual content, please refer to the [Screenshots Guide](../user-guide/screenshots-guide.md) or contact the documentation team.