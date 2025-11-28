# 📱 Deploy from iPhone - Complete Guide

## Automatic Deployment with Netlify

Since you can't build Flutter on your iPhone, we'll let **Netlify build and deploy automatically** whenever you merge code to GitHub!

---

## 🚀 One-Time Setup (5 minutes from iPhone)

### Step 1: Open Netlify in Safari
1. Open Safari on your iPhone
2. Go to: **https://app.netlify.com**
3. Tap **"Sign up"** (or "Log in" if you have an account)
4. Choose **"Sign up with GitHub"**
5. Authorize Netlify to access your GitHub

---

### Step 2: Import Your Project
1. Tap **"Add new site"** button
2. Tap **"Import an existing project"**
3. Tap **"Deploy with GitHub"**
4. Find and tap **"chamaya00/analysttrack"** in the list
   - (If you don't see it, tap "Configure the Netlify app on GitHub" and grant access)

---

### Step 3: Configure Build Settings

Netlify should auto-detect your settings from `netlify.toml`, but verify:

**Branch to deploy:**
```
claude/flutter-mobile-deployment-01MDZS9vpDuVJ2Ehg5YnyFAv
```

**Build settings** (should be pre-filled):
```
Build command: flutter build web --release
Publish directory: build/web
```

If not pre-filled, tap "Show advanced" and enter these values.

---

### Step 4: Deploy!
1. Tap **"Deploy [site name]"**
2. Wait 3-5 minutes (Netlify is building your app)
3. You'll see the build progress - it should turn green ✅
4. Your site is live! 🎉

---

## 🌐 Your Live URLs

After deployment, you'll get URLs like:

**Default Netlify URL:**
```
https://random-name-123.netlify.app
```

**Deploy previews (for PRs):**
```
https://deploy-preview-X--your-site.netlify.app
```

**Production branch:**
```
https://your-site.netlify.app
```

---

## ✨ Customize Your Site Name

1. In Netlify dashboard, tap **"Site settings"**
2. Under "Site information", tap **"Change site name"**
3. Enter something like: **analysttrack** or **nfl-analysttrack**
4. Tap "Save"
5. Your new URL: `https://analysttrack.netlify.app`

---

## 🔄 How Automatic Deployment Works

From now on:
1. ✅ **Every merge to your branch** → Netlify auto-builds and deploys
2. ✅ **Every pull request** → Gets a preview URL
3. ✅ **Build fails?** → You get an email notification
4. ✅ **Want to rollback?** → Click "Deploys" and republish an old one

**You never need to manually build again!**

---

## 📱 Add to iPhone Home Screen (Make it Feel Like an App)

Once deployed:

1. Open your Netlify URL in Safari
2. Tap the **Share** button (square with arrow up)
3. Scroll down and tap **"Add to Home Screen"**
4. Name it "AnalystTrack"
5. Tap "Add"

Now you have an app icon on your home screen! 🎉

---

## 🔍 Monitoring from iPhone

### Check Build Status:
1. Go to `https://app.netlify.com/sites/YOUR_SITE_NAME/deploys`
2. See all builds, logs, and deployment history

### View Build Logs:
1. Tap on any deployment
2. Tap "View build logs"
3. See exactly what happened during the build

### Check Analytics (Free):
- Netlify shows basic bandwidth and visitor stats
- Upgrade to Netlify Analytics for detailed insights ($9/mo)

---

## 🐛 Troubleshooting

### "Build failed" email?
1. Go to Netlify dashboard
2. Tap the failed deploy
3. Read the error message
4. Common issues:
   - Flutter version mismatch
   - Missing dependencies
   - Build timeout (increase in Site settings)

### Still not working?
1. Check `netlify.toml` is in your repository
2. Make sure the branch name is correct
3. Try triggering a manual deploy: "Deploys" → "Trigger deploy" → "Deploy site"

---

## 🎯 Deploy from Different Branches

Want to deploy from `main` branch instead?

1. Go to **Site settings** → **Build & deploy**
2. Under "Production branch", tap "Edit settings"
3. Change branch to `main` (or any branch)
4. Tap "Save"

---

## 🔐 Environment Variables (If Needed Later)

If you need API keys or secrets:

1. Go to **Site settings** → **Environment variables**
2. Tap "Add a variable"
3. Enter key and value
4. These are available during build but hidden from users

---

## 💰 Cost

**Netlify Free Tier includes:**
- ✅ 100 GB bandwidth/month
- ✅ 300 build minutes/month
- ✅ Unlimited sites
- ✅ Free SSL (HTTPS)
- ✅ Deploy previews
- ✅ Instant rollbacks

**This is more than enough for your project!**

---

## 📊 What Happens Now?

### When you merge a PR:
1. GitHub notifies Netlify
2. Netlify pulls latest code
3. Runs `flutter build web --release`
4. Publishes to `build/web`
5. Site is live in ~3-5 minutes
6. You get email: "Deploy succeeded"

### When you create a PR:
1. Netlify creates a **preview deploy**
2. You get a unique URL to test
3. Share with reviewers
4. When merged, preview becomes production

---

## 🎉 You're Done!

**What you've achieved:**
- ✅ Flutter web app deployed
- ✅ Automatic builds on every merge
- ✅ Free HTTPS hosting
- ✅ Deploy previews for PRs
- ✅ Can manage everything from iPhone

**Next steps:**
1. Share your URL with others
2. Merge changes to see auto-deployment in action
3. Add to iPhone home screen
4. Enjoy not worrying about builds!

---

## 📞 Quick Links

- **Your Netlify Dashboard:** https://app.netlify.com
- **Build Settings:** Site settings → Build & deploy
- **Deploy History:** Deploys tab
- **Domain Settings:** Site settings → Domain management
- **Netlify Docs:** https://docs.netlify.com

---

## 🆘 Need Help?

If something goes wrong:
1. Check build logs in Netlify dashboard
2. Make sure `netlify.toml` is committed to GitHub
3. Verify branch name matches
4. Try a manual rebuild: "Deploys" → "Trigger deploy"

**Enjoy your automatically deployed app!** 🚀
