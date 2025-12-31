#!/bin/bash

# Auto-fix Flutter SDK - More robust version

set -e

echo "🔧 StockFlow v2.1.0 - Android Build Auto-Fix"
echo "============================================="
echo ""

FLUTTER_PLUGIN="/home/iqbal/development/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt"
BACKUP_FILE="${FLUTTER_PLUGIN}.backup.$(date +%s)"

# Backup
echo "📦 Backing up Flutter SDK..."
cp "$FLUTTER_PLUGIN" "$BACKUP_FILE"

# Patch using pattern matching (more robust than line numbers)
echo "🔨 Applying patch..."
cat > /tmp/flutter_patch.sed << 'EOF'
/output\.filePermissions/,/^[[:space:]]*}[[:space:]]*$/ {
    s/^/\/\/ /
}
EOF

sed -i -f /tmp/flutter_patch.sed "$FLUTTER_PLUGIN"
rm /tmp/flutter_patch.sed

# Verify
if grep -q "// output.filePermissions" "$FLUTTER_PLUGIN"; then
    echo "✅ Patch applied!"
else
    echo "⚠️  Trying alternative patch method..."
    cp "$BACKUP_FILE" "$FLUTTER_PLUGIN"
    
    # Alternative: Remove the entire block
    awk '
    /output\.filePermissions/ {skip=1}
    skip && /^[[:space:]]*\}[[:space:]]*$/ {skip=0; next}
    !skip {print}
    ' "$BACKUP_FILE" > "${FLUTTER_PLUGIN}.new"
    
    mv "${FLUTTER_PLUGIN}.new" "$FLUTTER_PLUGIN"
    echo "✅ Alternative patch applied!"
fi

echo ""
echo "🧹 Cleaning project..."
cd /home/iqbal/project/flutter/stockflow2
flutter clean > /dev/null 2>&1

echo "📦 Getting dependencies..."
flutter pub get > /dev/null 2>&1

echo ""
echo "🏗️  Building APK..."
echo "   This will take 2-3 minutes..."
echo ""

if flutter build apk --release; then
    echo ""
    echo "═══════════════════════════════════════"
    echo "🎉  SUCCESS! APK BUILD COMPLETE!"
    echo "═══════════════════════════════════════"
    echo ""
    echo "📱 APK Location:"
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "   $APK_PATH"
    echo "   Size: $APK_SIZE"
    echo ""
    echo "✅ StockFlow v2.1.0 is ready for deployment!"
    echo ""
    echo "📦 Available Builds:"
    echo "   ✅ Web:     build/web/"
    echo "   ✅ Android: $APK_PATH"
    echo ""
    echo "🚀 You can now deploy both platforms with the same source code!"
    echo ""
    exit 0
else
    echo ""
    echo "❌ Build failed. Restoring Flutter SDK..."
    cp "$BACKUP_FILE" "$FLUTTER_PLUGIN"
    echo ""
    echo "Please check the error above."
    exit 1
fi
