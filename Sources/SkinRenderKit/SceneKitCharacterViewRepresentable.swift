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
  let debugMode: Bool

  /// Initialize the representable with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeTexturePath: Optional path to the cape texture file
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - debugMode: Whether to show control buttons (default: false)
  public init(
    texturePath: String? = nil,
    capeTexturePath: String? = nil,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    debugMode: Bool = false
  ) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.capeTexturePath = capeTexturePath
    self.capeImage = nil
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.debugMode = debugMode
  }

  /// Initialize the representable with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - capeImage: Optional NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - debugMode: Whether to show control buttons (default: false)
  public init(
    skinImage: NSImage,
    capeImage: NSImage? = nil,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    debugMode: Bool = false
  ) {
    self.texturePath = nil
    self.skinImage = skinImage
    self.capeTexturePath = nil
    self.capeImage = capeImage
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.debugMode = debugMode
  }

  /// Initialize the representable with mixed texture inputs
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeImage: NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  ///   - debugMode: Whether to show control buttons (default: false)
  public init(
    texturePath: String? = nil,
    capeImage: NSImage,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    debugMode: Bool = false
  ) {
    self.texturePath = texturePath
    self.skinImage = nil
    self.capeTexturePath = nil
    self.capeImage = capeImage
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.debugMode = debugMode
  }

  /// Create the underlying NSViewController for character rendering
  /// - Parameter context: SwiftUI representable context
  /// - Returns: Configured SceneKitCharacterViewController instance
  public func makeNSViewController(
    context: Context
  ) -> SceneKitCharacterViewController {
    if let skinImage = skinImage {
      return SceneKitCharacterViewController(
        skinImage: skinImage,
        capeImage: capeImage,
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        debugMode: debugMode
      )
    } else if let texturePath = texturePath {
      return SceneKitCharacterViewController(
        texturePath: texturePath,
        capeTexturePath: capeTexturePath,
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        debugMode: debugMode
      )
    } else if let capeImage = capeImage {
      // Only cape image provided
      let controller = SceneKitCharacterViewController(
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        debugMode: debugMode
      )
      controller.updateCapeTexture(image: capeImage)
      return controller
    } else {
      return SceneKitCharacterViewController(
        playerModel: playerModel,
        rotationDuration: rotationDuration,
        backgroundColor: backgroundColor,
        debugMode: debugMode
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
    nsViewController.updateShowButtons(debugMode)

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
  /// Drag and drop state - separate zones
  @State private var isDragOverSkin: Bool = false
  @State private var isDragOverCape: Bool = false
  @State private var isDraggingAny: Bool = false
  /// Drop feedback
  @State private var dropError: String?

  /// Optional callbacks for drop events
  public let onSkinDropped: ((NSImage) -> Void)?
  public let onCapeDropped: ((NSImage) -> Void)?

  /// Initialize the skin render view with an optional texture path
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeTexturePath: Optional path to the cape texture file
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(
    texturePath: String? = nil,
    capeTexturePath: String? = nil,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    onSkinDropped: ((NSImage) -> Void)? = nil,
    onCapeDropped: ((NSImage) -> Void)? = nil
  ) {
    self._texturePath = State(initialValue: texturePath)
    self._skinImage = State(initialValue: nil)
    self._capeTexturePath = State(initialValue: capeTexturePath)
    self._capeImage = State(initialValue: nil)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.onSkinDropped = onSkinDropped
    self.onCapeDropped = onCapeDropped
  }

  /// Initialize the skin render view with a direct NSImage texture
  /// - Parameters:
  ///   - skinImage: The NSImage containing the Minecraft skin texture
  ///   - capeImage: Optional NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(
    skinImage: NSImage,
    capeImage: NSImage? = nil,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    onSkinDropped: ((NSImage) -> Void)? = nil,
    onCapeDropped: ((NSImage) -> Void)? = nil
  ) {
    self._texturePath = State(initialValue: nil)
    self._skinImage = State(initialValue: skinImage)
    self._capeTexturePath = State(initialValue: nil)
    self._capeImage = State(initialValue: capeImage)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.onSkinDropped = onSkinDropped
    self.onCapeDropped = onCapeDropped
  }

  /// Initialize the skin render view with mixed texture inputs
  /// - Parameters:
  ///   - texturePath: Path to the Minecraft skin texture file
  ///   - capeImage: NSImage containing the cape texture
  ///   - playerModel: Player model type (Steve/Alex)
  ///   - rotationDuration: Duration for one full rotation in seconds (0 = no rotation)
  ///   - backgroundColor: Background color for the 3D scene
  public init(
    texturePath: String? = nil,
    capeImage: NSImage,
    playerModel: PlayerModel = .steve,
    rotationDuration: TimeInterval = 15.0,
    backgroundColor: NSColor = .gray,
    onSkinDropped: ((NSImage) -> Void)? = nil,
    onCapeDropped: ((NSImage) -> Void)? = nil
  ) {
    self._texturePath = State(initialValue: texturePath)
    self._skinImage = State(initialValue: nil)
    self._capeTexturePath = State(initialValue: nil)
    self._capeImage = State(initialValue: capeImage)
    self.playerModel = playerModel
    self.rotationDuration = rotationDuration
    self.backgroundColor = backgroundColor
    self.onSkinDropped = onSkinDropped
    self.onCapeDropped = onCapeDropped
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
          debugMode: false
        )
      } else {
        SceneKitCharacterViewRepresentable(
          texturePath: texturePath,
          capeTexturePath: capeTexturePath,
          playerModel: playerModel,
          rotationDuration: rotationDuration,
          backgroundColor: backgroundColor,
          debugMode: false
        )
      }
    }
    .frame(minWidth: 400, minHeight: 300)
    .overlay(
      ZStack {
        // Global outline when dragging over any zone
        if isDraggingAny || isDragOverSkin || isDragOverCape {
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.accentColor, lineWidth: 3)
            .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }

        // Two drop targets overlay (shown only while dragging)
        if isDraggingAny || isDragOverSkin || isDragOverCape {
          HStack(spacing: 16) {
            DropTargetView(
              title: "Skin (64x64)",
              subtitle: "PNG / JPEG,64x64",
              systemImage: "person.crop.square",
              isActive: isDragOverSkin
            )
            .onDrop(of: [.fileURL, .png, .jpeg, .image], isTargeted: $isDragOverSkin) { providers in
              return handleDrop(providers: providers, target: .skin)
            }

            DropTargetView(
              title: "Cape",
              subtitle: "PNG / JPEG,64x32",
              systemImage: "flag.fill",
              isActive: isDragOverCape
            )
            .onDrop(of: [.fileURL, .png, .jpeg, .image], isTargeted: $isDragOverCape) { providers in
              return handleDrop(providers: providers, target: .cape)
            }
          }
          .padding(24)
        }

        // Error banner
        if let error = dropError {
          VStack {
            HStack(spacing: 8) {
              Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
              Text(error)
                .foregroundColor(.white)
                .font(.caption)
            }
            .padding(8)
            .background(Color.red.opacity(0.9), in: Capsule())
            Spacer()
          }
          .padding(.top, 12)
        }
      }
    )
    // Root-level drop as fallback: drop outside cards defaults to skin
    .onDrop(of: [.fileURL, .png, .jpeg, .image], isTargeted: $isDraggingAny) { providers in
      // If a specific zone captured it, this won't fire; as fallback, treat as skin
      return handleDrop(providers: providers, target: .skin)
    }
  }

  // MARK: - Drag & Drop Helpers

  private enum DropTarget { case skin, cape }

  /// Handle drop for specific target (skin or cape)
  private func handleDrop(providers: [NSItemProvider], target: DropTarget) -> Bool {
    guard let provider = providers.first else {
      DispatchQueue.main.async { self.showDropError("No drag content detected") }
      return false
    }

    print("🎯 Start to handle \(target == .skin ? "Skin" : "Cape") drag")

    loadImage(from: provider) { image in
      DispatchQueue.main.async {
        guard let image = image else {
          self.showDropError("Failed to read image data, please check file format or permissions")
          return
        }

        print("📐 Image size: \(image.size.width) × \(image.size.height)")

        switch target {
        case .skin:
          if validateSkin(image) {
            self.skinImage = image
            self.texturePath = nil
            self.onSkinDropped?(image)
            print("✅ Skin updated successfully")
          } else {
            let size = image.size
            self.showDropError("Skin size error: \(Int(size.width))×\(Int(size.height)), need 64x64 or 64x32 format")
          }
        case .cape:
          if validateCape(image) {
            self.capeImage = image
            self.capeTexturePath = nil
            self.onCapeDropped?(image)
            print("✅ Cape updated successfully")
          } else {
            let size = image.size
            self.showDropError("Cape size error: \(Int(size.width))×\(Int(size.height)), need 64x32 format")
          }
        }
      }
    }

    return true
  }

  /// Try to load an NSImage from a single provider (file URL, PNG/JPEG data, or generic image)
  private func loadImage(from provider: NSItemProvider, completion: @escaping (NSImage?) -> Void) {
    // Debug: Print available type identifiers
    print("🔍 Drag provider supported types: \(provider.registeredTypeIdentifiers)")

    // Try to load NSImage object (for in-app drag)
    if provider.canLoadObject(ofClass: NSImage.self) {
      provider.loadObject(ofClass: NSImage.self) { object, error in
        if let error = error {
          print("❌ Failed to load NSImage object: \(error.localizedDescription)")
        }
        completion(object as? NSImage)
      }
      return
    }

    // 1) File URL path - fix processing logic
    if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
        if let error = error {
          print("❌ Failed to load file URL: \(error.localizedDescription)")
          completion(nil)
          return
        }

        var imageURL: URL?

        // Try multiple URL retrieval methods
        if let data = item as? Data {
          imageURL = URL(dataRepresentation: data, relativeTo: nil)
        } else if let url = item as? URL {
          imageURL = url
        } else if let nsUrl = item as? NSURL {
          imageURL = nsUrl as URL
        }

        guard let url = imageURL else {
          print("❌ Failed to extract URL from drag item")
          completion(nil)
          return
        }

        print("📁 Try to load image from file: \(url.path)")

        // Check if file exists and is accessible
        guard url.isFileURL, FileManager.default.fileExists(atPath: url.path) else {
          print("❌ File does not exist or cannot be accessed: \(url.path)")
          completion(nil)
          return
        }

        let image = NSImage(contentsOf: url)
        if image != nil {
          print("✅ Successfully loaded image from file")
        } else {
          print("❌ NSImage cannot read file content")
        }
        completion(image)
      }
      return
    }

    // 2) PNG Data
    if provider.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.png.identifier, options: nil) { item, error in
        if let error = error {
          print("❌ Failed to load PNG data: \(error.localizedDescription)")
          completion(nil)
          return
        }

        if let data = item as? Data {
          print("📊 PNG data size: \(data.count) bytes")
          let image = NSImage(data: data)
          if image != nil {
            print("✅ Successfully created image from PNG data")
          } else {
            print("❌ PNG data is invalid")
          }
          completion(image)
        } else {
          print("❌ PNG item is not Data type")
          completion(nil)
        }
      }
      return
    }

    // 3) JPEG data
    if provider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.jpeg.identifier, options: nil) { item, error in
        if let error = error {
          print("❌ Failed to load JPEG data: \(error.localizedDescription)")
          completion(nil)
          return
        }

        if let data = item as? Data {
          print("📊 JPEG data size: \(data.count) bytes")
          let image = NSImage(data: data)
          if image != nil {
            print("✅ Successfully created image from JPEG data")
          } else {
            print("❌ JPEG data is invalid")
          }
          completion(image)
        } else {
          print("❌ JPEG item is not Data type")
          completion(nil)
        }
      }
      return
    }

    // 4) Generic image representation
    if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
      provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
        if let error = error {
          print("❌ Failed to load generic image data: \(error.localizedDescription)")
          completion(nil)
          return
        }

        if let data = item as? Data {
          print("📊 Generic image data size: \(data.count) bytes")
          let image = NSImage(data: data)
          if image != nil {
            print("✅ Successfully created image from generic image data")
          } else {
            print("❌ Generic image data is invalid")
          }
          completion(image)
        } else if let image = item as? NSImage {
          print("✅ Directly obtained NSImage object")
          completion(image)
        } else {
          print("❌ Generic image item type not supported: \(type(of: item))")
          completion(nil)
        }
      }
      return
    }

    print("❌ No supported image type found")
    completion(nil)
  }

  private func validateSkin(_ image: NSImage) -> Bool {
    guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    let w = cg.width
    let h = cg.height
    // 64x64 (or exact square multiples) or legacy 64x32 in exact 2:1 multiples
    if w == h && w % 64 == 0 { return true }           // e.g., 64x64, 128x128
    if w % 64 == 0 && h * 2 == w { return true }       // e.g., 64x32, 128x64 (legacy style)
    return false                                       // reject 2:1 mistaken exports as modern skins
  }

  private func validateCape(_ image: NSImage) -> Bool {
    guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    let w = cg.width
    let h = cg.height
    // Standard 64x32 or any exact 2:1 multiple (e.g., 128x64, 256x128)
    return w == 2 * h && w % 64 == 0
  }

  private func showDropError(_ message: String) {
    dropError = message
    // Auto dismiss after short delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
      withAnimation { dropError = nil }
    }
  }
}

// MARK: - Drop Target Visual
private struct DropTargetView: View {
  let title: String
  let subtitle: String
  let systemImage: String
  let isActive: Bool

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: systemImage)
        .font(.system(size: 36))
        .foregroundColor(isActive ? .accentColor : .secondary)
      Text(title)
        .font(.headline)
        .foregroundColor(isActive ? .accentColor : .primary)
      Text(subtitle)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(16)
    .frame(minWidth: 180)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color(NSColor.windowBackgroundColor).opacity(isActive ? 0.95 : 0.7))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(isActive ? Color.accentColor : Color.secondary.opacity(0.3), style: StrokeStyle(lineWidth: isActive ? 2 : 1, dash: isActive ? [] : [6]))
    )
    .shadow(color: Color.black.opacity(isActive ? 0.15 : 0.05), radius: isActive ? 10 : 4, x: 0, y: 2)
    .contentShape(RoundedRectangle(cornerRadius: 10))
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
        debugMode: true
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
