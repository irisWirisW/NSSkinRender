//
//  SceneKitCharacterViewController.swift
//  SkinRender
//

import Cocoa
import SceneKit

// MARK: - Player Model Types
public enum PlayerModel: String, CaseIterable {
  case steve = "steve"
  case alex = "alex"

  var displayName: String {
    switch self {
    case .steve: return "Steve"
    case .alex: return "Alex"
    }
  }

  // Arm dimensions for each model
  var armDimensions: (width: CGFloat, height: CGFloat, length: CGFloat) {
    switch self {
    case .steve: return (4.0, 12.0, 4.0)
    case .alex: return (3.0, 12.0, 4.0)
    }
  }

  // Arm sleeve dimensions for each model
  var armSleeveDimensions: (width: CGFloat, height: CGFloat, length: CGFloat) {
    switch self {
    case .steve: return (4.5, 12.5, 4.5)
    case .alex: return (3.5, 12.5, 4.5)
    }
  }

  // Arm positions for each model
  var armPositions: (left: SCNVector3, right: SCNVector3) {
    switch self {
    case .steve: return (SCNVector3(6, 6, 0), SCNVector3(-6, 6, 0))
    case .alex: return (SCNVector3(5.5, 5.75, 0), SCNVector3(-5.5, 5.75, 0))
    }
  }
}

public class SceneKitCharacterViewController: NSViewController {

  private var scnView: SCNView!
  private var scene: SCNScene!

  // Texture file path
  private var texturePath: String?
  private var skinImage: NSImage?

  // Player model type
  private var playerModel: PlayerModel = .steve

  // Character body part nodes
  private var characterGroup: SCNNode!
  private var headNode: SCNNode!
  private var hatNode: SCNNode!
  private var bodyNode: SCNNode!
  private var jacketNode: SCNNode!
  private var rightArmNode: SCNNode!
  private var rightArmSleeveNode: SCNNode!
  private var leftArmNode: SCNNode!
  private var leftArmSleeveNode: SCNNode!
  private var rightLegNode: SCNNode!
  private var rightLegSleeveNode: SCNNode!
  private var leftLegNode: SCNNode!
  private var leftLegSleeveNode: SCNNode!

  // Outer layer display control
  private var showOuterLayers: Bool = true
  private var toggleButton: NSButton!

  // Model type control
  private var modelTypeButton: NSButton!

  // Convenience initializer
  public convenience init(texturePath: String, playerModel: PlayerModel = .steve) {
    self.init()
    self.texturePath = texturePath
    self.playerModel = playerModel
    loadTexture()
  }

  // Convenience initializer with only model type
  public convenience init(playerModel: PlayerModel) {
    self.init()
    self.playerModel = playerModel
  }

  public override func loadView() {
    scnView = SCNView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    self.view = scnView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    // If no texture is set through initializer, use default texture
    if skinImage == nil {
      loadDefaultTexture()
    }

    setupScene()
    setupCharacter()
    setupCamera()
    setupLighting()
    setupUI()

    scnView.allowsCameraControl = true
    scnView.backgroundColor = NSColor.gray
  }

  private func loadTexture() {
    guard let texturePath = texturePath else { return }

    if let image = NSImage(contentsOfFile: texturePath) {
      self.skinImage = image
    } else {
      print("Failed to load texture from path: \(texturePath)")
      loadDefaultTexture()
    }
  }

  private func loadDefaultTexture() {
    // Try to load alex.png from Swift Package resources
    if let resourceURL = Bundle.module.url(forResource: "alex", withExtension: "png"),
       let image = NSImage(contentsOf: resourceURL) {
      self.skinImage = image
    } else {
      // Fallback: try using NSImage(named:)
      self.skinImage = NSImage(named: "Skin")
      if self.skinImage == nil {
        print("Warning: Could not load default texture")
      }
    }
  }

  // Public method for updating texture
  public func updateTexture(path: String) {
    self.texturePath = path
    loadTexture()

    // Recreate character to apply new texture
    if skinImage != nil {
      characterGroup?.removeFromParentNode()
      setupCharacter()
    }
  }

