# Changelog

## 4.0.0 (Feb 22, 2021)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v5.0.0
#### Applicaster Android SDK Core version: 8.3.1
#### Android target API: 29


### Breaking changes:
- QuickBrick updated to 5.0.0 [#105](https://github.com/applicaster/zapp-platform-android/pull/105)

## QuickBrick SDK changes:

- New TV components:
    - support for Theme plugin with specific properties for TV platforms, including screen & component margins, and content anchoring (determines how many pixels from the top of the screen content is anchored when focus moves)
    - support on TV for Horizontal List (QB) and Grid (QB) plugin. These plugins should be used instead of the legacy horizontal list & grid component. These plugins support full customization of styling & spacing
    - support for Group, Group Info & Group info cell plugins on TV platforms, which allow to create Groups on TV layouts, and support full customization of TV components headers
    - Advanced customization capabilities on component cells with the use of the TV Cell 1 power cell plugin
    - Brand new Screen Picker TV (QB) plugin, with advanced configuration for styling of the screen selector part of the component
- pipes v2:
    - improved compatibility of pipes v2 layout, on mobile & TV platforms
    - separate entry / screen & search context to inject data in feeds
    - support for v2 feeds from plugins, available on continue watching & local favourites plugins


## 3.0.0 (Feb 8, 2021)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v4.1.6
#### Applicaster Android SDK Core version: 8.3.1
#### Android target API: 29


### Breaking changes:
- QuickBrick updated to 4.1.6 [#103](https://github.com/applicaster/zapp-platform-android/pull/103)

### Improvements:
- App build parameters are now fetched by url [#100](https://github.com/applicaster/zapp-platform-android/pull/100)
- Special symbols in application name are now escaped in generated Android xml localization files [#83](https://github.com/applicaster/zapp-platform-android/pull/83)
- Support for OAuth2 schemes added [#101](https://github.com/applicaster/zapp-platform-android/pull/101)

### Changes
- Microsoft AppCenter Distribution SDK removed [#102](https://github.com/applicaster/zapp-platform-android/pull/102)

### Core SDK improvements:
- Secure Shared Preferences storage added [#1461](https://github.com/applicaster/applicaster-android-sdk/pull/1461)
- Handling of malformed malformed SSL pins input improved [#1460](https://github.com/applicaster/applicaster-android-sdk/pull/1460)
- Push notification react-native bridge exported to QuickBrick SDK [#1459](https://github.com/applicaster/applicaster-android-sdk/pull/1459)
- `remove`, `getNamespace` and `removeNamespace` methods added to the local storage [#1456](https://github.com/applicaster/applicaster-android-sdk/pull/1456)
- `LocalizationHelper` class added to extract localizations from plugins [#1457](https://github.com/applicaster/applicaster-android-sdk/pull/1457)


## 2.0.0 (Dec 3, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v4.1.4
#### Applicaster Android SDK Core version: 8.0.1
#### Android target API: 29

### Breaking changes:
- QuickBrick updated to 4.1.4 [#81](https://github.com/applicaster/zapp-platform-android/pull/81)

### Improvements:
- CI application updated [#74](https://github.com/applicaster/zapp-platform-android/pull/74)
- Tablet orientation setting added [71](https://github.com/applicaster/zapp-platform-android/pull/71),[72](https://github.com/applicaster/zapp-platform-android/pull/72), [71](https://github.com/applicaster/zapp-platform-android/pull/71),[73](https://github.com/applicaster/zapp-platform-android/pull/73)
- Firebase push notification DeepLink support added [#69](https://github.com/applicaster/zapp-platform-android/pull/69), [#70](https://github.com/applicaster/zapp-platform-android/pull/70)
- Pre-load sequence improved [#67](https://github.com/applicaster/zapp-platform-android/pull/67)
- RtL support improved [#66](https://github.com/applicaster/zapp-platform-android/pull/66)

### Core SDK improvements:
- Localization support fixes [#1455](https://github.com/applicaster/applicaster-android-sdk/pull/1455)
- Firebase BoM upgraded to 26.0.0 [#1446](https://github.com/applicaster/applicaster-android-sdk/pull/1446)
- Glide upgraded to 4.11.0 [#1439](https://github.com/applicaster/applicaster-android-sdk/pull/1439)
- Dynamically toggled plugins introduced [#1386](https://github.com/applicaster/applicaster-android-sdk/pull/1386)
- Warning added if more that one push provider is found [#1437](https://github.com/applicaster/applicaster-android-sdk/pull/1437)


## 1.0.1 (Nov 20, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v4.1.1
#### Applicaster Android SDK Core version: 6.4.0
#### Android target API: 29

## Fixes:
- Fastlane MS AppCenter publishing fixed [#78](https://github.com/applicaster/zapp-platform-android/pull/78)


## 1.0.0 (Sept 21, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v4.1.1
#### Applicaster Android SDK Core version: 6.4.0
#### Android target API: 29


### Improvements:
- SSL pinning support added [#45](https://github.com/applicaster/zapp-platform-android/pull/45)
- Native startup plugin hooks re-introduced from legacy SDK [#47](https://github.com/applicaster/zapp-platform-android/pull/47)
- All React Native classes and interfaces are preserved by proguard by default [#44](https://github.com/applicaster/zapp-platform-android/pull/44), [#60](https://github.com/applicaster/zapp-platform-android/pull/60)
- Support for non-minified react-native bundles in Zapp added [#48](https://github.com/applicaster/zapp-platform-android/pull/48), [#49](https://github.com/applicaster/zapp-platform-android/pull/49), [#54](https://github.com/applicaster/zapp-platform-android/pull/54)
- Analytics events now contain build version, rivers ID and device ID [#55](https://github.com/applicaster/zapp-platform-android/pull/55), [#53](https://github.com/applicaster/zapp-platform-android/pull/53)
- Default QuickBrick react native packages added to the SDK: react-native-webview, react-native-fast-image, react-native-linear-gradient, react-native-svg, react-community-viewpager [#56](https://github.com/applicaster/zapp-platform-android/pull/56), [#59](https://github.com/applicaster/zapp-platform-android/pull/59), [#57](https://github.com/applicaster/zapp-platform-android/pull/57), [#46](https://github.com/applicaster/zapp-platform-android/pull/46), [#61](https://github.com/applicaster/zapp-platform-android/pull/61)
- Applicaster SDK logger can now be routed to X-Ray [#1420](https://github.com/applicaster/applicaster-android-sdk/pull/1420)
- Applicaster Core SDK plugin manager now handles pure React Native plugins gracefully [#1427](https://github.com/applicaster/applicaster-android-sdk/pull/1427)

## Changes:
- Updated to QuickBrick 4.1.1 [#63](https://github.com/applicaster/zapp-platform-android/pull/63)
- New unified key background_color style key added instead of app_background [#65](https://github.com/applicaster/zapp-platform-android/pull/65)

## Fixes:
- Use custom animated drawable AnimatedImageView for loading spinner to fix visual glitches on FireTV [#65](https://github.com/applicaster/zapp-platform-android/pull/65)


## 21.0.0 (July 1, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.62.2
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v4.0.0
#### Applicaster Android SDK Core version: 6.2.0
#### Android target API: 29


### Improvements:
- Zapp apk are now uploaded to S3 [#30](https://github.com/applicaster/zapp-platform-android/pull/30), [#33](https://github.com/applicaster/zapp-platform-android/pull/33)
- SDK CI flow improved  [#31](https://github.com/applicaster/zapp-platform-android/pull/31), [#35](https://github.com/applicaster/zapp-platform-android/pull/35)

### Changes:
- React Native version updated to 0.62.2 [#12](https://github.com/applicaster/zapp-platform-android/pull/12)
- Updated Android API level and build tools 29.0.3 [#29](https://github.com/applicaster/zapp-platform-android/pull/29)
- Applicaster Android SDK Core updated to version 6.2.0 [#38](https://github.com/applicaster/zapp-platform-android/pull/38)
- Both core and non-core Applicaster Android SDK gradle dependencies are properly handled now [#39](https://github.com/applicaster/zapp-platform-android/pull/39)
- Default QuickBrick version updated to version 4.0.0 [#41](https://github.com/applicaster/zapp-platform-android/pull/41)


### Fixes:
- Gamepad feature flag removed from TV manifest [#40](https://github.com/applicaster/zapp-platform-android/pull/40)


## 20.2.0 (June 9, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.59.10
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v3.0.3
#### Applicaster Android SDK Core version: 6.1.1


### Improvements:
- Push notifications can be now disabled for current device [#1407](https://github.com/applicaster/applicaster-android-sdk/pull/1407) [#1412](https://github.com/applicaster/applicaster-android-sdk/pull/1412)

### Changes:
- Applicaster Android SDK Core updated to version 6.1.1 [#23](https://github.com/applicaster/zapp-platform-android/pull/23)
- Default QuickBrick version updated to version 3.0.3 [#28](https://github.com/applicaster/zapp-platform-android/pull/28)
- com.google.ads.interactivemedia.v3:interactivemedia downgraded to 3.11.3 as last version that can play IMA properly in ExoPlayer [#1410](https://github.com/applicaster/applicaster-android-sdk/pull/1410)
- kotlinx-coroutines-android updated to the latest version 1.3.6 [#1404](https://github.com/applicaster/applicaster-android-sdk/pull/1404)

### Fixes:
- Support for round launcher icons fixed [#21](https://github.com/applicaster/zapp-platform-android/pull/21)
- Zapp builds for Amazon Fire TV fixed [#24](https://github.com/applicaster/zapp-platform-android/pull/24)
- Lost focus issue when app is returning from the background on TV is fixed [#25](https://github.com/applicaster/zapp-platform-android/pull/25)
- DeepLink for push notifications from UrbanAirship fixed [#26](https://github.com/applicaster/zapp-platform-android/pull/26)
- GPS feature flag removed from TV manifest [#27](https://github.com/applicaster/zapp-platform-android/pull/27)
- Application data constants fixed for Amazon Fire TV [#34](https://github.com/applicaster/zapp-platform-android/pull/34)
- PlayerPluginManager events fixed [#1408](https://github.com/applicaster/applicaster-android-sdk/pull/1408)


## 20.1.0 (May 21, 2020)

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.59.10
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v3.0.1
#### Applicaster Android SDK Core version: 5.1.0

### Improvements:
- Project now uses lightweight Core Applicaster Android SDK [#8](https://github.com/applicaster/zapp-platform-android/pull/8)
- Main activity now has singleTask flag for better deep linking experience [#17](https://github.com/applicaster/zapp-platform-android/pull/17)
- QuickBrick version updated to v3.0.1 [#18](https://github.com/applicaster/zapp-platform-android/pull/18)
- Build version added to the apk file name published to app center [#19](https://github.com/applicaster/zapp-platform-android/pull/19)

### Changes:
- App bundle can be build even if store is not connected in MS AppCenter [#4](https://github.com/applicaster/zapp-platform-android/pull/4)
- Custom s3 host can be defined [#5](https://github.com/applicaster/zapp-platform-android/pull/5)
- QuickBrick initialization delayed until plugins remote configuration is loaded [#16](https://github.com/applicaster/zapp-platform-android/pull/17)
- AndroidX SwipeRefreshLayout dependency added [#20](https://github.com/applicaster/zapp-platform-android/pull/20)

### Fixes:
- Screen insets fixed [#1](https://github.com/applicaster/zapp-platform-android/pull/1) [#2](https://github.com/applicaster/zapp-platform-android/pull/2)
- Symlinks for tv apk and mapping where not created properly [#3](https://github.com/applicaster/zapp-platform-android/pull/3)
- React native initialization fail for Zapp builds fixed [#7](https://github.com/applicaster/zapp-platform-android/pull/7)
- Intro layout fixed [#10](https://github.com/applicaster/zapp-platform-android/pull/10)

## 20.0.0 (March 11, 2020)
First official release.

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.59.10
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v2.3.0
#### Applicaster Android SDK version: 5.0.3

### Improvements:
- CI optimization [bdcba0](https://github.com/applicaster/zapp-platform-android/commit/bdcba015c30f6d65446864f124d54f8239340e4b)
- New intro design [bf82b2](https://github.com/applicaster/zapp-platform-android/commit/bf82b23183d4ce0c5911991b6f2cc965f480f218)

### Changes:
- Switch back to Applicaster Android SDK from Core SDK dependency [fdb59e](https://github.com/applicaster/zapp-android-platform/commit/fdb59e86395f02df164579a18dc358b5bf6605fd)

### Fixes:
- CI Bundle build fixed [1025e0](https://github.com/applicaster/zapp-platform-android/commit/1025e047f3f580baa1e1955106da7c907daee57f)
- CI AppCenter build fix merged from ZappAndroid [4aa00f](https://github.com/applicaster/zapp-android-platform/commit/4aa00fa8177dce451c3b66faea5fe0cfe82de654)

## 20.0.0-alpha (March 6, 2020)
Initial alpha release.

#### Minimum Android OS supported: 4.4.x
#### React Native version: 0.59.10
#### Gradle version: 5.6.4
#### Android Studio Gradle Plugin version: 3.5.3
#### QuickBrick version: v2.3.0
#### Applicaster Core SDK version: 0.1.0