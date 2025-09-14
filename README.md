# SkinRenderKit

A Swift package for rendering Minecraft character skins in 3D using SceneKit and SwiftUI. This library provides easy-to-use SwiftUI views for displaying Minecraft character models with custom skin textures.

## Features

- 🎮 3D Minecraft character rendering with SceneKit
- 🖼️ Support for custom skin textures (PNG format)
- 🎯 SwiftUI integration with native views
- 📁 Built-in file picker for texture selection
- 🔄 Dynamic texture updating
- 👤 Includes default Steve skin texture
- 🎛️ Interactive 3D model controls (rotation, zoom)
- 🧍 Full support for both Steve and Alex (slim) skin formats
- ⚡ Direct NSImage texture support for in-memory images
- 🎬 Configurable rotation speed with real-time controls
- 🎨 Customizable background colors with interactive color picker

> **Note:** Supports both Steve format (classic 4-pixel wide arms) and Alex format (slim 3-pixel wide arms) skins with automatic format detection.

## Requirements

- macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SkinRenderKit to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/your-username/SkinRenderKit.git`
3. Select the version or branch you want to use
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SkinRenderKit.git", from: "1.0.0")
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

### Custom Texture

Render a character with a custom skin texture:

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

For more control, you can use the underlying NSViewController directly:

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

### Programmatic Texture Updates

You can also work with the view controller directly for dynamic updates:

```swift
import SkinRenderKit

class MyViewController: NSViewController {
    private var skinViewController: SceneKitCharacterViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the skin render view controller with custom rotation
        skinViewController = SceneKitCharacterViewController(
            playerModel: .alex,
            rotationDuration: 8.0
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
    }

    @IBAction func toggleRotation(_ sender: Any) {
        // Toggle between rotating and static
        let currentDuration = skinViewController.rotationDuration
        skinViewController.updateRotationDuration(currentDuration > 0 ? 0.0 : 10.0)
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

The underlying NSViewController that handles 3D rendering.

```swift
public class SceneKitCharacterViewController: NSViewController {
    public convenience init(texturePath: String, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public convenience init(skinImage: NSImage, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)
    public convenience init(playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray)

    public func updateTexture(path: String)
    public func updateTexture(image: NSImage)
    public func updateRotationDuration(_ duration: TimeInterval)
    public func updateBackgroundColor(_ color: NSColor)
}
```

**Methods:**
- `updateTexture(path:)`: Updates the character's skin texture with a new image file
- `updateTexture(image:)`: Updates the character's skin texture with an NSImage
- `updateRotationDuration(_:)`: Changes the rotation speed dynamically

## Supported Texture Formats

- PNG (recommended)
- JPEG
- Standard Minecraft skin format (64x64 or 64x32 pixels)

> **Important:** This library supports both **Steve format** skins (classic 4-pixel wide arms) and **Alex format** skins (slim 3-pixel wide arms) with automatic format detection and proper rendering.

## Roadmap & TODO

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

### 🚧 In Progress / Planned
- [ ] **AppKit integration** - Native AppKit views and controls for non-SwiftUI applications
- [ ] **Enhanced texture validation** - Better error handling and format detection
- [ ] **Performance optimizations** - Improved rendering performance for multiple models
- [ ] **Animation support** - Character animations and poses
- [ ] **Custom model variants** - Support for different character model variations

## License

Distributed under the GNU Affero General Public License v3.0 (AGPL-3.0). See the `LICENSE` file for full details.

## Credits

- Built with Swift and SceneKit
- Includes default Steve skin texture from Minecraft
- Assisted by GitHub Copilot for code suggestions and documentation refinement