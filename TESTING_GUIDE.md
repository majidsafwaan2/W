# Testing Guide for Quran Recitation Feature

## Prerequisites

1. **Flutter installed** - Check with `flutter doctor`
2. **iOS or Android device/simulator ready**
3. **Internet connection** (for Whisper API calls)

## Quick Start

### 1. Install Dependencies
```bash
cd /Users/safwaan/G/Quran-App
flutter pub get
```

### 2. Check Available Devices
```bash
flutter devices
```

### 3. Run the App

**For iOS Simulator:**
```bash
# First, open iOS Simulator
open -a Simulator

# Then run the app
flutter run
```

**For Android Emulator:**
```bash
# First, start Android emulator from Android Studio or:
emulator -avd <your_emulator_name>

# Then run the app
flutter run
```

**For Physical Device:**
```bash
# Connect device via USB and enable USB debugging
flutter run
```

## Testing Steps

### Step 1: Verify App Launches
1. Run `flutter run`
2. App should launch successfully
3. Check that colors are **black background, white text, green accents** (no purple)

### Step 2: Navigate to a Surah
1. Tap on any Surah from the home screen
2. You should see the detail screen with verses
3. Verify the new color scheme throughout

### Step 3: Test Mic Button
1. Scroll to any verse (ayah)
2. Look at the top right area of each verse card
3. You should see **three buttons from left to right:**
   - 🎤 **Mic button** (NEW - green mic icon)
   - ▶️ **Play button** (audio playback)
   - 🔖 **Bookmark button** (flag icon)

### Step 4: Test Recording Feature

#### A. First Time - Permission Request
1. Tap the **mic button** (🎤)
2. **iOS**: System will ask for microphone permission
   - Tap "Allow" or "OK"
3. **Android**: Permission is requested automatically
4. After granting permission, recording should start

#### B. Recording Visual Feedback
1. When recording starts:
   - Mic button changes to a **red circle** with mic icon
   - This indicates recording is active
2. Start reciting the Arabic verse you see on screen
3. Speak clearly into the microphone

#### C. Stop Recording
1. Tap the **red recording button** again to stop
2. You'll see a loading indicator (circular progress)
3. A snackbar message appears: "Processing recitation..."

### Step 5: Test Transcription & Detection

#### A. Wait for Processing
1. After stopping recording, wait 5-15 seconds
2. The app sends audio to OpenAI Whisper API
3. Audio is transcribed to Arabic text

#### B. View Results
1. **Word Highlighting:**
   - Arabic text words are now colored:
     - 🟢 **Green**: Correctly recited words
     - 🔴 **Red**: Incorrectly recited words
     - 🟡 **Yellow**: Missing words (not recited)

2. **Accuracy Display:**
   - A green card appears below the Arabic text
   - Shows: "Accuracy: X.X%"
   - Shows: "X/Y correct" (correct words / total words)

3. **Accuracy Snackbar:**
   - A colored snackbar appears at bottom:
     - **Green**: Accuracy ≥ 80%
     - **Orange**: Accuracy 60-79%
     - **Red**: Accuracy < 60%

### Step 6: Test Multiple Verses
1. Scroll to different verses
2. Try recording multiple verses
3. Each verse should track its own recitation results
4. Previous highlights should clear when recording new verse

### Step 7: Test Error Handling

#### A. No Permission
1. Deny microphone permission when asked
2. You should see: "Microphone permission is required for recording"

#### B. Poor Audio Quality
1. Record in a noisy environment or very quietly
2. Transcription may fail or be inaccurate
3. Error message: "Failed to transcribe audio. Please try again."

#### C. Network Issues
1. Turn off internet/WiFi
2. Try recording
3. Should show error: "An error occurred while processing your recitation."

## Expected Behavior

### ✅ What Should Work:
- App launches with black/white/green theme
- Mic button appears next to play button
- Recording starts/stops on tap
- Red circle indicator while recording
- Processing indicator during transcription
- Word-level highlighting (green/red/yellow)
- Accuracy percentage display
- Color-coded feedback snackbars

### ⚠️ Known Limitations:
- **Internet required** for Whisper API transcription
- **First transcription** may take 10-15 seconds
- **Arabic pronunciation** must be clear for accurate transcription
- **Word matching** uses normalization (diacritics removed)
- Results are based on word-level comparison, not phonetic similarity

## Troubleshooting

### Issue: App won't launch
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Mic button not appearing
- Check that you're on the detail screen (inside a Surah)
- Verify you're looking at a verse card (ayah)
- Mic button is in the top-right row of buttons

### Issue: Permission denied
- **iOS**: Go to Settings > Privacy > Microphone > Enable for "Quran App"
- **Android**: Go to Settings > Apps > Quran App > Permissions > Enable Microphone

### Issue: Recording not working
- Check microphone permissions
- Try on a physical device (simulators may not have microphone)
- Check device volume settings

### Issue: Transcription fails
- Verify internet connection
- Check OpenAI API key is valid
- Ensure audio is clear and in Arabic
- Try recording again (API may be rate-limited)

### Issue: Wrong color highlighting
- Arabic text normalization may affect matching
- Try reciting more clearly
- Check that you're reciting the correct verse

## Testing Checklist

- [ ] App launches successfully
- [ ] Colors are black/white/green (no purple)
- [ ] Mic button visible next to play button
- [ ] Permission request appears on first use
- [ ] Recording starts when mic button tapped
- [ ] Red circle indicator shows while recording
- [ ] Recording stops on second tap
- [ ] Processing indicator appears
- [ ] Transcription completes (10-15 seconds)
- [ ] Words are highlighted (green/red/yellow)
- [ ] Accuracy percentage displayed
- [ ] Snackbar shows with accuracy
- [ ] Multiple verses can be tested independently

## Advanced Testing

### Test Word Matching
Try these scenarios:
1. **Perfect recitation**: Recite exactly as written → Should show 100% accuracy
2. **Missing words**: Skip a word → Should show yellow for missing word
3. **Wrong words**: Mispronounce a word → Should show red for wrong word
4. **Partial recitation**: Only recite first half → Should show yellow for missing words

### Test Arabic Normalization
The system normalizes:
- Removes diacritics (harakat)
- Normalizes Alef variations (أ، إ، آ → ا)
- Normalizes Taa Marbuta (ة → ه)
- Normalizes Yaa (ى → ي)

So words with different diacritics should still match if normalized correctly.

## Notes

- **API Costs**: Each transcription uses OpenAI API credits
- **Privacy**: Audio is sent to OpenAI servers for processing
- **Offline**: Core app works offline, but transcription requires internet
- **Performance**: First transcription may be slower (cold start)

## Need Help?

If something doesn't work:
1. Check `flutter doctor` output
2. Check device logs: `flutter logs`
3. Verify all permissions granted
4. Test on physical device if simulator issues occur
5. Check internet connection for API calls

