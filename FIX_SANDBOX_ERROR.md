# 🔧 Fix: Sandbox rsync Error

## The Problem

**Error:** `Sandbox: rsync(45021) deny(1) file-read-data /Users/safwaan/G/Quran-App/build/ios/Debug-iphoneos`

This is a permissions/sandbox issue with Xcode's build process.

---

## ✅ Solution 1: Clean Build (Try This First)

### Step 1: Clean Flutter Build

```bash
cd /Users/safwaan/G/Quran-App
flutter clean
```

### Step 2: Clean Xcode Build

```bash
cd ios
rm -rf build DerivedData
cd ..
```

### Step 3: Reinstall Pods

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Step 4: Get Dependencies and Run

```bash
cd /Users/safwaan/G/Quran-App
flutter pub get
flutter run
```

---

## ✅ Solution 2: Fix Permissions

### Step 1: Check Build Directory Permissions

```bash
cd /Users/safwaan/G/Quran-App
ls -la build/
```

### Step 2: Fix Permissions (if needed)

```bash
cd /Users/safwaan/G/Quran-App
chmod -R 755 build/
chmod -R 755 ios/
```

### Step 3: Try Running Again

```bash
flutter run
```

---

## ✅ Solution 3: Rebuild Everything

### Complete Clean and Rebuild:

```bash
cd /Users/safwaan/G/Quran-App

# Clean everything
flutter clean
rm -rf ios/build ios/DerivedData
rm -rf ios/Pods ios/Podfile.lock

# Reinstall
flutter pub get
cd ios && pod install && cd ..

# Run
flutter run
```

---

## ✅ Solution 4: Check Xcode Build Settings

If the above doesn't work:

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode:**
   - Select **Runner** project in left sidebar
   - Select **Runner** target
   - Go to **Build Settings** tab
   - Search for "Enable User Script Sandboxing"
   - **Uncheck** "Enable User Script Sandboxing" (if checked)

3. **Try running again:**
   ```bash
   flutter run
   ```

---

## ✅ Solution 5: Check Project Location

Sometimes this error happens if the project is in a restricted location.

### Check if project path is accessible:

```bash
cd /Users/safwaan/G/Quran-App
pwd
ls -la
```

Make sure you have read/write permissions to:
- `/Users/safwaan/G/`
- `/Users/safwaan/G/Quran-App/`
- `/Users/safwaan/G/Quran-App/build/`

---

## Quick Fix Script

Run this all at once:

```bash
cd /Users/safwaan/G/Quran-App && \
flutter clean && \
rm -rf ios/build ios/DerivedData ios/Pods ios/Podfile.lock && \
flutter pub get && \
cd ios && pod install && cd .. && \
chmod -R 755 build/ 2>/dev/null; \
flutter run
```

---

## If Nothing Works

### Try Building in Xcode Directly:

1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode:**
   - Select your iPhone from device dropdown (top toolbar)
   - Click **Run** button (▶️) or press `Cmd + R`
   - This builds directly in Xcode, bypassing some Flutter build issues

3. **If it builds in Xcode:**
   - The app will install on your device
   - You can then use `flutter run` for hot reload

---

## Most Likely Fix

Try **Solution 1** first (clean build). This usually fixes sandbox errors:

```bash
cd /Users/safwaan/G/Quran-App
flutter clean
rm -rf ios/build ios/DerivedData ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

**Start with Solution 1 - it fixes this error 90% of the time!** 🚀

