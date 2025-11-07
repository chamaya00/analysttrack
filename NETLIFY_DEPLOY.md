# 🚀 Deploy to Netlify in 2 Minutes

Quick guide to get your AnalystTrack app live and shareable via link.

---

## ⚡ Super Quick Method (Drag & Drop)

### Step 1: Build the App
```bash
# Navigate to project directory
cd analysttrack

# Run the build script
./build-web.sh
```

Or manually:
```bash
flutter pub get
flutter build web --release
```

### Step 2: Deploy to Netlify

1. **Go to Netlify Drop**
   - Visit: [https://app.netlify.com/drop](https://app.netlify.com/drop)

2. **Sign in**
   - Click "Sign up" if you don't have an account
   - Use GitHub, GitLab, or Email

3. **Drag & Drop**
   - Drag the entire `build/web` folder onto the page
   - Wait ~30 seconds

4. **Get Your Link! 🎉**
   - You'll get a URL like: `https://random-name-12345.netlify.app`
   - Click "Site settings" → "Change site name" to customize
   - Example: `https://analysttrack.netlify.app`

5. **Share the Link**
   - Copy the URL and share with anyone!
   - Works on mobile, tablet, desktop
   - Can be added to home screen on mobile

---

## 🔄 Automatic Deployment (Recommended for Ongoing Development)

This method auto-deploys whenever you push to GitHub.

### Setup (One-time)

1. **Push your code to GitHub** (already done ✅)

2. **Go to Netlify**
   - Visit: [https://app.netlify.com/start](https://app.netlify.com/start)
   - Click "Import an existing project"

3. **Connect GitHub**
   - Select your repository: `chamaya00/analysttrack`
   - Choose branch: `claude/review-espn-api-code-011CUrA1QEgZ4JyhAYf2VJ7t`

4. **Configure Build Settings**
   ```
   Base directory:    (leave empty)
   Build command:     flutter build web --release
   Publish directory: build/web
   ```

5. **Add Build Image**
   - Click "Show advanced"
   - Add environment variable:
     - Key: `FLUTTER_CHANNEL`
     - Value: `stable`

6. **Deploy!**
   - Click "Deploy site"
   - Wait 3-5 minutes for first build
   - Every git push will auto-deploy! 🎉

---

## 📱 Test on Mobile

Once deployed, you can make it feel like a native app:

### iOS (iPhone/iPad)
1. Open your Netlify URL in Safari
2. Tap the Share button (box with arrow)
3. Scroll down and tap "Add to Home Screen"
4. Now it's an app icon on your home screen!

### Android
1. Open your Netlify URL in Chrome
2. Tap the menu (three dots)
3. Tap "Add to Home screen"
4. Icon appears on your home screen!

---

## 🎨 Custom Domain (Optional)

Want `analysttrack.com` instead of `random-name.netlify.app`?

1. **In Netlify Dashboard**
   - Go to "Domain settings"
   - Click "Add custom domain"

2. **Enter your domain**
   - Type: `analysttrack.com` (you need to own this)

3. **Configure DNS**
   - Netlify will give you DNS settings
   - Update at your domain registrar

4. **Free SSL**
   - Netlify automatically provisions HTTPS
   - Usually takes 1-2 minutes

---

## 🐛 Troubleshooting

### Build fails?
```bash
# Make sure Flutter is installed
flutter --version

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### App shows blank screen?
- Check browser console for errors (F12)
- ESPN API might be down - try later
- CORS proxy might be slow on first load

### Events not loading?
- ESPN API has rate limits
- Try a different week/season
- Check your internet connection

### Want to test locally first?
```bash
cd build/web
python3 -m http.server 8000
# Open http://localhost:8000
```

---

## 📊 Performance Tips

### Optimize Load Time
In `web/index.html`, add before `</head>`:
```html
<link rel="preconnect" href="https://sports.core.api.espn.com">
<link rel="preconnect" href="https://corsproxy.io">
```

### Enable Caching
Netlify automatically caches static assets. To force refresh:
- Clear your browser cache
- Or use private/incognito mode

---

## 🔐 Security Notes

- **No API keys needed** - ESPN API is public
- **CORS proxy** - We use corsproxy.io for web builds
  - Mobile apps use direct ESPN API (no proxy)
  - Proxy is only for browser CORS restrictions

---

## 📈 Analytics (Optional)

Want to track visitors?

1. **In Netlify Dashboard**
   - Go to "Analytics" tab
   - Enable "Netlify Analytics" ($9/month)

2. **Or use free alternatives:**
   - Google Analytics
   - Plausible Analytics
   - Simple Analytics

Add to `web/index.html` in the `<head>` section.

---

## ✅ Checklist

- [ ] Flutter installed (`flutter --version`)
- [ ] Run `./build-web.sh` successfully
- [ ] `build/web` folder exists
- [ ] Netlify account created
- [ ] Dragged `build/web` to Netlify Drop
- [ ] Got live URL
- [ ] Tested on desktop browser
- [ ] Tested on mobile browser
- [ ] Shared link with others

---

## 🎉 You're Live!

Your app is now accessible worldwide. Here's what you can do:

✅ Share the link via email, text, social media
✅ Works on any device with a browser
✅ No app store approval needed
✅ Free hosting (Netlify free tier: 100GB bandwidth/month)
✅ HTTPS enabled by default
✅ Can be added to home screen (PWA)

**Example URLs to share:**
- Desktop: `https://analysttrack.netlify.app`
- Direct: Copy and paste the full URL
- QR Code: Generate at [qr-code-generator.com](https://www.qr-code-generator.com/)

---

## 📞 Need Help?

If you encounter issues:
1. Check the [Flutter Web docs](https://docs.flutter.dev/deployment/web)
2. Check [Netlify docs](https://docs.netlify.com/)
3. Check browser console (F12) for errors
4. Try rebuilding: `flutter clean && flutter build web --release`

---

**Ready to deploy? Run `./build-web.sh` and follow the steps above!** 🚀
