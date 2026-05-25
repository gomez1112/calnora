# Calnora Icon Composer Layers

These PNGs are placeholder 1024x1024 layers generated locally so the app and asset pipeline are ready before final Images 2.0 artwork is exported.

Import into Apple Icon Composer in this order:

1. `AppIcon_Background.png`
2. `AppIcon_BaseGradient.png`
3. `AppIcon_DepthShadow.png`
4. `AppIcon_CalorieRing.png`
5. `AppIcon_NutritionLeaf.png`
6. `AppIcon_AISpark.png`
7. `AppIcon_GlassHighlight.png`

Recommended depth:

- Depth/parallax: `AppIcon_BaseGradient.png`, `AppIcon_CalorieRing.png`, `AppIcon_NutritionLeaf.png`, `AppIcon_AISpark.png`
- Keep subtle: `AppIcon_DepthShadow.png`, `AppIcon_GlassHighlight.png`
- Keep fixed: `AppIcon_Background.png`

Preview the icon at 1024, 180, 120, 60, 40, and 29px. The calorie ring, leaf, and spark should remain visible at every size.

When final Images 2.0 layers are ready, replace the PNG files in this folder without changing names. Keep every layer exactly 1024x1024 and preserve transparency for every foreground layer.

Export final app icon assets from Icon Composer, then update `Assets.xcassets/AppIcon.appiconset`. `AppIcon_CompositePreview.png` is only a preview/fallback and is not the layered source.
