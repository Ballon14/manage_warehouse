# Flutter SDK Patch for Android Build

## Root Cause
File: `/home/iqbal/development/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt`
Lines: 744-747
Error: `filePermissions`, `user`, `read`, `write` undefined

## Manual Fix Required

### Step 1: Edit Flutter SDK File
```bash
nano /home/iqbal/development/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt
```

### Step 2: Find Lines 744-747
Look for code like:
```kotlin
output.filePermissions {
    user {
        read = true
        write = true
    }
}
```

### Step 3: Comment Out Those Lines
```kotlin
// output.filePermissions {
//     user {
//         read = true
//         write = true
//     }
// }
```

### Step 4: Rebuild
```bash
cd /home/iqbal/project/flutter/stockflow2
flutter clean
flutter build apk --release
```

## Alternative: Use Flutter 3.27 for Android

```bash
# In a separate terminal/directory
cd ~
git clone https://github.com/flutter/flutter.git flutter-3.27
cd flutter-3.27
git checkout 3.27.0
export PATH="$HOME/flutter-3.27/bin:$PATH"

# Build APK
cd /home/iqbal/project/flutter/stockflow2
flutter build apk --release
```

## Or: GitHub Actions CI/CD
Create `.github/workflows/android-release.yml`:
```yaml
name: Android Release
on:
  push:
    branches: [main]
    
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```
