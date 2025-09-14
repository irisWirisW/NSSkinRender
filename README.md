# SkinRenderKit

A Swift package for rendering Minecraft character skins in 3D using SceneKit and SwiftUI. This library provides easy-to-use SwiftUI views for displaying Minecraft character models with custom skin textures, including support for capes and dynamic animations.

## Features

- 🎮 3D Minecraft character rendering with SceneKit
- 🖼️ Support for custom skin textures (PNG format)
- 🧥 **Minecraft cape rendering with realistic thickness and animations**
- 🎯 SwiftUI integration with native views
- 📁 Built-in file picker for texture selection
- 🔄 Dynamic texture updating
- 👤 Includes default Steve skin texture
- 🎛️ Interactive 3D model controls (rotation, zoom)
- 🧍 Full support for both Steve and Alex (slim) skin formats
- ⚡ Direct NSImage texture support for in-memory images
- 🎬 Configurable rotation speed with real-time controls
- 🎨 Customizable background colors with interactive color picker
- 🌪️ **Dynamic cape swaying animation with wind effects**
- 🎪 **Outer layer visibility controls (hat, jacket, sleeves, pants)**
- 🎭 **Real-time model switching between Steve and Alex formats**

> **Note:** Supports both Steve format (classic 4-pixel wide arms) and Alex format (slim 3-pixel wide arms) skins with automatic format detection. Also includes **Minecraft cape rendering** with realistic 3D thickness, proper texture mapping, and dynamic swaying animations.

## Requirements

- macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SkinRenderKit to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/irisWirisW/NSSkinRender`
3. Select the version or branch you want to use
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/irisWirisW/NSSkinRender", from: "1.0.0")
]
```

## Usage

### Basic Usage

Import the library and use the basic skin render view:

```swift
import SwiftUI
import SkinRenderKit

struct ContentView: View {
    var body: some View {
        VStack {
            // Basic skin render view with default Steve texture
            SkinRenderView()
                .frame(width: 400, height: 300)

            // With custom background color
            SkinRenderView(backgroundColor: .blue)
                .frame(width: 400, height: 300)
        }
    }
}
```

### Custom Texture with Cape Support

Render a character with a custom skin texture and cape:

```swift
import SwiftUI
import SkinRenderKit

struct ContentView: View {
    var body: some View {
        VStack {
            // Render with custom texture path
            SkinRenderView(texturePath: "/path/to/your/skin.png")
                .frame(width: 400, height: 300)

            // Render with custom rotation speed and background color
            SkinRenderView(
                texturePath: "/path/to/your/skin.png",
                rotationDuration: 5.0,
                backgroundColor: .black
            )
            .frame(width: 400, height: 300)

            // Static view with custom background (no rotation)
            SkinRenderView(
                texturePath: "/path/to/your/skin.png",
                rotationDuration: 0.0,
                backgroundColor: NSColor.systemPurple
            )
            .frame(width: 400, height: 300)
        }
    }
}
```

**Cape Support:**
The library automatically looks for a cape texture file named `cap.png` in your app bundle or package resources. If found, it will be rendered with:
- Realistic 3D thickness (1.0 unit depth)
- Proper attachment to character shoulders
- Natural hanging physics simulation
- Dynamic swaying animation
- Interactive visibility controls

### Using NSImage Directly

For in-memory images or downloaded textures:

```swift
import SwiftUI
import SkinRenderKit

struct ContentView: View {
    @State private var skinImage: NSImage?

    var body: some View {
        VStack {
            if let skinImage = skinImage {
                // Render with NSImage directly and custom background
                SkinRenderView(
                    skinImage: skinImage,
                    rotationDuration: 10.0,
                    backgroundColor: .darkGray
                )
                .frame(width: 400, height: 300)
            }

            Button("Load Skin from Network") {
                loadSkinFromNetwork()
            }
        }
    }

    private func loadSkinFromNetwork() {
        // Example: Load skin from URL
        guard let url = URL(string: "https://example.com/skin.png") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.skinImage = image
                }
            }
        }.resume()
    }
}
```

### With File Picker

Use the built-in file picker to allow users to select skin textures:

```swift
import SwiftUI
import SkinRenderKit

struct ContentView: View {
    var body: some View {
        VStack {
            // Full view with file picker, rotation and background color controls
            SkinRenderViewWithPicker()
                .frame(width: 600, height: 500)

            // With custom initial settings
            SkinRenderViewWithPicker(
                rotationDuration: 8.0,
                backgroundColor: .systemBlue
            )
            .frame(width: 600, height: 500)
        }
    }
}
```

### Advanced Usage with NSViewController

For more control, including cape and animation management, you can use the underlying NSViewController directly:

```swift
import SwiftUI
import SkinRenderKit

struct ContentView: View {
    var body: some View {
        VStack {
            // Direct use of the representable view with full control
            SceneKitCharacterViewRepresentable(
                texturePath: "/path/to/skin.png",
                rotationDuration: 12.0,
                backgroundColor: .black
            )
            .frame(width: 500, height: 400)

            // Using NSImage directly with custom background
            if let skinImage = NSImage(named: "my_skin") {
                SceneKitCharacterViewRepresentable(
                    skinImage: skinImage,
                    rotationDuration: 6.0,
                    backgroundColor: NSColor.systemPurple
                )
                .frame(width: 500, height: 400)
            }
        }
    }
}
```

