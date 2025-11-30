# 📱 Step-by-Step: Run App on Physical iPhone/iPad

## Prerequisites
- iPhone or iPad
- USB cable (Lightning or USB-C)
- Your Mac (already set up)

---

## Step 1: Connect Your Device

1. **Plug your iPhone/iPad into your Mac** using the USB cable
2. **Unlock your device** (enter passcode/Face ID)
3. If you see **"Trust This Computer?"** popup:
   - Tap **"Trust"**
   - Enter your device passcode if prompted

---

## Step 2: Enable Developer Mode (iOS 16+)

**Important:** This is required for iOS 16 and later.

1. On your iPhone/iPad, go to **Settings**
2. Scroll down to **Privacy & Security**
3. Scroll down to find **Developer Mode**
4. Toggle **Developer Mode** to **ON** (green)
5. A popup will ask to restart - tap **Restart**
6. **Wait for device to restart**
7. After restart, you'll see another popup asking to enable Developer Mode
   - Tap **Turn On**
   - Enter your passcode

---

## Step 3: Verify Device is Connected

Open Terminal and run:

```bash
flutter devices
```

You should see your device listed, something like:
```
iPhone (mobile) • 00008030-001... • ios • iOS 18.x (device)
```

If you see your device, you're ready! ✅

---

## Step 4: Run the App

```bash
cd /Users/safwaan/G/Quran-App
flutter run
```

**What happens:**
1. Flutter will build the app (takes 1-2 minutes first time)
2. App will install on your device
3. App will launch automatically
4. You might see a popup on device: **"Untrusted Developer"**

---

## Step 5: Trust the Developer (If Needed)

If you see **"Untrusted Developer"** on your device:

1. On your iPhone/iPad, go to **Settings**
2. Go to **General**
3. Scroll down to **VPN & Device Management** (or **Device Management**)
4. Tap on your Apple ID/Developer account
5. Tap **Trust "[Your Name]"**
6. Tap **Trust** again to confirm
7. Go back to the app - it should now launch!

---

## Step 6: Test the App! 🎉

Once the app launches:

1. **Check colors**: Should see black background, white text, green accents
2. **Navigate**: Tap any Surah to open it
3. **Find mic button**: Scroll to a verse, look for 🎤 button next to play button
4. **Test recording**: 
   - Tap mic button
   - Grant microphone permission when asked
   - Record a verse
   - See results with colored words!

---

## Troubleshooting

### "No devices found"
- Make sure device is unlocked
- Check USB cable connection
- Try unplugging and replugging
- Run `flutter devices` again

### "Developer Mode not found"
- Your iOS version might be older than iOS 16
- Skip Developer Mode step and try running directly
- Or update iOS to 16+ if possible

### "Untrusted Developer" keeps appearing
- Make sure you completed Step 5 above
- Check Settings > General > VPN & Device Management
- Trust the developer certificate

### "App won't install"
- Check device has enough storage
- Make sure device is unlocked
- Try restarting device

### "Build fails"
- Make sure you're in the project directory: `cd /Users/safwaan/G/Quran-App`
- Try: `flutter clean && flutter pub get && flutter run`

---

## Quick Command Reference

```bash
# Check if device is connected
flutter devices

# Navigate to project
cd /Users/safwaan/G/Quran-App

# Run on device
flutter run

# If device not found, try:
flutter devices
# Then use device ID:
flutter run -d <device-id-from-above>
```

---

## Success Indicators ✅

You'll know it's working when:
- ✅ `flutter devices` shows your iPhone/iPad
- ✅ Terminal shows "Building..." then "Launching..."
- ✅ App appears on your device screen
- ✅ App opens with black/green theme

---

## Next Steps After App Launches

1. **Navigate**: Tap any Surah from home screen
2. **Find Mic**: Scroll to verse, see 🎤 button
3. **Test Recording**: Tap mic, grant permission, record!
4. **See Results**: Colored words and accuracy percentage

**Happy testing! 🚀**

