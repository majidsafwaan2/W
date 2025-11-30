#!/bin/bash

# Quick test script for Quran App

echo "📱 Quran App Testing Script"
echo "=========================="
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

echo "1️⃣ Checking Flutter setup..."
flutter doctor | grep -E "(Flutter|Xcode|Chrome)" | head -3
echo ""

echo "2️⃣ Installing dependencies..."
flutter pub get
echo ""

echo "3️⃣ Available devices:"
flutter devices
echo ""

echo "4️⃣ Available iOS Simulators:"
xcrun simctl list devices available | grep -i "iphone\|ipad" | head -3
echo ""

echo "🚀 Starting iOS Simulator..."
open -a Simulator

echo "⏳ Waiting 5 seconds for simulator to boot..."
sleep 5

echo "📦 Building and running app..."
flutter run