  private func setupScene() {
    scene = SCNScene()
    scnView.scene = scene
  }

  private func setupCharacter() {
    // Create character group node
    characterGroup = SCNNode()
    characterGroup.name = "CharacterGroup"
    scene.rootNode.addChildNode(characterGroup)

    // Create body parts
    createHead()
    createBody()
    createArms()
    createLegs()

    // Set rendering priorities and depth offsets
    setupRenderingPriorities()

    // Add rotation animation
    let rotationAction = SCNAction.rotateBy(
      x: 0,
      y: CGFloat.pi * 2,
      z: 0,
      duration: 15.0
    )
    let repeatAction = SCNAction.repeatForever(rotationAction)
    characterGroup.runAction(repeatAction)
  }

  private func setupCamera() {
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(0, 10, 30)
    cameraNode.look(at: SCNVector3(0, 10, 0))
    scene.rootNode.addChildNode(cameraNode)
  }

  private func setupLighting() {
    // Ambient light
    let ambientLight = SCNNode()
    ambientLight.light = SCNLight()
    ambientLight.light?.type = .ambient
    ambientLight.light?.intensity = 300
    scene.rootNode.addChildNode(ambientLight)

    // Directional light
    let directionalLight = SCNNode()
    directionalLight.light = SCNLight()
    directionalLight.light?.type = .directional
    directionalLight.light?.intensity = 500
    directionalLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
    scene.rootNode.addChildNode(directionalLight)
  }

  private func setupUI() {
    // Create button to toggle outer layers
    toggleButton = NSButton(frame: NSRect(x: 20, y: 20, width: 130, height: 30))
    toggleButton.title =
      showOuterLayers ? "Hide Outer Layers" : "Show Outer Layers"
    toggleButton.bezelStyle = .rounded
    toggleButton.target = self
    toggleButton.action = #selector(toggleOuterLayers)
    toggleButton.autoresizingMask = [.maxXMargin, .maxYMargin]

    view.addSubview(toggleButton)

    // Create button to switch model type
    modelTypeButton = NSButton(frame: NSRect(x: 20, y: 60, width: 130, height: 30))
    modelTypeButton.title = "Switch to \(playerModel == .steve ? "Alex" : "Steve")"
    modelTypeButton.bezelStyle = .rounded
    modelTypeButton.target = self
    modelTypeButton.action = #selector(switchModelType)
    modelTypeButton.autoresizingMask = [.maxXMargin, .maxYMargin]

    view.addSubview(modelTypeButton)
  }

  @objc private func toggleOuterLayers() {
    showOuterLayers.toggle()

    // Toggle visibility of all outer layers
    hatNode?.isHidden = !showOuterLayers
    jacketNode?.isHidden = !showOuterLayers
    rightArmSleeveNode?.isHidden = !showOuterLayers
    leftArmSleeveNode?.isHidden = !showOuterLayers
    rightLegSleeveNode?.isHidden = !showOuterLayers
    leftLegSleeveNode?.isHidden = !showOuterLayers

    toggleButton.title =
      showOuterLayers ? "Hide Outer Layers" : "Show Outer Layers"

    print("Outer layers visibility: \(showOuterLayers ? "shown" : "hidden")")
  }

  @objc private func switchModelType() {
    // Switch between Steve and Alex models
    playerModel = (playerModel == .steve) ? .alex : .steve

    // Update button text
    modelTypeButton.title = "Switch to \(playerModel == .steve ? "Alex" : "Steve")"

    // Recreate character with new model type
    characterGroup?.removeFromParentNode()
    setupCharacter()

    print("Switched to \(playerModel.displayName) model")
  }
}

// MARK: - Material Creation Functions

extension SceneKitCharacterViewController {

