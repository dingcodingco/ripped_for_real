#!/bin/bash

echo "Building iOS version without ads for App Store review..."

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build iOS app
echo "Building iOS app..."
flutter build ios --release

echo "iOS build complete!"
echo ""
echo "IMPORTANT NOTES:"
echo "1. The ads have been disabled for iOS in the code"
echo "2. Make sure to test the app thoroughly on iOS devices"
echo "3. Take new screenshots without any ad elements"
echo "4. To re-enable ads later, change _adsEnabled to true in ad_service.dart"
echo ""
echo "The build is located at: build/ios/iphoneos/"