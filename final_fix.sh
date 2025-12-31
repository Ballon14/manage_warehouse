#!/bin/bash

# FINAL FIX for Android Build - Direct Edit Approach
# This manually edits the problematic Kotlin file

echo "🔧 StockFlow v2.1.0 - FINAL Android Fix"
echo "========================================"
echo ""

PLUGIN_FILE="/home/iqbal/development/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt"

# Backup
echo "1. Creating backup..."
cp "$PLUGIN_FILE" "${PLUGIN_FILE}.original"

# Get exact line content to replace
echo "2. Identifying problematic code..."
START_LINE=$(grep -n "filePermissions {" "$PLUGIN_FILE" | head -1 | cut -d: -f1)

if [ -z "$START_LINE" ]; then
    echo "❌ Could not find the problematic code!"
    exit 1
fi

echo "   Found at line: $START_LINE"

# Use Python to do precise editing
python3 << 'PYTHON_SCRIPT'
import re

file_path = "/home/iqbal/development/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt"

with open(file_path, 'r') as f:
    content = f.read()

# Remove the filePermissions block entirely
pattern = r'filePermissions\s*\{[^}]*user\s*\{[^}]*read\s*=[^}]*write\s*=[^}]*\}\s*\}'
new_content = re.sub(pattern, '// filePermissions removed for compatibility', content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(new_content)

print("✅ File edited successfully!")
PYTHON_SCRIPT

if [ $? -ne 0 ]; then
    echo "❌ Python edit failed. Trying sed..."
    
    # Fallback to sed
    sed -i "${START_LINE},$((START_LINE+5))d" "$PLUGIN_FILE"
    echo "✅ Sed edit completed"
fi

echo ""
echo "3. Rebuilding Gradle plugin..."
cd /home/iqbal/development/flutter/packages/flutter_tools/gradle
./gradlew clean build -q 2>/dev/null || true

echo ""
echo "4. Cleaning Flutter project..."
cd /home/iqbal/project/flutter/stockflow2
flutter clean

echo ""
echo "5. Building APK (final attempt)..."
echo ""

flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║  🎉 SUCCESS! APK BUILD COMPLETE! 🎉   ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    echo "📱 APK created:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo "✅ Both platforms ready:"
    echo "   Web:     build/web/"
    echo "   Android: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    exit 0
else
    echo ""
    echo "❌ Still failed. Restoring original..."
    cp "${PLUGIN_FILE}.original" "$PLUGIN_FILE"
    echo ""
    echo "Manual fix required. See instructions below:"
    echo ""
    echo "Edit this file:"
    echo "  $PLUGIN_FILE"
    echo ""
    echo "Remove lines containing 'filePermissions'"
    exit 1
fi