### Cape and Animation Control

The NSViewController provides advanced controls for cape and character customization:

```swift
import SkinRenderKit

class MyViewController: NSViewController {
    private var skinViewController: SceneKitCharacterViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the skin render view controller with custom settings
        skinViewController = SceneKitCharacterViewController(
            playerModel: .alex,
            rotationDuration: 8.0,
            backgroundColor: .darkGray
        )

        // Add it as a child view controller
        addChild(skinViewController)
        view.addSubview(skinViewController.view)

        // Update texture programmatically (file path)
        skinViewController.updateTexture(path: "/path/to/new/skin.png")

        // Update texture with NSImage
        if let newSkin = NSImage(named: "another_skin") {
            skinViewController.updateTexture(image: newSkin)
        }

        // Change rotation speed dynamically
        skinViewController.updateRotationDuration(15.0)

        // Update background color
        skinViewController.updateBackgroundColor(.systemBlue)
    }

    @IBAction func toggleRotation(_ sender: Any) {
        // Toggle between rotating and static
        let currentDuration = skinViewController.rotationDuration
        skinViewController.updateRotationDuration(currentDuration > 0 ? 0.0 : 10.0)
    }

    @IBAction func toggleCapeAnimation(_ sender: Any) {
        // Toggle cape swaying animation
        skinViewController.toggleCapeAnimation(true) // or false to disable
    }
}
```

## API Reference

### SkinRenderView

The main SwiftUI view for rendering Minecraft characters.

```swift
public struct SkinRenderView: View {
    public init(texturePath: String? = nil, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public init(skinImage: NSImage, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
}
```

**Parameters:**
- `texturePath`: Optional path to a custom skin texture file. If nil, uses the default Steve skin.
- `skinImage`: NSImage containing the skin texture for direct image input.
- `rotationDuration`: Duration for one full rotation in seconds. Use 0 for no rotation.
- `backgroundColor`: Background color for the 3D scene. Defaults to gray.

### SkinRenderViewWithPicker

A complete view that includes file picker functionality for selecting skin textures.

```swift
public struct SkinRenderViewWithPicker: View {
    public init(rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
}
```

**Parameters:**
- `rotationDuration`: Initial rotation duration. Users can adjust this with the built-in slider.
- `backgroundColor`: Initial background color. Users can adjust this with the built-in color picker.

Features:
- File picker button for selecting PNG/JPEG image files
- Display of selected file name
- Interactive rotation speed slider (0-15 seconds)
- Interactive background color picker
- Real-time rotation and color control with visual feedback
- Automatic texture application to the 3D model

### SceneKitCharacterViewRepresentable

SwiftUI representable wrapper for the underlying NSViewController.

```swift
public struct SceneKitCharacterViewRepresentable: NSViewControllerRepresentable {
    public init(texturePath: String? = nil, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public init(skinImage: NSImage, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
}
```

**Parameters:**
- `texturePath`: Optional path to a custom skin texture file.
- `skinImage`: NSImage containing the skin texture.
- `rotationDuration`: Duration for one full rotation in seconds.
- `backgroundColor`: Background color for the 3D scene.

### SceneKitCharacterViewController

The underlying NSViewController that handles 3D rendering with comprehensive cape and animation support.

```swift
public class SceneKitCharacterViewController: NSViewController {
    public convenience init(texturePath: String, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public convenience init(skinImage: NSImage, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public convenience init(playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)

    // Texture Management
    public func updateTexture(path: String)
    public func updateTexture(image: NSImage)

    // Appearance Controls
    public func updateRotationDuration(_ duration: TimeInterval)
    public func updateBackgroundColor(_ color: NSColor)

    // Cape Animation Control
    public func toggleCapeAnimation(_ enabled: Bool)

    // Built-in UI Controls (automatically added to view)
    // - "Hide/Show Outer Layers" button
    // - "Switch to Steve/Alex" button
    // - "Hide/Show Cape" button
    // - "Enable/Disable Animation" button
}
```

**Built-in Interactive Controls:**

The view controller automatically includes UI buttons for:

1. **Outer Layer Toggle** - Show/hide hat, jacket, sleeves, and pants
2. **Model Type Switch** - Toggle between Steve and Alex (slim) models
3. **Cape Visibility** - Show/hide the cape entirely
4. **Cape Animation** - Enable/disable the swaying animation

**Methods:**
- `updateTexture(path:)`: Updates the character's skin texture with a new image file
- `updateTexture(image:)`: Updates the character's skin texture with an NSImage
- `updateRotationDuration(_:)`: Changes the rotation speed dynamically
- `updateBackgroundColor(_:)`: Updates the 3D scene background color
- `toggleCapeAnimation(_:)`: Controls the cape swaying animation