  private func createHeadMaterials(
    from skinImage: NSImage,
    isHat: Bool = false
  ) -> [SCNMaterial] {
    let headRects: [CGRect]
    let layerName: String

    if isHat {
      // Hat layer texture coordinates
      headRects = [
        CGRect(x: 40, y: 8, width: 8, height: 8),  // front
        CGRect(x: 48, y: 8, width: 8, height: 8),  // right
        CGRect(x: 56, y: 8, width: 8, height: 8),  // back
        CGRect(x: 32, y: 8, width: 8, height: 8),  // left
        CGRect(x: 40, y: 0, width: 8, height: 8),  // top
        CGRect(x: 48, y: 0, width: 8, height: 8),  // bottom
      ]
      layerName = "hat"
    } else {
      headRects = [
        CGRect(x:  8, y: 8, width: 8, height: 8), // front
        CGRect(x: 16, y: 8, width: 8, height: 8), // right
        CGRect(x: 24, y: 8, width: 8, height: 8), // back
        CGRect(x:  0, y: 8, width: 8, height: 8), // left
        CGRect(x:  8, y: 0, width: 8, height: 8), // top
        CGRect(x: 16, y: 0, width: 8, height: 8), // bottom
      ]
      layerName = "head"
    }

    return createMaterials(
      from: skinImage,
      rects: headRects,
      layerName: layerName,
      isOuter: isHat
    )
  }

  private func createBodyMaterials(
    from skinImage: NSImage,
    isJacket: Bool = false
  ) -> [SCNMaterial] {
    let bodyRects: [CGRect]
    let layerName: String

    if isJacket {
      // Jacket layer texture coordinates
      bodyRects = [
        CGRect(x: 20, y: 36, width: 8, height: 12),  // front
        CGRect(x: 28, y: 36, width: 4, height: 12),  // right
        CGRect(x: 32, y: 36, width: 8, height: 12),  // back
        CGRect(x: 16, y: 36, width: 4, height: 12),  // left
        CGRect(x: 20, y: 32, width: 8, height:  4),  // top
        CGRect(x: 28, y: 32, width: 8, height:  4),  // bottom
      ]
      layerName = "jacket"
    } else {
      // Base body texture coordinates
      bodyRects = [
        CGRect(x: 20, y: 20, width: 8, height: 12),  // front
        CGRect(x: 28, y: 20, width: 4, height: 12),  // right
        CGRect(x: 32, y: 20, width: 8, height: 12),  // back
        CGRect(x: 16, y: 20, width: 4, height: 12),  // left
        CGRect(x: 20, y: 16, width: 8, height:  4),  // top
        CGRect(x: 28, y: 16, width: 8, height:  4),  // bottom
      ]
      layerName = "body"
    }

    return createMaterials(
      from: skinImage,
      rects: bodyRects,
      layerName: layerName,
      isOuter: isJacket
    )
  }

