# ✅ Device Found! Now Let's Pair It

## Good News! 🎉

Your iPhone is detected but needs to be **paired** first. This is easy!

---

## Step 1: Open Xcode

1. **Open Xcode** on your Mac
   - You can find it in Applications
   - Or press `Cmd + Space` and type "Xcode"

---

## Step 2: Open Devices Window

In Xcode:
1. Go to **Window** menu at the top
2. Click **Devices and Simulators**
   - Or press `Shift + Cmd + 2`

A window will open showing connected devices.

---

## Step 3: Pair Your Device

1. In the **Devices and Simulators** window:
   - You should see **"Safwaan's iPhone"** on the left side
   - It might say "Unpaired" or show a warning icon

2. **Click on your iPhone** in the list

3. Xcode will ask you to **"Use for Development"**
   - Click that button
   - Or look for a **"Pair"** or **"Use for Development"** button

4. **On your iPhone:**
   - You'll see a popup asking to trust this computer
   - Enter your device passcode
   - Tap **Trust**

5. **Wait a moment** - Xcode will pair the device
   - You'll see a progress indicator
   - This takes 30-60 seconds

6. **After pairing:**
   - Your iPhone status should change to "Ready" or show a green checkmark ✅

---

## Step 4: Developer Mode Will Now Appear!

After pairing, **Developer Mode** should appear on your iPhone:

1. **On your iPhone:**
   - Go to **Settings**
   - **Privacy & Security**
   - Scroll down - **Developer Mode** should now be visible!

2. **Enable Developer Mode:**
   - Toggle **Developer Mode** to **ON**
   - Device will ask to restart
   - Tap **Restart**
   - After restart, confirm to enable

---

## Step 5: Verify Device is Ready

Back in Terminal:

```bash
flutter devices
```

You should now see:
```
iPhone (mobile) • [some-id] • ios • iOS [version] (device)
```

Status should show **"(device)"** without errors! ✅

---

## Step 6: Run the App!

```bash
cd /Users/safwaan/G/Quran-App
flutter run
```

The app should build and install on your iPhone! 🎉

---

## If Pairing Doesn't Work

### Try These:

1. **Disconnect and reconnect:**
   - Unplug USB cable
   - Wait 5 seconds
   - Plug back in
   - Unlock device
   - Try pairing again

2. **Restart both:**
   - Restart your iPhone
   - Restart your Mac
   - Try pairing again

3. **Check USB cable:**
   - Use Apple original or certified cable
   - Some cables only charge, don't transfer data

4. **Trust computer again:**
   - On iPhone: Settings > General > Transfer or Reset iPhone
   - Tap "Reset Location & Privacy"
   - This resets trust - connect again and trust

---

## Quick Summary

1. ✅ Device detected (good!)
2. Open Xcode → Window → Devices and Simulators
3. Click your iPhone → Click "Use for Development"
4. Trust on iPhone when prompted
5. Wait for pairing to complete
6. Developer Mode appears on iPhone → Enable it
7. Restart iPhone
8. Run `flutter devices` → Should show device as ready
9. Run `flutter run` → App launches! 🚀

---

**Start with Step 1: Open Xcode and go to Devices window!**

