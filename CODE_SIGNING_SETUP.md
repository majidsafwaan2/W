# ✅ Fix Code Signing - Run App on Your iPhone

## The Problem
Xcode needs a "Development Team" to sign the app so it can run on your iPhone. This is free and easy!

---

## Step 1: Open Xcode Project

In Terminal, run:

```bash
cd /Users/safwaan/G/Quran-App
open ios/Runner.xcworkspace
```

This opens the project in Xcode. ⚠️ **Important:** Use `.xcworkspace` (NOT `.xcodeproj`)

---

## Step 2: Select Runner Project

In Xcode:

1. **Click "Runner"** in the left sidebar (blue icon at the top)
   - If you don't see it, look for a blue folder icon labeled "Runner"

2. **Make sure "Runner" target is selected:**
   - In the main area, you'll see tabs like "General", "Signing & Capabilities", etc.
   - Look at the top - there should be a dropdown showing "Runner" project and "Runner" target
   - Make sure **"Runner" target** is selected (not just the project)

---

## Step 3: Go to Signing & Capabilities

1. **Click the "Signing & Capabilities" tab** at the top
2. You'll see a section about "Signing"

---

## Step 4: Enable Automatic Signing

1. **Check the box:** ✅ **"Automatically manage signing"**

2. **Select a Team:**
   - Under "Team" dropdown, click it
   - If you see your Apple ID: **Select it**
   - If you see "Add an Account..." or "None": **Click "Add an Account..."**

---

## Step 5: Sign In with Apple ID

If you clicked "Add an Account...":

1. **Enter your Apple ID** (the email you use for iCloud/App Store)
2. **Enter your password**
3. Click **"Next"** or **"Sign In"**

**Note:** This is FREE! You don't need a paid developer account for testing.

---

## Step 6: Wait for Xcode to Configure

After selecting your team:

1. Xcode will automatically:
   - Create a development certificate
   - Create a provisioning profile
   - Register your device
   - This takes 10-30 seconds

2. You'll see a **green checkmark** ✅ when it's done
   - And "Provisioning profile created" or similar message

---

## Step 7: Trust the Certificate on Your iPhone

After Xcode signs the app:

1. **On your iPhone:**
   - Go to **Settings**
   - Go to **General**
   - Scroll down to **VPN & Device Management** (or **Device Management**)

2. **You'll see your Apple ID** listed:
   - Tap on it
   - Tap **"Trust [Your Name]"**
   - Tap **"Trust"** again to confirm

---

## Step 8: Run the App!

Back in Terminal:

```bash
cd /Users/safwaan/G/Quran-App
flutter run
```

The app should now build and install on your iPhone! 🎉

---

## Troubleshooting

### "No accounts found" or "Add an Account..."
- Click "Add an Account..."
- Sign in with your Apple ID (free iCloud account works!)
- Then select your team

### "No valid certificate"
- Make sure "Automatically manage signing" is checked ✅
- Make sure you've selected a Team
- Wait 30 seconds for Xcode to create certificates

### "Failed to register device"
- Make sure your iPhone is connected and unlocked
- Make sure you trusted the computer
- Try unplugging and replugging USB cable

### "Bundle identifier conflicts"
- This is rare, but if it happens:
  - In Xcode, go to "General" tab
  - Find "Bundle Identifier"
  - Change it to something unique like: `com.yourname.quranapp`

### "Cannot find development certificate"
- In Xcode, go to **Xcode > Settings > Accounts**
- Select your Apple ID
- Click **"Download Manual Profiles"**
- Wait for it to complete
- Go back to Signing & Capabilities tab
- Make sure Team is selected

---

## Quick Checklist

- [ ] Opened `ios/Runner.xcworkspace` in Xcode
- [ ] Selected "Runner" target (not just project)
- [ ] Went to "Signing & Capabilities" tab
- [ ] Checked "Automatically manage signing" ✅
- [ ] Selected a Team (signed in with Apple ID if needed)
- [ ] Saw green checkmark ✅ (signing successful)
- [ ] Trusted certificate on iPhone (Settings > General > Device Management)
- [ ] Ran `flutter run` in Terminal

---

## Success Indicators

✅ Green checkmark in Xcode Signing section  
✅ "Provisioning profile created" message  
✅ No errors in Xcode  
✅ App builds and installs on iPhone  

---

## After Setup

Once code signing is set up, you only need to do this **once**. After that, just run:

```bash
flutter run
```

And the app will install on your device! 🚀

---

**Start with Step 1: Open the Xcode workspace!**