  private func createArmMaterials(
    from skinImage: NSImage,
    isLeft: Bool,
    isSleeve: Bool
  ) -> [SCNMaterial] {
    let armRects: [CGRect]
    let layerName: String

    // Determine arm width based on player model
    let armWidth: CGFloat = playerModel.armDimensions.width

    if isSleeve {
      if isLeft {
        // Left arm sleeve texture coordinates
        armRects = [
          CGRect(x: 52, y: 52, width: armWidth, height: 12),  // front
          CGRect(x: 52 + armWidth, y: 52, width: 4, height: 12),  // right
          CGRect(x: 52 + armWidth + 4, y: 52, width: armWidth, height: 12),  // back
          CGRect(x: 48, y: 52, width: 4, height: 12),  // left
          CGRect(x: 52, y: 48, width: armWidth, height: 4),  // top
          CGRect(x: 52 + armWidth, y: 48, width: armWidth, height: 4),  // bottom
        ]
        layerName = "left_arm_sleeve"
      } else {
        // Right arm sleeve texture coordinates
        armRects = [
          CGRect(x: 44, y: 36, width: armWidth, height: 12),  // front
          CGRect(x: 44 + armWidth, y: 36, width: 4, height: 12),  // right
          CGRect(x: 44 + armWidth + 4, y: 36, width: armWidth, height: 12),  // back
          CGRect(x: 40, y: 36, width: 4, height: 12),  // left
          CGRect(x: 44, y: 32, width: armWidth, height: 4),  // top
          CGRect(x: 44 + armWidth, y: 32, width: armWidth, height: 4),  // bottom
        ]
        layerName = "right_arm_sleeve"
      }
    } else {
      if isLeft {
        // Left arm base texture coordinates
        armRects = [
          CGRect(x: 36, y: 52, width: armWidth, height: 12),  // front
          CGRect(x: 36 + armWidth, y: 52, width: 4, height: 12),  // right
          CGRect(x: 36 + armWidth + 4, y: 52, width: armWidth, height: 12),  // back
          CGRect(x: 32, y: 52, width: 4, height: 12),  // left
          CGRect(x: 36, y: 48, width: armWidth, height: 4),  // top
          CGRect(x: 36 + armWidth, y: 48, width: armWidth, height: 4),  // bottom
        ]
        layerName = "left_arm"
      } else {
        // Right arm base texture coordinates
        armRects = [
          CGRect(x: 44, y: 20, width: armWidth, height: 12),  // front
          CGRect(x: 44 + armWidth, y: 20, width: 4, height: 12),  // right
          CGRect(x: 44 + armWidth + 4, y: 20, width: armWidth, height: 12),  // back
          CGRect(x: 40, y: 20, width: 4, height: 12),  // left
          CGRect(x: 44, y: 16, width: armWidth, height: 4),  // top
          CGRect(x: 44 + armWidth, y: 16, width: armWidth, height: 4),  // bottom
        ]
        layerName = "right_arm"
      }
    }

    return createMaterials(
      from: skinImage,
      rects: armRects,
      layerName: layerName,
      isOuter: isSleeve,
      isLimb: true
    )
  }

  private func createLegMaterials(
    from skinImage: NSImage,
    isLeft: Bool,
    isSleeve: Bool
  ) -> [SCNMaterial] {
    let legRects: [CGRect]
    let layerName: String

    if isSleeve {
      if isLeft {
        // Left leg pants texture coordinates
        legRects = [
          CGRect(x:  4, y: 52, width: 4, height: 12),  // front
          CGRect(x:  8, y: 52, width: 4, height: 12),  // right
          CGRect(x: 12, y: 52, width: 4, height: 12),  // back
          CGRect(x:  0, y: 52, width: 4, height: 12),  // left
          CGRect(x:  4, y: 48, width: 4, height:  4),  // top
          CGRect(x:  8, y: 48, width: 4, height:  4),  // bottom
        ]
        layerName = "left_leg_sleeve"
      } else {
        // Right leg pants texture coordinates
        legRects = [
          CGRect(x:  4, y: 36, width: 4, height: 12),  // front
          CGRect(x:  8, y: 36, width: 4, height: 12),  // right
          CGRect(x: 12, y: 36, width: 4, height: 12),  // back
          CGRect(x:  0, y: 36, width: 4, height: 12),  // left
          CGRect(x:  4, y: 32, width: 4, height:  4),  // top
          CGRect(x:  8, y: 32, width: 4, height:  4),  // bottom
        ]
        layerName = "right_leg_sleeve"
      }
    } else {
      if isLeft {
        // Left leg base texture coordinates (mirrored from right leg)
        legRects = [
          CGRect(x: 20, y: 52, width: 4, height: 12),  // front
          CGRect(x: 24, y: 52, width: 4, height: 12),  // right
          CGRect(x: 28, y: 52, width: 4, height: 12),  // back
          CGRect(x: 16, y: 52, width: 4, height: 12),  // left
          CGRect(x: 20, y: 48, width: 4, height:  4),  // top
          CGRect(x: 24, y: 48, width: 4, height:  4),  // bottom
        ]
        layerName = "left_leg"
      } else {
        // Right leg base texture coordinates
        legRects = [
          CGRect(x:  4, y: 20, width: 4, height: 12),  // front
          CGRect(x:  8, y: 20, width: 4, height: 12),  // right
          CGRect(x: 12, y: 20, width: 4, height: 12),  // back
          CGRect(x:  0, y: 20, width: 4, height: 12),  // left
          CGRect(x:  4, y: 16, width: 4, height:  4),  // top
          CGRect(x:  8, y: 16, width: 4, height:  4),  // bottom
        ]
        layerName = "right_leg"
      }
    }

    return createMaterials(
      from: skinImage,
      rects: legRects,
      layerName: layerName,
      isOuter: isSleeve,
      isLimb: true
    )
  }

