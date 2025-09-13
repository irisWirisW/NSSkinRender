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

  /// Initialize the representable with an optional texture path
  /// - Parameter texturePath: Path to the Minecraft skin texture file
  public init(texturePath: String? = nil) {
    self.texturePath = texturePath
  }

  /// Create the underlying NSViewController for character rendering
  /// - Parameter context: SwiftUI representable context
  /// - Returns: Configured SceneKitCharacterViewController instance
  public func makeNSViewController(context: Context) -> SceneKitCharacterViewController {
    if let texturePath = texturePath {
      return SceneKitCharacterViewController(texturePath: texturePath)
    } else {
      return SceneKitCharacterViewController()
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
    // Update texture when texturePath changes
    if let texturePath = texturePath {
      nsViewController.updateTexture(path: texturePath)
    }
  }
}

/// Main SwiftUI View for rendering Minecraft character skins
/// Provides a simple interface for displaying character models with optional texture customization
public struct SkinRenderView: View {
  /// Optional path to the texture file for the character skin
  let texturePath: String?

  /// Initialize the skin render view with an optional texture path
  /// - Parameter texturePath: Path to the Minecraft skin texture file
  public init(texturePath: String? = nil) {
    self.texturePath = texturePath
  }

  public var body: some View {
    SceneKitCharacterViewRepresentable(texturePath: texturePath)
      .frame(minWidth: 400, minHeight: 300)
  }
}

/// Complete view with file selection functionality for choosing skin textures
/// Combines the skin render view with a file picker interface for easy texture selection
public struct SkinRenderViewWithPicker: View {
  /// Currently selected texture file path
  @State private var selectedTexturePath: String?
  /// Controls the visibility of the file picker dialog
  @State private var showingFilePicker = false

  /// Initialize the view with file picker functionality
  public init() {}

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

      SkinRenderView(texturePath: selectedTexturePath)
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
