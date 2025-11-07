# AnalystTrack Deployment Guide

Complete guide for deploying and testing the AnalystTrack Flutter app across different platforms.

---

## 🚀 Quick Start Options (Ranked by Ease)

### 1. ⚡ **Web via Netlify** (Easiest - 2 minutes)
```bash
flutter build web --release
```
Then:
1. Go to [netlify.com](https://netlify.com)
2. Sign in with GitHub
3. Drag and drop the `build/web` folder
4. Get instant URL: `https://your-app.netlify.app`

### 2. 🌐 **Web via Vercel** (Very Easy - 3 minutes)
```bash
flutter build web --release
```
Then:
1. Go to [vercel.com](https://vercel.com)
2. Sign in with GitHub
3. Import project or drag `build/web`
4. Auto-deploy

### 3. 📦 **Web via GitHub Pages** (Free, 5 minutes)
```bash
# Build
flutter build web --release --base-href "/analysttrack/"

# Push to gh-pages branch
cd build/web
git init
git add .
git commit -m "Deploy to GitHub Pages"
git push -f git@github.com:chamaya00/analysttrack.git main:gh-pages
```
Access at: `https://chamaya00.github.io/analysttrack/`

---

## 📱 Mobile Deployment

### Android - APK Installation

**Build Release APK:**
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

**Install Options:**
1. **USB Transfer:** Connect phone, enable USB debugging, `adb install app-release.apk`
2. **Cloud:** Upload to Google Drive/Dropbox, download on phone
3. **Email:** Email APK to yourself, open on phone
4. **QR Code:** Use [qr-code-generator.com](https://www.qr-code-generator.com/) with APK URL

**Note:** Enable "Install from Unknown Sources" on Android

### Android - Google Play Internal Testing

```bash
# Build App Bundle (required for Play Store)
flutter build appbundle --release
```

**Steps:**
1. Go to [Google Play Console](https://play.google.com/console)
2. Create app (one-time)
3. Navigate to: Testing → Internal testing
4. Create new release
5. Upload `build/app/outputs/bundle/release/app-release.aab`
6. Add testers via email
7. Share testing link with testers

**Timeline:** Available to testers in ~2 hours

### iOS - TestFlight (Requires Mac + Apple Developer Account)

```bash
flutter build ipa --release
```

**Steps:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Set team & bundle identifier
3. Archive: Product → Archive
4. Upload to App Store Connect
5. TestFlight → Add external testers
6. Share TestFlight link

**Cost:** $99/year Apple Developer Program
**Timeline:** 24-48 hours for review

---

## 💻 Desktop Deployment

### Windows
```bash
flutter build windows --release
```
**Output:** `build/windows/runner/Release/`
- Zip entire folder
- Share via cloud storage
- Users extract and run `analysttrack.exe`

### macOS
```bash
flutter build macos --release
```
**Output:** `build/macos/Build/Products/Release/analysttrack.app`
- Create DMG or ZIP
- Share via cloud storage
- Users may need to "Allow" in Security settings

### Linux
```bash
flutter build linux --release
```
**Output:** `build/linux/x64/release/bundle/`
- Create tar.gz: `tar -czf analysttrack-linux.tar.gz -C build/linux/x64/release/bundle/ .`
- Share via cloud storage
- Users extract and run `./analysttrack`

---

## 🔥 Firebase Hosting (Recommended for Web)

### Setup
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
```

**Configuration (firebase.json):**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### Deploy
```bash
flutter build web --release
firebase deploy
```

**Custom Domain:** Free SSL, CDN, `https://analysttrack.web.app`

---

## 🧪 Testing Platforms

### Web Testing
- **BrowserStack:** Test on real browsers/devices
- **Local Network:** `flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080`
- **ngrok:** `ngrok http 8080` for public URL

### Mobile Testing Services
- **Firebase App Distribution:** Quick beta distribution
- **TestFlight (iOS):** Official Apple beta testing
- **Google Play Internal Testing:** Official Android beta testing

---

## 📊 My Recommendation for You

Based on your setup, here's what I recommend:

### **Option 1: Web First (Immediate Testing)**
```bash
cd /home/user/analysttrack
flutter build web --release
```
Then upload `build/web` to Netlify → **Live in 2 minutes**

### **Option 2: Android APK (Mobile Testing)**
```bash
flutter build apk --release
```
Transfer `build/app/outputs/flutter-apk/app-release.apk` to your Android phone

### **Option 3: Progressive Web App (Best of Both)**
The app already has `manifest.json` configured. When you deploy to web:
- Users can "Add to Home Screen" on mobile
- Works offline with service workers
- Feels like native app
- No app store required

---

## 🔒 CORS Considerations

The ESPN API calls work from mobile apps but **may have CORS issues on web**. If you encounter this:

### Solution 1: Proxy Server
```javascript
// Use a CORS proxy for web builds only
const baseUrl = kIsWeb
  ? 'https://corsproxy.io/?https://sports.core.api.espn.com'
  : 'https://sports.core.api.espn.com';
```

### Solution 2: Backend Proxy
Create a simple backend (Firebase Functions, Vercel Serverless):
```javascript
export default async function handler(req, res) {
  const espnUrl = `https://sports.core.api.espn.com${req.url}`;
  const response = await fetch(espnUrl);
  const data = await response.json();
  res.json(data);
}
```

---

## 📦 Build Sizes

Expected build sizes:
- **Web:** ~2-3 MB (gzipped)
- **Android APK:** ~15-20 MB
- **Android App Bundle:** ~12-15 MB (optimized)
- **iOS IPA:** ~20-25 MB
- **Windows:** ~15-20 MB
- **macOS:** ~25-30 MB

---

## ⚙️ Environment-Specific Builds

### Add Environment Config
```dart
// lib/config/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://sports.core.api.espn.com',
  );
}
```

### Build with Environment
```bash
# Production
flutter build web --release --dart-define=PRODUCTION=true

# Staging
flutter build web --release --dart-define=API_URL=https://staging.api.com
```

---

## 🎯 Next Steps

1. **Choose platform** (I recommend web for quick demo)
2. **Build:** `flutter build web --release`
3. **Deploy:** Upload to Netlify/Vercel
4. **Share:** Send link to testers
5. **Gather feedback**
6. **Iterate**

Need help with any specific deployment? Let me know!