  // MARK: - General Material Creation Functions

  private func createMaterials(
    from skinImage: NSImage,
    rects: [CGRect],
    layerName: String,
    isOuter: Bool,
    isLimb: Bool = false
  ) -> [SCNMaterial] {
    let faceNames = ["front", "right", "back", "left", "top", "bottom"]
    var materials: [SCNMaterial] = []

    for (index, rect) in rects.enumerated() {
      let material = SCNMaterial()
      print(
        "Processing \(layerName) face \(index) (\(faceNames[index])) with rect: \(rect)"
      )

      if let croppedImage = cropImage(
        skinImage,
        rect: rect,
        layerName: layerName
      ) {
        let finalImage: NSImage
        if index == 5 {  // bottom face
          if isLimb {
            // Limbs (arms and legs) bottom face doesn't need rotation
            finalImage = croppedImage
          } else {
            // Head and body bottom face needs 180 degree rotation
            finalImage = rotateImage(croppedImage, degrees: 180) ?? croppedImage
          }
        } else {
          finalImage = croppedImage
        }

        material.diffuse.contents = finalImage
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.wrapS = .clamp
        material.diffuse.wrapT = .clamp

        // Set transparency for outer layers
        if isOuter {
          if hasTransparentPixels(finalImage) {
            material.transparency = 1.0
            material.blendMode = .alpha
            material.isDoubleSided = true
          } else {
            material.transparency = 0.9
            material.blendMode = .alpha
          }
        }

        material.lightingModel = .constant

        print(
          "Successfully created material for \(layerName) face \(index) (\(faceNames[index]))"
        )
      } else {
        material.diffuse.contents = isOuter ? NSColor.blue.withAlphaComponent(0.5) : NSColor.red
        print(
          "Failed to crop texture for \(layerName) face \(index) (\(faceNames[index])), rect: \(rect)"
        )
      }

      materials.append(material)
    }

    return materials
  }
}

// MARK: - Helper Functions

extension SceneKitCharacterViewController {

  private func cropImage(
    _ image: NSImage,
    rect: CGRect,
    layerName: String = "character"
  ) -> NSImage? {
    guard
      let cgImage = image.cgImage(
        forProposedRect: nil,
        context: nil,
        hints: nil
      )
    else {
      print("❌ Failed to get CGImage from NSImage")
      return nil
    }

    let imageWidth = CGFloat(cgImage.width)
    let imageHeight = CGFloat(cgImage.height)

    let cropRect = CGRect(
      x: rect.minX,
      y: rect.minY,
      width: rect.width,
      height: rect.height
    )

    let imageBounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
    if !imageBounds.contains(cropRect) {
      print("⚠️  Crop rect \(cropRect) is outside image bounds \(imageBounds)")
      let intersection = cropRect.intersection(imageBounds)
      if intersection.isEmpty {
        print("❌ No intersection with image bounds")
        return nil
      }
    }

    guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
      print("❌ Failed to crop CGImage with rect: \(cropRect)")
      return nil
    }

    let resultImage = NSImage(
      cgImage: croppedCGImage,
      size: NSSize(width: rect.width, height: rect.height)
    )

    #if DEBUG
      saveDebugImage(
        resultImage,
        name:
          "\(layerName)_crop_\(Int(rect.minX))_\(Int(rect.minY))_\(Int(rect.width))x\(Int(rect.height))"
      )
    #endif

