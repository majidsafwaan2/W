# Quick Testing Guide

## Current Setup Status

✅ Flutter installed  
✅ Xcode available (iOS 26.1 simulator not installed yet)  
❌ Android SDK not installed  
✅ macOS desktop available  
✅ Chrome browser available  

## Option 1: Test on iOS Simulator (Recommended for full features)

### Setup iOS Simulator:
1. Open Xcode
2. Go to **Xcode > Settings > Components** (or **Platforms** tab)
3. Download and install **iOS 26.1 Simulator** (or latest available)
4. Wait for download/install to complete

### Run on iOS Simulator:
```bash
cd /Users/safwaan/G/Quran-App

# List available simulators
xcrun simctl list devices available

# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

**Note**: Simulators may have limited microphone support. For full microphone testing, use a physical iOS device.

## Option 2: Test on Physical iOS Device (Best for microphone)

### Requirements:
- iPhone/iPad connected via USB
- Device in Developer Mode
- Trusted computer

### Steps:
```bash
cd /Users/safwaan/G/Quran-App

# Connect your iOS device via USB
# Unlock device and trust the computer if prompted

# Check if device is detected
flutter devices

# Run on device
flutter run
```

### Enable Developer Mode on iOS:
1. Go to **Settings > Privacy & Security**
2. Scroll to **Developer Mode**
3. Toggle it ON
4. Restart device when prompted

## Option 3: Test on macOS Desktop (Limited - No Microphone)

**Warning**: macOS desktop version may not support microphone recording properly.

```bash
cd /Users/safwaan/G/Quran-App
flutter run -d macos
```

This will let you test:
- ✅ UI/colors
- ✅ Navigation
- ✅ Button placement
- ❌ Microphone recording (may not work)

## Option 4: Test on Chrome/Web (Limited - No Microphone)

```bash
cd /Users/safwaan/G/Quran-App
flutter run -d chrome
```

This will let you test:
- ✅ UI/colors
- ✅ Navigation  
- ❌ Microphone recording (browser permissions needed)

## Recommended: Full Feature Testing

### Best Approach:
1. **Use Physical iOS Device** for full microphone testing
2. **Or setup iOS Simulator** for UI/navigation testing

### Quick Test Commands:

```bash
# Navigate to project
cd /Users/safwaan/G/Quran-App

# Install dependencies (if not done)
flutter pub get

# Check available devices
flutter devices

# Run on first available device
flutter run

# Or specify device
flutter run -d <device-id>
```

## What to Test:

### 1. Visual Test (No microphone needed):
- [ ] App opens successfully
- [ ] Colors are black/white/green (no purple)
- [ ] Mic button visible next to play button
- [ ] UI looks correct

### 2. Microphone Test (Requires device):
- [ ] Tap mic button
- [ ] Permission prompt appears
- [ ] Grant permission
- [ ] Red circle appears when recording
- [ ] Tap again to stop
- [ ] Processing indicator shows
- [ ] Results appear with colored words

### 3. Functionality Test:
- [ ] Record a verse
- [ ] See transcription result
- [ ] Words highlighted (green/red/yellow)
- [ ] Accuracy percentage shown

## Troubleshooting

### "No devices found"
- Connect iOS device via USB and unlock it
- Or open iOS Simulator first: `open -a Simulator`
- Or check: `flutter devices`

### "iOS Simulator not installed"
- Open Xcode > Settings > Components
- Download iOS Simulator runtime
- Wait for installation (can take 10-20 minutes)

### "Permission denied"
- iOS: Settings > Privacy > Microphone > Enable for app
- Grant permission when app requests it

### "Cannot run on macOS/Chrome"
- Microphone recording requires iOS/Android
- Use macOS/Chrome only for UI testing

## Quick Start Command:

```bash
# One command to get started
cd /Users/safwaan/G/Quran-App && flutter pub get && flutter devices
```

Then choose your target and run `flutter run`.

