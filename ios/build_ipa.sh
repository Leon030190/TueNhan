#!/bin/bash
set -e

echo "=== BẮT ĐẦU BUILD TUỆ NHÃN IPA QUA XCODE ==="

# 1. Clean
xcodebuild clean -project TueNhan.xcodeproj -scheme TueNhan

# 2. Archive
xcodebuild archive \
    -project TueNhan.xcodeproj \
    -scheme TueNhan \
    -configuration Release \
    -archivePath build/TueNhan.xcarchive \
    CODE_SIGNING_ALLOWED=NO

# 3. Export IPA
mkdir -p build/Payload
cp -r build/TueNhan.xcarchive/Products/Applications/TueNhan.app build/Payload/
cd build
zip -r ../TueNhan.ipa Payload
cd ..

echo "=== BUILD THÀNH CÔNG: TueNhan.ipa ==="