    return resultImage
  }

  private func rotateImage(_ image: NSImage, degrees: CGFloat) -> NSImage? {
    let radians = degrees * .pi / 180.0
    let originalSize = image.size
    let newSize = originalSize

    let newImage = NSImage(size: newSize)
    newImage.lockFocus()

    let transform = NSAffineTransform()
    transform.translateX(by: newSize.width / 2, yBy: newSize.height / 2)
    transform.rotate(byRadians: radians)
    transform.translateX(
      by: -originalSize.width / 2,
      yBy: -originalSize.height / 2
    )
    transform.concat()

    image.draw(
      at: NSPoint.zero,
      from: NSRect.zero,
      operation: .copy,
      fraction: 1.0
    )

    newImage.unlockFocus()

    return newImage
  }

  private func hasTransparentPixels(_ image: NSImage) -> Bool {
    guard
      let cgImage = image.cgImage(
        forProposedRect: nil,
        context: nil,
        hints: nil
      )
    else {
      return false
    }

    return cgImage.alphaInfo != .none && cgImage.alphaInfo != .noneSkipFirst
      && cgImage.alphaInfo != .noneSkipLast
  }

  #if DEBUG
    private func saveDebugImage(_ image: NSImage, name: String) {
      guard let data = image.tiffRepresentation,
        let bitmapRep = NSBitmapImageRep(data: data),
        let pngData = bitmapRep.representation(using: .png, properties: [:])
      else {
        return
      }

      let desktopURL = FileManager.default.urls(
        for: .desktopDirectory,
        in: .userDomainMask
      ).first!
      let fileURL = desktopURL.appendingPathComponent("\(name).png")

      try? pngData.write(to: fileURL)
      print("🖼️ Saved debug image: \(fileURL.path)")
    }
  #endif

  private func setupRenderingPriorities() {
    // Set rendering order and depth offset to avoid Z-fighting
    // Rendering order: higher values render later (appear in front)

    // Base layers - lowest priority
    bodyNode?.renderingOrder = 100
    headNode?.renderingOrder = 100
    rightArmNode?.renderingOrder = 105  // Arms slightly higher priority to avoid conflicts with body
    leftArmNode?.renderingOrder = 105
    rightLegNode?.renderingOrder = 105
    leftLegNode?.renderingOrder = 105

    // Outer layers - highest priority, ensuring they display on top of base layers
    hatNode?.renderingOrder = 200
    jacketNode?.renderingOrder = 200
    rightArmSleeveNode?.renderingOrder = 210
    leftArmSleeveNode?.renderingOrder = 210
    rightLegSleeveNode?.renderingOrder = 210
    leftLegSleeveNode?.renderingOrder = 210

    // Set depth bias for all geometries to further reduce Z-fighting
    setDepthBias(for: bodyNode, bias: 0.0)
    setDepthBias(for: headNode, bias: 0.0)
    setDepthBias(for: rightArmNode, bias: -0.001)  // Negative value makes arms slightly forward
    setDepthBias(for: leftArmNode, bias: -0.001)
    setDepthBias(for: rightLegNode, bias: -0.001)
    setDepthBias(for: leftLegNode, bias: -0.001)

    // Outer layers set with larger forward offset
    setDepthBias(for: hatNode, bias: -0.002)
    setDepthBias(for: jacketNode, bias: -0.002)
    setDepthBias(for: rightArmSleeveNode, bias: -0.003)
    setDepthBias(for: leftArmSleeveNode, bias: -0.003)
    setDepthBias(for: rightLegSleeveNode, bias: -0.003)
    setDepthBias(for: leftLegSleeveNode, bias: -0.003)

    print("✅ Rendering priorities and depth bias configured")
  }

  private func setDepthBias(for node: SCNNode?, bias: Float) {
    guard let node = node, let geometry = node.geometry else { return }

    for material in geometry.materials {
      material.readsFromDepthBuffer = true
      material.writesToDepthBuffer = true

      // Set transparency sorting to control rendering order
      if bias != 0.0 {
        material.transparency = 0.99999  // Close to 1 but not fully transparent, triggers alpha sorting
        material.blendMode = .alpha
      }
    }

    // Create depth offset effect by fine-tuning node position
    let currentPosition = node.position
    node.position = SCNVector3(
      currentPosition.x,
      currentPosition.y,
      currentPosition.z + CGFloat(bias * 100)  // Amplify offset effect
    )
  }
}

