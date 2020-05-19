# Changelog


## 20.1.0 (May 20, 2020)

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