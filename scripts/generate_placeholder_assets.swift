import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconDirectory = root.appending(path: "calnora/Assets/IconComposer")
let catalogDirectory = root.appending(path: "calnora/Assets.xcassets")

try FileManager.default.createDirectory(at: iconDirectory, withIntermediateDirectories: true)

func savePNG(_ image: NSImage, to url: URL) throws {
    let size = image.size
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    bitmap.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    image.draw(
        in: NSRect(origin: .zero, size: size),
        from: NSRect(origin: .zero, size: size),
        operation: .copy,
        fraction: 1
    )
    NSGraphicsContext.restoreGraphicsState()

    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    try data.write(to: url)
}

func makeImage(size: CGFloat = 1024, draw: (NSRect) -> Void) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    draw(NSRect(x: 0, y: 0, width: size, height: size))
    image.unlockFocus()
    return image
}

func drawCenteredRing(in rect: NSRect, lineWidth: CGFloat = 82) {
    let ringRect = rect.insetBy(dx: 235, dy: 235)
    let path = NSBezierPath()
    path.appendArc(
        withCenter: NSPoint(x: rect.midX, y: rect.midY),
        radius: ringRect.width / 2,
        startAngle: 30,
        endAngle: 330,
        clockwise: false
    )
    path.lineWidth = lineWidth
    path.lineCapStyle = .round
    NSColor.systemPink.setStroke()
    path.stroke()

    let accent = NSBezierPath()
    accent.appendArc(
        withCenter: NSPoint(x: rect.midX, y: rect.midY),
        radius: ringRect.width / 2,
        startAngle: 332,
        endAngle: 62,
        clockwise: false
    )
    accent.lineWidth = lineWidth
    accent.lineCapStyle = .round
    NSColor.systemOrange.setStroke()
    accent.stroke()
}

let background = makeImage { rect in
    NSGradient(colors: [
        NSColor.systemTeal.blended(withFraction: 0.25, of: .black) ?? .systemTeal,
        NSColor.systemBlue,
        NSColor.systemGreen.blended(withFraction: 0.18, of: .white) ?? .systemGreen
    ])?.draw(in: rect, angle: 42)
}
try savePNG(background, to: iconDirectory.appending(path: "AppIcon_Background.png"))

let baseGradient = makeImage { rect in
    NSColor.systemMint.withAlphaComponent(0.28).setFill()
    NSBezierPath(ovalIn: rect.insetBy(dx: 90, dy: 210)).fill()
    NSColor.systemPink.withAlphaComponent(0.16).setFill()
    NSBezierPath(ovalIn: NSRect(x: 590, y: 650, width: 280, height: 220)).fill()
}
try savePNG(baseGradient, to: iconDirectory.appending(path: "AppIcon_BaseGradient.png"))

let depthShadow = makeImage { rect in
    NSColor.black.withAlphaComponent(0.18).setFill()
    NSBezierPath(ovalIn: NSRect(x: 260, y: 220, width: 520, height: 460)).fill()
}
try savePNG(depthShadow, to: iconDirectory.appending(path: "AppIcon_DepthShadow.png"))

let ring = makeImage { rect in
    drawCenteredRing(in: rect)
}
try savePNG(ring, to: iconDirectory.appending(path: "AppIcon_CalorieRing.png"))

let leaf = makeImage { rect in
    let leafPath = NSBezierPath()
    leafPath.move(to: NSPoint(x: rect.midX - 42, y: rect.midY - 56))
    leafPath.curve(
        to: NSPoint(x: rect.midX + 160, y: rect.midY + 64),
        controlPoint1: NSPoint(x: rect.midX + 20, y: rect.midY + 78),
        controlPoint2: NSPoint(x: rect.midX + 124, y: rect.midY + 118)
    )
    leafPath.curve(
        to: NSPoint(x: rect.midX - 42, y: rect.midY - 56),
        controlPoint1: NSPoint(x: rect.midX + 86, y: rect.midY + 20),
        controlPoint2: NSPoint(x: rect.midX + 6, y: rect.midY - 42)
    )
    NSColor.systemMint.setFill()
    leafPath.fill()

    NSColor.white.withAlphaComponent(0.58).setStroke()
    leafPath.lineWidth = 8
    leafPath.stroke()
}
try savePNG(leaf, to: iconDirectory.appending(path: "AppIcon_NutritionLeaf.png"))

let spark = makeImage { rect in
    let center = NSPoint(x: rect.midX + 185, y: rect.midY + 205)
    NSColor.white.withAlphaComponent(0.92).setFill()
    let vertical = NSBezierPath(roundedRect: NSRect(x: center.x - 8, y: center.y - 70, width: 16, height: 140), xRadius: 8, yRadius: 8)
    let horizontal = NSBezierPath(roundedRect: NSRect(x: center.x - 70, y: center.y - 8, width: 140, height: 16), xRadius: 8, yRadius: 8)
    vertical.fill()
    horizontal.fill()
    NSColor.systemPurple.withAlphaComponent(0.26).setFill()
    NSBezierPath(ovalIn: NSRect(x: center.x - 80, y: center.y - 80, width: 160, height: 160)).fill()
}
try savePNG(spark, to: iconDirectory.appending(path: "AppIcon_AISpark.png"))

let highlight = makeImage { rect in
    NSColor.white.withAlphaComponent(0.24).setStroke()
    let path = NSBezierPath()
    path.appendArc(withCenter: NSPoint(x: rect.midX, y: rect.midY), radius: 310, startAngle: 92, endAngle: 158)
    path.lineWidth = 28
    path.lineCapStyle = .round
    path.stroke()
}
try savePNG(highlight, to: iconDirectory.appending(path: "AppIcon_GlassHighlight.png"))

let composite = makeImage { rect in
    background.draw(in: rect)
    baseGradient.draw(in: rect)
    depthShadow.draw(in: rect)
    ring.draw(in: rect)
    leaf.draw(in: rect)
    spark.draw(in: rect)
    highlight.draw(in: rect)
}
try savePNG(composite, to: iconDirectory.appending(path: "AppIcon_CompositePreview.png"))

let marketingAssets: [(String, String, NSColor)] = [
    ("onboarding_welcome_hero", "sparkles", .systemTeal),
    ("ai_meal_estimate", "fork.knife.circle", .systemPink),
    ("coach_companion", "sparkle.magnifyingglass", .systemPurple),
    ("empty_meals", "plus.circle", .systemOrange),
    ("empty_insights", "chart.xyaxis.line", .systemBlue),
    ("pro_card_background", "sparkles", .systemPink),
    ("high_protein_pack_cover", "takeoutbag.and.cup.and.straw", .systemGreen),
    ("privacy_local_ai", "checkmark.shield", .systemIndigo),
    ("app_store_promo_background", "heart.text.square", .systemMint)
]

for (name, symbol, color) in marketingAssets {
    let directory = catalogDirectory.appending(path: "\(name).imageset")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let image = makeImage(size: 1024) { rect in
        NSGradient(colors: [color.withAlphaComponent(0.9), .white.withAlphaComponent(0.35), .systemGray.withAlphaComponent(0.18)])?.draw(in: rect, angle: 38)
        NSColor.white.withAlphaComponent(0.32).setFill()
        NSBezierPath(roundedRect: rect.insetBy(dx: 170, dy: 250), xRadius: 64, yRadius: 64).fill()
        let symbolImage = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) ?? NSImage()
        symbolImage.draw(in: rect.insetBy(dx: 365, dy: 365), from: .zero, operation: .sourceOver, fraction: 0.92)
    }
    try savePNG(image, to: directory.appending(path: "\(name).png"))
}