// MARK: - Create Character Parts

extension SceneKitCharacterViewController {

  private func createHead() {
    // Base head (8x8x8)
    let headGeometry = SCNBox(width: 8, height: 8, length: 8, chamferRadius: 0)
    guard let skinImage = skinImage else { return }

    headGeometry.materials = createHeadMaterials(from: skinImage, isHat: false)
    headNode = SCNNode(geometry: headGeometry)
    headNode.name = "Head"
    headNode.position = SCNVector3(0, 16, 0)  // Adjust head position: body top(12) + head height half(4) = 16
    characterGroup.addChildNode(headNode)

    // Hat layer (9x9x9)
    let hatGeometry = SCNBox(width: 9, height: 9, length: 9, chamferRadius: 0)
    hatGeometry.materials = createHeadMaterials(from: skinImage, isHat: true)
    hatNode = SCNNode(geometry: hatGeometry)
    hatNode.name = "Hat"
    hatNode.position = SCNVector3(0, 16, 0)  // Hat position same as head
    characterGroup.addChildNode(hatNode)
  }

  private func createBody() {
    // Base body (8x12x4)
    let bodyGeometry = SCNBox(width: 8, height: 12, length: 4, chamferRadius: 0)
    guard let skinImage = skinImage else { return }

    bodyGeometry.materials = createBodyMaterials(
      from: skinImage,
      isJacket: false
    )
    bodyNode = SCNNode(geometry: bodyGeometry)
    bodyNode.name = "Body"
    bodyNode.position = SCNVector3(0, 6, 0)  // Body center
    characterGroup.addChildNode(bodyNode)

    // Jacket layer (8.5x12.5x4.5)
    let jacketGeometry = SCNBox(
      width: 8.5,
      height: 12.5,
      length: 4.5,
      chamferRadius: 0
    )
    jacketGeometry.materials = createBodyMaterials(
      from: skinImage,
      isJacket: true
    )
    jacketNode = SCNNode(geometry: jacketGeometry)
    jacketNode.name = "Jacket"
    jacketNode.position = SCNVector3(0, 6, 0)
    characterGroup.addChildNode(jacketNode)
  }

  private func createArms() {
    guard let skinImage = skinImage else { return }

    let armDimensions = playerModel.armDimensions
    let armSleeveDimensions = playerModel.armSleeveDimensions
    let armPositions = playerModel.armPositions

    // Right arm
    let rightArmGeometry = SCNBox(
      width: armDimensions.width,
      height: armDimensions.height,
      length: armDimensions.length,
      chamferRadius: 0
    )
    rightArmGeometry.materials = createArmMaterials(
      from: skinImage,
      isLeft: false,
      isSleeve: false
    )
    rightArmNode = SCNNode(geometry: rightArmGeometry)
    rightArmNode.name = "RightArm"
    rightArmNode.position = armPositions.right
    characterGroup.addChildNode(rightArmNode)

    // Right arm sleeve
    let rightArmSleeveGeometry = SCNBox(
      width: armSleeveDimensions.width,
      height: armSleeveDimensions.height,
      length: armSleeveDimensions.length,
      chamferRadius: 0
    )
    rightArmSleeveGeometry.materials = createArmMaterials(
      from: skinImage,
      isLeft: false,
      isSleeve: true
    )
    rightArmSleeveNode = SCNNode(geometry: rightArmSleeveGeometry)
    rightArmSleeveNode.name = "RightArmSleeve"
    rightArmSleeveNode.position = armPositions.right
    characterGroup.addChildNode(rightArmSleeveNode)

    // Left arm
    let leftArmGeometry = SCNBox(
      width: armDimensions.width,
      height: armDimensions.height,
      length: armDimensions.length,
      chamferRadius: 0
    )
    leftArmGeometry.materials = createArmMaterials(
      from: skinImage,
      isLeft: true,
      isSleeve: false
    )
    leftArmNode = SCNNode(geometry: leftArmGeometry)
    leftArmNode.name = "LeftArm"
    leftArmNode.position = armPositions.left
    characterGroup.addChildNode(leftArmNode)

    // Left arm sleeve
    let leftArmSleeveGeometry = SCNBox(
      width: armSleeveDimensions.width,
      height: armSleeveDimensions.height,
      length: armSleeveDimensions.length,
      chamferRadius: 0
    )
    leftArmSleeveGeometry.materials = createArmMaterials(
      from: skinImage,
      isLeft: true,
      isSleeve: true
    )
    leftArmSleeveNode = SCNNode(geometry: leftArmSleeveGeometry)
    leftArmSleeveNode.name = "LeftArmSleeve"
    leftArmSleeveNode.position = armPositions.left
    characterGroup.addChildNode(leftArmSleeveNode)
  }

