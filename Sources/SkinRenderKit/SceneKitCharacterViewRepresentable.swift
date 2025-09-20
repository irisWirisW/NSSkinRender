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
  /// Optional path to the cape texture file
  let capeTexturePath: String?
  /// Optional NSImage for direct cape texture input
  let capeImage: NSImage?
  /// Player model type (Steve/Alex)
  let playerModel: PlayerModel
  /// Rotation duration for character animation (0 = no rotation)
  let rotationDuration: TimeInterval
  /// Background color for the 3D scene
  let backgroundColor: NSColor
  /// Whether to show control buttons (toggle layers, model type, etc.)
  let showButtons: Bool

  /// Initialize the representable with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeTexturePath: Optional path to the cape texture file
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - showButtons: Whether to show control buttons (default: true)
  public init(texturePath: String? = nil, capeTexturePath: String? = nil, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray, showButtons: Bool = true) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.capeTexturePath = capeTexturePath
    self.capeImage = nil
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.showButtons = showButtons
  }

  /// Initialize the representable with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - capeImage: Optional NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - showButtons: Whether to show control buttons (default: true)
  public init(skinImage: NSImage, capeImage: NSImage? = nil, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray, showButtons: Bool = true) {
    self.texturePath = nil
    self.skinImage = skinImage
    self.capeTexturePath = nil
    self.capeImage = capeImage
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.showButtons = showButtons
  }

  /// Initialize the representable with mixed texture inputs
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeImage: NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - showButtons: Whether to show control buttons (default: true)
  public init(texturePath: String? = nil, capeImage: NSImage, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray, showButtons: Bool = true) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.capeTexturePath = nil
    self.capeImage = capeImage
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.showButtons = showButtons
  }

  /// Create the underlying NSViewController for character rendering
  /// - Parameter context: SwiftUI representable context
  /// - Returns: Configured SceneKitCharacterViewController instance
  public func makeNSViewController(context: Context) -> SceneKitCharacterViewController {
    if let skinImage = skinImage {
      return SceneKitCharacterViewController(
        skinImage: skinImage,
        capeImage: capeImage,
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        showButtons: showButtons
      )
    } else if let texturePath = texturePath {
      return SceneKitCharacterViewController(
        texturePath: texturePath,
        capeTexturePath: capeTexturePath,
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        showButtons: showButtons
      )
    } else if let capeImage = capeImage {
      // Only cape image provided
      let controller = SceneKitCharacterViewController(
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        showButtons: showButtons
      )
      controller.updateCapeTexture(image: capeImage)
      return controller
    } else {
      return SceneKitCharacterViewController(
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        showButtons: showButtons
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
    // Update player model
    nsViewController.updatePlayerModel(playerModel)

    // Update button visibility
    nsViewController.updateShowButtons(showButtons)

    // Update texture when skinImage or texturePath changes
    if let skinImage = skinImage {
      nsViewController.updateTexture(image: skinImage)
    } else if let texturePath = texturePath {
      nsViewController.updateTexture(path: texturePath)
    }

    // Update cape texture when capeImage or capeTexturePath changes
    if let capeImage = capeImage {
      nsViewController.updateCapeTexture(image: capeImage)
    } else if let capeTexturePath = capeTexturePath {
      nsViewController.updateCapeTexture(path: capeTexturePath)
    } else {
      // No cape texture provided, remove it
      nsViewController.removeCapeTexture()
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
  @State private var texturePath: String?
  /// Optional NSImage for direct texture input
  @State private var skinImage: NSImage?
  /// Optional path to the cape texture file
  @State private var capeTexturePath: String?
  /// Optional NSImage for direct cape texture input
  @State private var capeImage: NSImage?
  /// Player model type (Steve/Alex)
  let playerModel: PlayerModel
  /// Rotation duration for character animation (0 = no rotation)
  let rotationDuration: TimeInterval
  /// Background color for the 3D scene
  let backgroundColor: NSColor
  /// Drag and drop state
  @State private var isDragOver: Bool = false

  /// Initialize the skin render view with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeTexturePath: Optional path to the cape texture file
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(texturePath: String? = nil, capeTexturePath: String? = nil, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self._texturePath = State(initialValue: texturePath)
    self._skinImage = State(initialValue: nil)
    self._capeTexturePath = State(initialValue: capeTexturePath)
    self._capeImage = State(initialValue: nil)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  /// Initialize the skin render view with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - capeImage: Optional NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(skinImage: NSImage, capeImage: NSImage? = nil, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self._texturePath = State(initialValue: nil)
    self._skinImage = State(initialValue: skinImage)
    self._capeTexturePath = State(initialValue: nil)
    self._capeImage = State(initialValue: capeImage)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  /// Initialize the skin render view with mixed texture inputs
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeImage: NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(texturePath: String? = nil, capeImage: NSImage, playerModel: PlayerModel = .steve, rotationDuration: TimeInterval = 15.0, backgroundColor: NSColor = .gray) {
    self._texturePath = State(initialValue: texturePath)
    self._skinImage = State(initialValue: nil)
    self._capeTexturePath = State(initialValue: nil)
    self._capeImage = State(initialValue: capeImage)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
  }

  public var body: some View {
    Group {
      if let skinImage = skinImage {
        SceneKitCharacterViewRepresentable(
          skinImage: skinImage,
          capeImage: capeImage,
          playerModel: playerModel,
          rotationDuration: rotationDuration,
          backgroundColor: backgroundColor,
          showButtons: false
        )
      } else {
        SceneKitCharacterViewRepresentable(
          texturePath: texturePath,
          capeTexturePath: capeTexturePath,
          playerModel: playerModel,
          rotationDuration: rotationDuration,
          backgroundColor: backgroundColor,
          showButtons: false
        )
      }
    }
    .frame(minWidth: 400, minHeight: 300)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(isDragOver ? Color.blue : Color.clear, lineWidth: 3)
        .background(
          isDragOver ? Color.blue.opacity(0.1) : Color.clear,
          in: RoundedRectangle(cornerRadius: 12)
        )
    )
    .overlay(
      isDragOver ?
        VStack(spacing: 8) {
          Image(systemName: "square.and.arrow.down")
            .font(.system(size: 40))
            .foregroundColor(.blue)
          Text("Drop image file to update skin")
            .font(.headline)
            .foregroundColor(.blue)
          Text("Supports PNG, JPEG format")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 5)
        : nil
    )
    .onDrop(of: [.fileURL], isTargeted: $isDragOver) { providers in
      return handleDrop(providers: providers)
    }
  }

  /// Handle file drop
  private func handleDrop(providers: [NSItemProvider]) -> Bool {
    guard let provider = providers.first else { return false }

    provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (item, error) in
      guard let data = item as? Data,
            let url = URL(dataRepresentation: data, relativeTo: nil) else {
        return
      }

      let allowedExtensions = ["png", "jpg", "jpeg"]
      let fileExtension = url.pathExtension.lowercased()

      guard allowedExtensions.contains(fileExtension) else {
        return
      }

      DispatchQueue.main.async {
        if let image = NSImage(contentsOf: url) {
          self.skinImage = image
          self.texturePath = nil
        }
      }
    }

    return true
  }
}

/// Complete view with file selection functionality for choosing skin textures
/// Combines the skin render view with a file picker interface for easy texture selection
public struct SkinRenderDebug: View {
  /// Currently selected texture file path
  @State private var selectedTexturePath: String?
  /// Currently selected cape texture file path
  @State private var selectedCapeTexturePath: String?
  /// Controls the visibility of the file picker dialog
  @State private var showingFilePicker = false
  /// Controls the visibility of the cape file picker dialog
  @State private var showingCapeFilePicker = false
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
      // File selection controls
      HStack {
        Button("Select Skin Texture") {
          showFileImporter()
        }
        .padding()

        Button("Select Cape Texture") {
          showCapeFileImporter()
        }
        .padding()

        Spacer()
      }

      // Selected file names
      VStack(alignment: .leading, spacing: 4) {
        if let path = selectedTexturePath {
          HStack {
            Text("Skin:")
              .font(.caption)
              .foregroundColor(.secondary)
            Text(URL(fileURLWithPath: path).lastPathComponent)
              .font(.caption)
              .foregroundColor(.primary)
              .lineLimit(1)
              .truncationMode(.middle)
            Spacer()
          }
        }

        if let path = selectedCapeTexturePath {
          HStack {
            Text("Cape:")
              .font(.caption)
              .foregroundColor(.secondary)
            Text(URL(fileURLWithPath: path).lastPathComponent)
              .font(.caption)
              .foregroundColor(.primary)
              .lineLimit(1)
              .truncationMode(.middle)

            Button("✕") {
              selectedCapeTexturePath = nil
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()
          }
        }
      }
      .padding(.horizontal)

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

      SceneKitCharacterViewRepresentable(
        texturePath: selectedTexturePath,
        capeTexturePath: selectedCapeTexturePath,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        showButtons: true
      )
      .frame(minWidth: 400, minHeight: 300)
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

  /// Display file picker for selecting cape texture files
  /// Opens a native macOS file picker filtered for image files
  private func showCapeFileImporter() {
    let panel = NSOpenPanel()
    panel.allowedContentTypes = [.png, .jpeg, .image]
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.prompt = "Select"
    panel.message = "Choose a Minecraft cape texture file (64x32 pixels)"

    panel.begin { response in
      if response == .OK, let url = panel.url {
        selectedCapeTexturePath = url.path
      }
    }
  }
}
