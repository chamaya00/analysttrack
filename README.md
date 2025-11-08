# AnalystTrack

A Flutter application for tracking NFL analytics using the ESPN API.

## 🚀 Quick Start - Deploy to Web

Want to share this app via link? Choose your preferred platform:

- **[VERCEL_DEPLOY.md](VERCEL_DEPLOY.md)** - ⭐ Recommended (faster, more build minutes)
- **[NETLIFY_DEPLOY.md](NETLIFY_DEPLOY.md)** - Alternative (simpler for beginners)

```bash
./build-web.sh  # Build for web
# Then drag build/web to vercel.com or netlify.com
```

## Features

- **Week Events Viewer**: Browse NFL games by season, week, and season type
- **Real-time Data**: Fetch live game information from ESPN's API
- **Comprehensive Game Details**: View teams, scores, venues, and game status
- **Progress Tracking**: See loading progress when fetching multiple events
- **Error Handling**: Robust error handling with user-friendly messages
- **Throttled Requests**: API calls are batched to avoid rate limiting

## Architecture

### Models (`lib/models/`)
- `WeekEventsResponse`: Contains event IDs for a specific week
- `EventDetails`: Detailed game information
- `Competition`: Competition/game details including teams
- `Competitor`: Team information with scores

### Services (`lib/services/`)
- `ESPNNFLService`: Main service for interacting with ESPN's NFL API
  - Request timeout handling
  - Batch processing with throttling
  - Comprehensive error handling
  - Progress callbacks

### Screens (`lib/screens/`)
- `NFLWeekEventsScreen`: Main screen for browsing NFL events
  - Proper controller lifecycle management
  - Loading states with progress
  - Error states with retry
  - Segmented season type selection

## ESPN API

This app uses ESPN's public NFL API:

### Base URL
```
https://sports.core.api.espn.com/v2/sports/football/leagues/nfl
```

### Endpoints Used
- `/seasons/{year}/types/{seasonType}/weeks/{week}/events` - Get event IDs
- `/events/{eventId}` - Get event details

### Season Types
- `1` - Preseason
- `2` - Regular Season
- `3` - Postseason

### CORS Handling
The app automatically detects the platform and handles CORS appropriately:
- **Web builds**: Uses CORS proxy (`corsproxy.io`) to bypass browser restrictions
- **Mobile/Desktop**: Direct API access (no proxy needed)

This ensures the app works seamlessly across all platforms.

## Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd analysttrack
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. Select the season year (e.g., 2025)
2. Select the week number (1-18)
3. Choose season type (Preseason/Regular/Postseason)
4. Tap "Load Events" to fetch games
5. Tap on any game card to see detailed information

## Code Improvements

This version includes several improvements over the original implementation:

### Critical Fixes
- ✅ Fixed memory leaks with proper TextEditingController disposal
- ✅ Added HTTP request timeouts (10 seconds)
- ✅ Safe date parsing with error handling
- ✅ Throttled concurrent API requests to avoid rate limiting
- ✅ CORS handling for web deployment

### Enhanced Features
- ✅ Comprehensive data models with team/score information
- ✅ Loading progress indicator
- ✅ Season type selector (Preseason/Regular/Postseason)
- ✅ Better error messages with error type detection
- ✅ Status indicators (Scheduled/Live/Final)
- ✅ Venue information

### Code Quality
- ✅ Proper widget lifecycle management
- ✅ Custom exception classes
- ✅ Progress callbacks for async operations
- ✅ Material 3 design

## Project Structure

```
analysttrack/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   └── event_models.dart        # Data models
│   ├── services/
│   │   └── espn_nfl_service.dart    # API service
│   └── screens/
│       └── nfl_week_events_screen.dart  # Main screen
├── test/                            # Unit tests
├── pubspec.yaml                     # Dependencies
└── README.md                        # Documentation
```

## Dependencies

- `http: ^1.1.0` - HTTP requests
- `flutter` - Flutter framework
- `cupertino_icons` - iOS-style icons

## Future Enhancements

- [ ] Add caching for API responses
- [ ] Implement team-specific queries
- [ ] Add favorite teams
- [ ] Show play-by-play data
- [ ] Add statistics and player information
- [ ] Dark mode support
- [ ] Search functionality
- [ ] Filter by team

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
