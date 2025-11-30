# 🧪 How to Test the Quran Recitation Feature

## 🚀 Quick Start (Easiest Method)

### Option A: Use the Test Script
```bash
cd /Users/safwaan/G/Quran-App
./test_app.sh
```

This script will:
1. Check Flutter setup
2. Install dependencies
3. List available devices
4. Launch iOS Simulator
5. Run the app

### Option B: Manual Steps

#### Step 1: Open iOS Simulator
```bash
open -a Simulator
```
Wait a few seconds for it to boot up.

#### Step 2: Run the App
```bash
cd /Users/safwaan/G/Quran-App
flutter run
```

The app will:
- Build automatically
- Install on simulator
- Launch automatically

---

## 📱 Testing on Physical iOS Device (Best for Microphone)

### Step 1: Connect Your iPhone/iPad
- Connect via USB cable
- Unlock your device
- Trust the computer if prompted

### Step 2: Enable Developer Mode
On your iOS device:
1. Go to **Settings > Privacy & Security**
2. Scroll down to **Developer Mode**
3. Toggle it ON
4. Restart device when prompted

### Step 3: Run the App
```bash
cd /Users/safwaan/G/Quran-App
flutter devices  # Check if device appears
flutter run      # Run on your device
```

---

## ✅ What to Test

### 1. Visual Check (Takes 30 seconds)
1. **App launches** ✅
2. **Colors changed**: Look for:
   - Black background
   - White text
   - Green accents (not purple)
3. **Home screen** shows Surahs list
4. **Tap any Surah** to open detail screen

### 2. Mic Button Check (Takes 1 minute)
1. **Scroll to a verse** (ayah)
2. **Look at top-right** of verse card
3. **You should see 3 buttons**:
   ```
   🎤 Mic | ▶️ Play | 🔖 Bookmark
   ```
4. **Mic button is GREEN** 🎤

### 3. Recording Test (Takes 2 minutes)

#### First Time:
1. **Tap the mic button** 🎤
2. **Permission prompt** appears
3. **Tap "Allow"** or "OK"
4. **Recording starts** - button turns red ⭕

#### While Recording:
1. **Speak the Arabic verse** you see on screen
2. **Red circle** shows recording is active
3. **Speak clearly** into microphone

#### Stop Recording:
1. **Tap red button again** to stop
2. **Loading spinner** appears
3. **Wait 10-15 seconds** for processing
4. **Results appear**:
   - Words colored: 🟢 Green (correct), 🔴 Red (wrong), 🟡 Yellow (missing)
   - Accuracy card shows percentage
   - Snackbar shows accuracy feedback

---

## 🎯 Testing Checklist

### Visual Tests (No Microphone Needed):
- [ ] App opens without errors
- [ ] Background is black (not white/purple)
- [ ] Text is white
- [ ] Buttons/icons are green (not purple)
- [ ] Mic button visible next to play button

### Functionality Tests (Needs Microphone):
- [ ] Tap mic button → permission requested
- [ ] Grant permission → recording starts
- [ ] Red circle appears while recording
- [ ] Tap again → recording stops
- [ ] Processing indicator shows
- [ ] Results appear with colored words
- [ ] Accuracy percentage displayed
- [ ] Snackbar shows accuracy feedback

---

## 🐛 Troubleshooting

### "No devices found"
```bash
# Check available devices
flutter devices

# If simulator not running:
open -a Simulator
```

### "Permission denied"
- iOS Simulator: Settings > Privacy > Microphone > Enable
- Physical device: Settings > Privacy & Security > Microphone > Quran App > ON

### "App crashes on launch"
```bash
flutter clean
flutter pub get
flutter run
```

### "Microphone not working"
- **Simulators**: May have limited mic support - use physical device
- **Physical device**: Check Settings > Privacy > Microphone
- Check device isn't on mute

### "Transcription fails"
- Check internet connection (needs WiFi/cellular)
- Verify OpenAI API key is valid
- Speak clearly in Arabic
- Wait 10-15 seconds (API processing time)

---

## 📊 Expected Results

### Perfect Recitation:
- **Accuracy**: 90-100%
- **Words**: All green 🟢
- **Feedback**: Green snackbar

### Good Recitation:
- **Accuracy**: 70-89%
- **Words**: Mostly green, few red/yellow
- **Feedback**: Orange snackbar

### Needs Improvement:
- **Accuracy**: <70%
- **Words**: Many red 🔴 or yellow 🟡
- **Feedback**: Red snackbar

---

## 💡 Pro Tips

1. **Start with short verses** (easier to recite perfectly)
2. **Speak clearly** and at moderate pace
3. **Test in quiet environment** for better transcription
4. **Try different verses** to see how detection works
5. **Check word highlighting** - see which words were matched/mismatched

---

## 🎬 Step-by-Step Test Flow

```
1. Launch app → See home screen
2. Tap "Al-Fatihah" (or any Surah)
3. Scroll to verse 1
4. Tap 🎤 mic button
5. Grant microphone permission
6. Speak: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
7. Tap red button to stop
8. Wait for processing (10-15 seconds)
9. See colored words and accuracy!
```

---

## 📞 Quick Commands Reference

```bash
# Navigate to project
cd /Users/safwaan/G/Quran-App

# Install dependencies
flutter pub get

# List devices
flutter devices

# Open iOS Simulator
open -a Simulator

# Run app
flutter run

# View logs (in separate terminal)
flutter logs

# Clean and rebuild
flutter clean && flutter pub get && flutter run
```

---

## 🎉 Success Indicators

You'll know it's working when:
1. ✅ App opens with black/green theme
2. ✅ Mic button appears and is green
3. ✅ Recording works (red circle appears)
4. ✅ Transcription completes (no errors)
5. ✅ Words are highlighted with colors
6. ✅ Accuracy percentage is shown

**Happy Testing! 🚀**