  private func createLegs() {
    guard let skinImage = skinImage else { return }

    // Right leg (4x12x4)
    let rightLegGeometry = SCNBox(
      width: 4,
      height: 12,
      length: 4,
      chamferRadius: 0
    )
    rightLegGeometry.materials = createLegMaterials(
      from: skinImage,
      isLeft: false,
      isSleeve: false
    )
    rightLegNode = SCNNode(geometry: rightLegGeometry)
    rightLegNode.name = "RightLeg"
    rightLegNode.position = SCNVector3(-2, -6, 0)  // Right bottom of body
    characterGroup.addChildNode(rightLegNode)

    // Right leg pants (4.5x12.5x4.5)
    let rightLegSleeveGeometry = SCNBox(
      width: 4.5,
      height: 12.5,
      length: 4.5,
      chamferRadius: 0
    )
    rightLegSleeveGeometry.materials = createLegMaterials(
      from: skinImage,
      isLeft: false,
      isSleeve: true
    )
    rightLegSleeveNode = SCNNode(geometry: rightLegSleeveGeometry)
    rightLegSleeveNode.name = "RightLegSleeve"
    rightLegSleeveNode.position = SCNVector3(-2, -6, 0)
    characterGroup.addChildNode(rightLegSleeveNode)

    // Left leg (4x12x4)
    let leftLegGeometry = SCNBox(
      width: 4,
      height: 12,
      length: 4,
      chamferRadius: 0
    )
    leftLegGeometry.materials = createLegMaterials(
      from: skinImage,
      isLeft: true,
      isSleeve: false
    )
    leftLegNode = SCNNode(geometry: leftLegGeometry)
    leftLegNode.name = "LeftLeg"
    leftLegNode.position = SCNVector3(2, -6, 0)  // Left bottom of body
    characterGroup.addChildNode(leftLegNode)

    // Left leg pants (4.5x12.5x4.5)
    let leftLegSleeveGeometry = SCNBox(
      width: 4.5,
      height: 12.5,
      length: 4.5,
      chamferRadius: 0
    )
    leftLegSleeveGeometry.materials = createLegMaterials(
      from: skinImage,
      isLeft: true,
      isSleeve: true
    )
    leftLegSleeveNode = SCNNode(geometry: leftLegSleeveGeometry)
    leftLegSleeveNode.name = "LeftLegSleeve"
    leftLegSleeveNode.position = SCNVector3(2, -6, 0)
    characterGroup.addChildNode(leftLegSleeveNode)
  }
}

// MARK: - Usage Helper
extension SceneKitCharacterViewController {

  static func presentInNewWindow(playerModel: PlayerModel = .steve) {
    let characterVC = SceneKitCharacterViewController(playerModel: playerModel)
    let window = NSWindow(
      contentRect: NSRect(x: 300, y: 300, width: 800, height: 600),
      styleMask: [.titled, .closable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "SceneKit Minecraft Character - \(playerModel.displayName)"
    window.contentViewController = characterVC
    window.makeKeyAndOrderFront(nil)
  }
}

#Preview {
  SceneKitCharacterViewController()
}
