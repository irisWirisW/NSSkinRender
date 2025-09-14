//
//  SceneKitCharacterViewRepresentable.swift
//  SkinRenderKit
//
//  SwiftUI representation layer for Minecraft character skin rendering
//

import AppKit
import SwiftUI
internal import UniformTypeIdentifiers

/// SwiftUI bridge for wrapping NSViewController to render Minecraft character skins
/// This representable allows integration of SceneKit-based character rendering into SwiftUI views
public struct SceneKitCharacterViewRepresentable: NSViewControllerRepresentable {
  /// Optional path to the texture file for the character skin
  let texturePath: String?
  /// Optional NSImage for direct texture input
  let skinImage: NSImage?
  /// Rotation duration for character animation (0 = no rotation)
  let rotationDuration: TimeInterval
  /// Background color for the 3D scene
  let backgroundColor: NSColor

  /// Initialize the representable with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(texturePath: String? = nil, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  /// Initialize the representable with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(skinImage: NSImage, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self.texturePath = nil
    self.skinImage = skinImage
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  /// Create the underlying NSViewController for character rendering
  /// - Parameter context: SwiftUI representable context
  /// - Returns: Configured SceneKitCharacterViewController instance
  public func makeNSViewController(context: Context) -> SceneKitCharacterViewController {
    if let skinImage = skinImage {
      return SceneKitCharacterViewController(
        skinImage: skinImage,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
    } else if let texturePath = texturePath {
      return SceneKitCharacterViewController(
        texturePath: texturePath,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
    } else {
      return SceneKitCharacterViewController(
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
    }
  }

  /// Update the NSViewController when SwiftUI state changes
  /// - Parameters:
  ///   - nsViewController: The view controller to update
  ///   - context: SwiftUI representable context
  public func updateNSViewController(
    _ nsViewController: SceneKitCharacterViewController,
    context: Context
  ) {
    // Update texture when skinImage or texturePath changes
    if let skinImage = skinImage {
      nsViewController.updateTexture(image: skinImage)
    } else if let texturePath = texturePath {
      nsViewController.updateTexture(path: texturePath)
    }

    // Update rotation speed
    nsViewController.updateRotationDuration(rotationDuration)

    // Update background color
    nsViewController.updateBackgroundColor(backgroundColor)
  }
}

/// Main SwiftUI View for rendering Minecraft character skins
/// Provides a simple interface for displaying character models with optional texture customization
public struct SkinRenderView: View {
  /// Optional path to the texture file for the character skin
  let texturePath: String?
  /// Optional NSImage for direct texture input
  let skinImage: NSImage?
  /// Rotation duration for character animation (0 = no rotation)
  let rotationDuration: TimeInterval
  /// Background color for the 3D scene
  let backgroundColor: NSColor

  /// Initialize the skin render view with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(texturePath: String? = nil, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  /// Initialize the skin render view with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(skinImage: NSImage, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self.texturePath = nil
    self.skinImage = skinImage
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  public var body: some View {
    if let skinImage = skinImage {
      SceneKitCharacterViewRepresentable(
        skinImage: skinImage,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
      .frame(minWidth: 400, minHeight: 300)
    } else {
      SceneKitCharacterViewRepresentable(
        texturePath: texturePath,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
      .frame(minWidth: 400, minHeight: 300)
    }
  }
}

/// Complete view with file selection functionality for choosing skin textures
/// Combines the skin render view with a file picker interface for easy texture selection
public struct SkinRenderViewWithPicker: View {
  /// Currently selected texture file path
  @State private var selectedTexturePath: String?
  /// Controls the visibility of the file picker dialog
  @State private var showingFilePicker = false
  /// Rotation duration for character animation (0 = no rotation)
  @State private var rotationDuration: TimeInterval
  /// Background color for the 3D scene
  @State private var backgroundColor: NSColor

  /// Initialize the view with file picker functionality
  /// - Parameters:
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self._rotationDuration = State(initialValue: rotationDuration)
    self._backgroundColor = State(initialValue: backgroundColor)
  }

  public var body: some View {
    VStack {
      HStack {
        Button("Select Texture File") {
          showFileImporter()
        }
        .padding()

        if let path = selectedTexturePath {
          Text("Selected: \(URL(fileURLWithPath: path).lastPathComponent)")
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .truncationMode(.middle)
        }

        Spacer()
      }

      // Rotation speed control
      HStack {
        Text("Rotation Speed:")
          .font(.caption)

        Slider(value: $rotationDuration, in: 0...15, step: 1) {
          Text("Rotation Duration")
        }
        .frame(width: 300)

        Text(rotationDuration == 0 ? "Static" : String(format: "%.1fs", rotationDuration))
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(width: 50, alignment: .leading)
      }
      .padding(.horizontal)

      // Background color control
      HStack {
        Text("Background Color:")
          .font(.caption)

        ColorPicker("", selection: Binding(
          get: { Color(backgroundColor) },
          set: { backgroundColor = NSColor($0) }
        ))
        .frame(width: 50)
        .labelsHidden()

        Spacer()
      }
      .padding(.horizontal)

      SkinRenderView(
        texturePath: selectedTexturePath,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor
      )
    }
  }

  /// Display file picker for selecting texture files
  /// Opens a native macOS file picker filtered for image files
  private func showFileImporter() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.png, .jpeg, .image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.prompt = "Select"
    panel.message = "Choose a Minecraft skin texture file"

    panel.begin { response in
      if response == .OK, let url = panel.url {
        selectedTexturePath = url.path
      }
    }
  }
}
