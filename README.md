# Calnora

Calnora is a starter multiplatform SwiftUI scaffold for a private AI calorie, macro, meal logging, and nutrition coaching app.

## Project Status

This was treated as an existing-project change. The repository already contained `calnora.xcodeproj`, a minimal SwiftUI app target, test targets, and package references for:

- OnboardingKit
- FlexStore
- EZSwiftData
- GentleNotification
- EZCharts

The target/scheme remains `calnora`; the home screen display name is `Calnora`, and the bundle ID is `com.gerardgomez.calnora`.

## Architecture

The app target is organized under `calnora/`:

- `App/`: app state, routing, environment, SwiftData container setup
- `Models/`: SwiftData persistent models
- `Stores/`: UI-facing stores and package adapters
- `Services/`: nutrition math, quotas, Foundation Models abstraction, seeds, product IDs
- `DesignSystem/`: Health/Wallet-inspired cards, metric tiles, Liquid Glass wrappers, semantic colors
- `Views/`: onboarding, dashboard, meals, coach, history, insights, paywall, settings, premium pack
- `Resources/`: local foods, high-protein pack, StoreKit config
- `Assets/`: Images 2.0 plan and Icon Composer layers

## Package Responsibilities

- OnboardingKit powers `OnboardingView` through `PagedOnboardingView` and `OnboardingPage`.
- FlexStore owns StoreKit logic through `StoreKitService<CalnoraSubscriptionTier>`.
- EZSwiftData creates the SwiftData container through `ModelContainerFactory`.
- GentleNotification handles system notification permissions and scheduling through `Notify`.
- EZCharts wraps dashboard and insight charts through `EZAnimatedChart`, `EZAnimatedSectorChart`, and helpers.

## Foundation Models

`CoachEngine` isolates AI features from SwiftUI. `FoundationModelsCoachEngine` uses Apple Foundation Models when available and falls back to `MockCoachEngine` when Apple Intelligence is off, unavailable, or not ready.

The coach is constrained to supportive wellness guidance only. It must not diagnose, treat, promise weight loss, encourage extreme restriction, or claim estimates are exact.

## Monetization

Product IDs:

- `com.gerardgomez.calnora.pro.weekly`
- `com.gerardgomez.calnora.pro.monthly`
- `com.gerardgomez.calnora.pro.yearly`
- `com.gerardgomez.calnora.pro.lifetime`
- `com.gerardgomez.calnora.pack.highprotein`

The included StoreKit config is `calnora/Resources/StoreKit.storekit`. Configure matching products in App Store Connect and replace the placeholder subscription group identifier in `CalnoraProductID.subscriptionGroupID` if your App Store Connect group ID differs.

## Images 2.0 And Icon Composer

Images 2.0 was not available as a repo-bound export tool in this environment. Placeholder PNGs and exact generation prompts are included.

- Asset plan: `calnora/Assets/Assets.md`
- Icon Composer manifest: `calnora/Assets/IconComposer/AppIconLayerManifest.json`
- Icon Composer instructions: `calnora/Assets/IconComposer/README.md`

Replace placeholders with final reviewed Images 2.0 exports before release.

## Build And Launch

Run:

```sh
./scripts/build_and_launch.sh
```

Defaults:

- Project: `calnora.xcodeproj`
- Scheme: `calnora`
- Configuration: `Debug`
- Simulator: `iPhone 17 Pro`
- Bundle ID: `com.gerardgomez.calnora`

Override example:

```sh
SIMULATOR_NAME="iPhone 17" ./scripts/build_and_launch.sh
```

## Validation

Focused unit tests cover:

- calorie target calculations
- macro calculations
- meal totals
- daily totals
- weekly averages
- streaks
- quota limits and weekly reset
- Pro/lifetime/high-protein entitlements
- product ID constants
- mock coach fallback

Useful commands:

```sh
xcodebuild -project calnora.xcodeproj -scheme calnora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project calnora.xcodeproj -scheme calnora -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO test
```

## Privacy And Safety

Calnora is local-first by default. AI nutrition estimates are approximate and editable. The app provides informational wellness guidance only and is not a medical device or a replacement for professional care.

Placeholders:

- Privacy Policy: `https://example.com/privacy`
- Terms: `https://example.com/terms`
