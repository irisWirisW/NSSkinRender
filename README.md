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

> **Note:** Currently only supports Steve format skins. Alex (slim) format support is planned for future releases.

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
            // Basic skin render view with default Alex texture
            SkinRenderView()
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
        }
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
            // Full view with file picker functionality
            SkinRenderViewWithPicker()
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
        // Direct use of the representable view
        SceneKitCharacterViewRepresentable(texturePath: "/path/to/skin.png")
            .frame(width: 500, height: 400)
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

        // Create the skin render view controller
        skinViewController = SceneKitCharacterViewController()

        // Add it as a child view controller
        addChild(skinViewController)
        view.addSubview(skinViewController.view)

        // Update texture programmatically
        skinViewController.updateTexture(path: "/path/to/new/skin.png")
    }
}
```

## API Reference

### SkinRenderView

The main SwiftUI view for rendering Minecraft characters.

```swift
public struct SkinRenderView: View {
    public init(texturePath: String? = nil)
}
```

**Parameters:**
- `texturePath`: Optional path to a custom skin texture file. If nil, uses the default Alex skin.

### SkinRenderViewWithPicker

A complete view that includes file picker functionality for selecting skin textures.

```swift
public struct SkinRenderViewWithPicker: View {
    public init()
}
```

Features:
- File picker button for selecting PNG/JPEG image files
- Display of selected file name
- Automatic texture application to the 3D model

### SceneKitCharacterViewRepresentable

SwiftUI representable wrapper for the underlying NSViewController.

```swift
public struct SceneKitCharacterViewRepresentable: NSViewControllerRepresentable {
    public init(texturePath: String? = nil)
}
```

### SceneKitCharacterViewController

The underlying NSViewController that handles 3D rendering.

```swift
public class SceneKitCharacterViewController: NSViewController {
    public convenience init(texturePath: String)
    public func updateTexture(path: String)
}
```

**Methods:**
- `updateTexture(path:)`: Updates the character's skin texture with a new image file

## Supported Texture Formats

- PNG (recommended)
- JPEG
- Standard Minecraft skin format (64x64 or 64x32 pixels)

> **Important:** This library currently supports only **Steve format** skins (classic 4-pixel wide arms). Alex format skins (slim 3-pixel wide arms) are not yet supported and may not render correctly. Support for Alex format is planned for future releases.

## Roadmap & TODO

### ✅ Completed
- SwiftUI-based skin rendering with SceneKit integration
- Steve format skin support with proper texture mapping
- Interactive 3D model controls (rotation, zoom, camera)
- File picker integration for texture selection
- Dynamic texture updating capabilities

### 🚧 In Progress / Planned
- [ ] **Alex format skin support** - Add support for slim (3-pixel wide) arm model
- [ ] **AppKit integration** - Native AppKit views and controls for non-SwiftUI applications
- [ ] **Enhanced texture validation** - Better error handling and format detection
- [ ] **Performance optimizations** - Improved rendering performance for multiple models
- [ ] **Animation support** - Character animations and poses
- [ ] **Custom model variants** - Support for different character model variations

## Example Projects

Examples and usage demonstrations can be found in the documentation and code comments within the package.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT License. See the LICENSE file for more info.

## Credits

- Built with Swift and SceneKit
- Includes default Steve skin texture from Minecraft