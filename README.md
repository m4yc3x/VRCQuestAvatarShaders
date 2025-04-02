# Quest-Compatible Shader Collection

A collection of optimized, mobile-friendly shaders designed specifically for VRChat Quest avatars. These shaders provide high-quality visual effects while maintaining performance on mobile VR platforms, focusing on creating unique material appearances like iridescence, glass, metals, and other special effects.

## Important Technical Note

All shaders in this collection are compiled under the `VRChat/Mobile/Particles/Additive` shader path to ensure compatibility with VRChat's Android SDK and Quest platform. This specific implementation allows the shaders to pass through VRChat's upload pipeline while maintaining their custom functionality.

## Features

### Visual Effects
- Dynamic fluid-like patterns and movements
- View-dependent effects (fresnel, reflections)
- Customizable color variations and highlights
- Organic pattern generation
- Realistic material simulation
- Adjustable emission and glow effects

### Performance Optimizations
- Mobile-optimized calculations
- Limited texture sampling
- Efficient use of shader operations
- Quest-compatible rendering paths
- Minimal draw call impact
- Memory-efficient property usage

### Customization
- Intuitive parameter controls
- Real-time adjustable effects
- Color property controls
- Pattern scale and speed adjustments
- Effect strength modifiers
- Blend and overlay options

## Common Parameters

### Base Properties
- Color controls for primary and accent colors
- Pattern scale adjustments
- Animation speed controls
- Effect strength modifiers
- Surface property adjustments (metallic, smoothness, etc.)

### Effect Properties
- View-based effect intensities
- Pattern generation controls
- Highlight and reflection strengths
- Edge effect modifiers
- Emission intensity controls

## Usage Tips

### General Setup
1. Import shaders into your Unity project
2. Create materials using desired shader variants
3. Apply materials to your meshes
4. Adjust parameters for desired appearance

### Optimization Tips
1. Start with default values and adjust gradually
2. Balance effect intensities for performance
3. Consider mesh complexity when applying effects
4. Monitor performance impact when layering effects

## Performance Considerations
- All shaders optimized for Quest/mobile VR
- Efficient calculation methods
- Mobile-friendly effect implementations
- Optimized for single-pass rendering
- Minimal vertex/fragment shader complexity

## Installation
1. Import the shader package into your Unity project
2. Create new materials using the shaders
3. Apply materials to your meshes
4. Adjust parameters to achieve desired effects

## Compatibility
- Unity 2019.4.31f1 and above
- VRChat SDK3 for Quest
- Android/Mobile VR platforms
- Standard RP compatible

## Technical Details
- Mobile-optimized shader code
- Efficient mathematical operations
- Limited texture sampling
- Optimized vertex/fragment operations
- Quest-compatible rendering features

## License
Free to use for personal and commercial projects. Please credit me!!!

## Credits
Created for the VRChat Quest community.