## Supported Texture Formats

### Skin Textures
- PNG (recommended)
- JPEG
- Standard Minecraft skin format (64x64 or 64x32 pixels)

### Cape Textures
- PNG format (recommended for transparency support)
- Standard Minecraft cape format (64x32 pixels)
- Texture file should be named `cap.png` and placed in your app bundle or package resources
- Supports transparency for realistic cloth effects

**Cape Texture Mapping:**
The cape texture follows Minecraft's standard 64x32 pixel format:
- Back (outer) surface: x=1, y=1, width=10, height=16
- Front (inner) surface: x=11, y=1, width=10, height=16
- Side edges: x=0,21, y=1, width=1, height=16
- Top/bottom edges: x=1,11, y=0, width=10, height=1

> **Important:** This library supports both **Steve format** skins (classic 4-pixel wide arms) and **Alex format** skins (slim 3-pixel wide arms) with automatic format detection and proper rendering. **Cape rendering** includes realistic 3D thickness, proper shoulder attachment, and dynamic swaying animations.

## Cape System Details

### Cape Features

The cape system provides a comprehensive implementation of Minecraft-style capes with the following features:

**🏗️ Realistic 3D Structure**
- **Proper Thickness**: 1.0 unit depth (not a flat plane) for authentic appearance
- **Pivot-Based Attachment**: Cape hangs from a shoulder-level pivot point for natural physics
- **Dual-Node System**: Separate pivot and cape nodes for precise positioning control

**🎨 Enhanced Visual Quality**
- **Phong Lighting Model**: Realistic cloth-like material appearance with subtle shininess
- **Double-Sided Rendering**: Visible from both front and back for complete immersion
- **Transparency Support**: Automatic detection and handling of transparent cape designs
- **Anti-Z-Fighting**: Proper depth separation from character body

**🌪️ Dynamic Animation System**
- **Natural Swaying**: Smooth back-and-forth motion simulating wind effects
- **Multi-Axis Movement**: Combined X and Z rotation for realistic cloth behavior
- **Configurable Speed**: ~6.5 second cycle with smooth easing transitions
- **Interactive Control**: Real-time animation enable/disable via UI button

**⚙️ Technical Implementation**
- **Efficient Geometry**: SCNBox-based with optimized material mapping
- **Memory Optimized**: Single geometry instance with shared materials
- **Performance Conscious**: Minimal impact on frame rate even with animation
- **SceneKit Integration**: Full compatibility with scene lighting and camera controls

### Cape Texture Requirements

```
Cape Texture Format (64x32 pixels):
┌─────────────────────────────────┐
│  Top   │ Top    │               │  y=0
├────────┼────────┼───────────────┤
│ Left   │ Front  │ Right │ Back  │  y=1-16
│ Edge   │(Inner) │ Edge  │(Outer)│
│ x=0    │ x=1-10 │x=11   │x=12-21│
│ w=1    │ w=10   │ w=1   │ w=10  │
└────────┴────────┴───────┴───────┘
```

**Best Practices:**
- Use PNG format for transparency support
- Follow Minecraft's standard cape dimensions (10x16 game units)
- Design with back surface as the primary visible area
- Consider transparency for flowing or torn cape effects## Roadmap & TODO

### ✅ Completed
- [x] SwiftUI-based skin rendering with SceneKit integration
- [x] Steve format skin support with proper texture mapping
- [x] Alex format skin support with automatic format detection
- [x] Interactive 3D model controls (rotation, zoom, camera)
- [x] File picker integration for texture selection
- [x] Dynamic texture updating capabilities
- [x] Configurable rotation speed with real-time controls
- [x] Direct NSImage texture support for in-memory images
- [x] Dynamic rotation speed adjustment during runtime
- [x] **Complete cape rendering system with 3D thickness**
- [x] **Realistic cape physics with pivot-based attachment**
- [x] **Dynamic cape swaying animation with wind effects**
- [x] **Interactive UI controls for cape and outer layer visibility**
- [x] **Real-time model switching between Steve and Alex formats**
- [x] **Enhanced material system with Phong lighting for realistic appearance**

### 🚧 In Progress / Planned
- [ ] **AppKit integration** - Native AppKit views and controls for non-SwiftUI applications
- [ ] **Enhanced texture validation** - Better error handling and format detection
- [ ] **Performance optimizations** - Improved rendering performance for multiple models
- [ ] **Advanced animation support** - Character poses, walking animations, arm movements
- [ ] **Custom model variants** - Support for different character model variations
- [ ] **Physics-based cape simulation** - More realistic cloth physics with wind interaction
- [ ] **Multiple cape texture support** - Runtime cape texture switching
- [ ] **Accessory system** - Support for additional character accessories (hats, items, etc.)

## License

Distributed under the GNU Affero General Public License v3.0 (AGPL-3.0). See the `LICENSE` file for full details.

## Credits

- Built with Swift and SceneKit
- Includes default Steve skin texture from Minecraft
- Assisted by GitHub Copilot for code suggestions and documentation refinement