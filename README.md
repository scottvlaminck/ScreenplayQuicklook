Currently supported file types: 
- fdx

---
# Installation

After opening this repo in Xcode, use these instructions that I followed from ChatGPT: 

### 1. Build a Release and install the app

You want an actual .app bundle that lives in /Applications, like any other app.
- At the top of Xcode, set:
	- Scheme: your host app (not the extension)
	- Destination: My Mac
- Choose Product → Archive.
- When the build finishes, Xcode’s Organizer will open with your archive.
- Right-click the archive and click Show in Finder.
	- Right-click the archive → Show Package Contents → navigate to Products/Applications/YourApp.app.
	- Copy YourApp.app to /Applications.



### 2. Register & enable the Quick Look extension
- After copying the app into /Applications, double-click the app to launch it once, then close the app. That helps macOS register the bundle and its extensions.
	


### 3. Use it in Finder

Now it should work like any other Quick Look plugin:
- In Finder, select an .fdx file (or whatever UTI you support).
- Press Spacebar (Quick Look).
- Your PreviewProvider should be invoked and render HTML.

---

### If that doesn't work:  
- Open System Settings → Privacy & Security → Extensions (on newer macOS) and look for:
	- Quick Look (or possibly “Finder Extensions”/“Other Extensions” depending on version)
	- You should see your extension listed there with the name from your extension target.
	- Turn it on (checkbox or toggle).

If it doesn’t show up:
- Double-check the extension’s Info.plist:
- NSExtensionPointIdentifier is com.apple.quicklook.preview
- QLSupportedContentTypes contains com.finaldraft.fdx (or whatever UTI you want)
- Make sure the extension target is using the same Team and Signing as the app.

