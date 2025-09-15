# Installation Guide

## macOS Installation

### Download
1. Go to [Releases](https://github.com/your-username/tsubusu/releases)
2. Download the latest `tsubusu-macos.dmg` file

### Installation Steps
1. Open the downloaded `.dmg` file
2. Drag `tsubusu.app` to your Applications folder

### First Launch (Critical Steps!)

macOS will show security warnings for unsigned apps. **Follow these steps carefully:**

#### Step 1: Remove Quarantine Flag
After downloading, **immediately** run this Terminal command:
```bash
sudo xattr -r -d com.apple.quarantine /Applications/tsubusu.app
```
(Enter your password when prompted)

#### Step 2: Handle Security Warnings
When you first try to open the app, macOS may show warnings like:
- **"tsubusu can't be opened because Apple cannot check it for malicious software."**
- **"This software needs to be updated. Contact the developer for more information."**

**To fix this:**

**Method 1 - Right-Click Method (Recommended):**
1. Right-click on `tsubusu.app` in Applications
2. Select "Open" from the context menu
3. Click "Open" in the security dialog
4. The app should now launch

**Method 2 - System Preferences:**
1. Go to System Preferences → Security & Privacy
2. In the "General" tab, you'll see a message about the blocked app
3. Click "Open Anyway" next to the message

**Method 3 - Terminal (if app becomes unresponsive):**
```bash
# Remove quarantine and disable gatekeeper temporarily
sudo xattr -r -d com.apple.quarantine /Applications/tsubusu.app
sudo spctl --master-disable
# Try to open the app, then re-enable protection:
sudo spctl --master-enable
```

#### If App Becomes Unresponsive
If you clicked "OK" on the error dialog and the app won't open anymore:
1. Delete the app from Applications
2. Re-download the DMG
3. Follow Step 1 (remove quarantine) BEFORE first launch

## Windows Installation

### Download
1. Go to [Releases](https://github.com/your-username/tsubusu/releases)
2. Download the latest `tsubusu-windows.zip` file

### Installation Steps
1. Extract the ZIP file to a folder of your choice
2. Run `tsubusu.exe` from the extracted folder

### Windows Security Warning
Windows may show a "Windows protected your PC" dialog. Click "More info" then "Run anyway" to proceed.

## Why These Warnings Appear

These security warnings appear because the application is not code-signed with an Apple Developer certificate (macOS) or Microsoft certificate (Windows). The app is safe to use - these are standard warnings for any unsigned application.

## Troubleshooting

If you continue to have issues:
1. Make sure you downloaded from the official [Releases page](https://github.com/your-username/tsubusu/releases)
2. Check that your antivirus isn't blocking the application
3. Try running as administrator (Windows) or with sudo (macOS) if needed

For additional help, please [open an issue](https://github.com/your-username/tsubusu/issues).