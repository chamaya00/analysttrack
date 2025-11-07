#!/bin/bash
# Build script for AnalystTrack web deployment

echo "🚀 Building AnalystTrack for Web Deployment..."
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo ""
    echo "Please install Flutter first:"
    echo "  https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
fi

echo "✅ Flutter detected"
echo ""

# Get Flutter dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""
echo "🔨 Building for web (this may take a few minutes)..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "✅ Build successful!"
echo ""
echo "📁 Your web app is ready in: build/web/"
echo ""
echo "📤 Next steps for deployment:"
echo ""
echo "Option 1: Netlify (Easiest)"
echo "  1. Go to https://app.netlify.com/drop"
echo "  2. Drag and drop the 'build/web' folder"
echo "  3. Get instant live URL"
echo ""
echo "Option 2: Firebase Hosting"
echo "  1. npm install -g firebase-tools"
echo "  2. firebase login"
echo "  3. firebase init hosting"
echo "  4. firebase deploy"
echo ""
echo "Option 3: GitHub Pages"
echo "  cd build/web"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Deploy to GitHub Pages'"
echo "  git push -f git@github.com:chamaya00/analysttrack.git main:gh-pages"
echo ""
echo "Option 4: Test locally first"
echo "  cd build/web"
echo "  python3 -m http.server 8000"
echo "  # Then open http://localhost:8000 in your browser"
echo ""
