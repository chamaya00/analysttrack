# AnalystTrack

A Flutter application for tracking NFL analytics using the ESPN API.

## 🚀 Quick Start - Deploy to Web

Want to share this app via link? See **[NETLIFY_DEPLOY.md](NETLIFY_DEPLOY.md)** for 2-minute deployment guide.

```bash
./build-web.sh  # Build for web
# Then drag build/web to netlify.com/drop
```

## Features

- **Week Events Viewer**: Browse NFL games by season, week, and season type
- **Player Statistics**: View detailed player stats for each game (boxscore)
- **Historical Player Stats**: Track player performance over time with game logs
- **Real-time Data**: Fetch live game information from ESPN's API
- **Comprehensive Game Details**: View teams, scores, venues, and game status
- **Progress Tracking**: See loading progress when fetching multiple events
- **Error Handling**: Robust error handling with user-friendly messages
- **Throttled Requests**: API calls are batched to avoid rate limiting

## Architecture

### Models (`lib/models/`)

**Event Models**:
- `WeekEventsResponse`: Contains event IDs for a specific week
- `EventDetails`: Detailed game information
- `Competition`: Competition/game details including teams
- `Competitor`: Team information with scores

**Player Models**:
- `Athlete`: Player information (name, position, jersey, headshot)
- `GameBoxscore`: Complete boxscore with player statistics
- `TeamPlayerStats`: Team's player statistics organized by category
- `StatCategory`: Statistical category (passing, rushing, receiving, etc.)
- `PlayerStats`: Individual player statistics for a category
- `PlayerStatsLogEntry`: Historical game-by-game performance
- `AggregatedPlayerStats`: Season-long aggregated statistics

### Services (`lib/services/`)
- `ESPNNFLService`: Main service for interacting with ESPN's NFL API
  - Request timeout handling
  - Batch processing with throttling
  - Comprehensive error handling
  - Progress callbacks
  - **NEW**: Player statistics retrieval
  - **NEW**: Historical player data
  - **NEW**: Team rosters
  - **NEW**: Athlete details

### Screens (`lib/screens/`)
- `NFLWeekEventsScreen`: Main screen for browsing NFL events
  - Proper controller lifecycle management
  - Loading states with progress
  - Error states with retry
  - Segmented season type selection
  - **NEW**: Navigation to player stats
- `GamePlayerStatsScreen`: **NEW** - Display player statistics for a game
  - Team selector
  - Expandable stat categories
  - Scrollable data tables
- `PlayerHistoryScreen`: **NEW** - View historical player performance
  - Season selector
  - Player profile header
  - Game-by-game statistics

## ESPN API

This app uses ESPN's public NFL API:

### Base URL
```
https://sports.core.api.espn.com/v2/sports/football/leagues/nfl
```

### Endpoints Used

**Event Data**:
- `/seasons/{year}/types/{seasonType}/weeks/{week}/events` - Get event IDs
- `/events/{eventId}` - Get event details

**Player Statistics**:
- `/summary?event={eventId}` (Site API) - Get game boxscore with player stats
- `/seasons/{year}/types/{seasonType}/athletes/{athleteId}/eventlog` - Player game logs
- `/athletes/{athleteId}` - Athlete details
- `/events/{eventId}/competitions/{eventId}/competitors/{teamId}/roster` - Team roster

> 📖 For comprehensive ESPN API documentation and usage examples, see [ESPN_API_GUIDE.md](ESPN_API_GUIDE.md)

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

### Viewing Week Events
1. Select the season year (e.g., 2025)
2. Select the week number (1-18)
3. Choose season type (Preseason/Regular/Postseason)
4. Tap "Load Events" to fetch games
5. Tap on any game card to see detailed information

### Viewing Player Statistics
1. From the game details dialog, tap "View Player Stats"
2. Use the team selector to switch between teams
3. Browse different stat categories (passing, rushing, receiving, etc.)
4. View detailed player performance in scrollable tables

### Viewing Historical Player Stats
1. Navigate to a player from the game boxscore
2. Select the season and season type
3. Review game-by-game performance logs
4. Expand individual games to see detailed statistics

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
│   ├── main.dart                          # App entry point
│   ├── models/
│   │   ├── event_models.dart              # Event/game data models
│   │   └── player_models.dart             # Player statistics models
│   ├── services/
│   │   └── espn_nfl_service.dart          # ESPN API service
│   └── screens/
│       ├── nfl_week_events_screen.dart    # Main events screen
│       ├── game_player_stats_screen.dart  # Game boxscore screen
│       └── player_history_screen.dart     # Player history screen
├── test/                                  # Unit tests
├── pubspec.yaml                           # Dependencies
├── README.md                              # Documentation
└── ESPN_API_GUIDE.md                      # Comprehensive API guide
```

## Dependencies

- `http: ^1.1.0` - HTTP requests
- `intl: ^0.19.0` - Date formatting
- `flutter` - Flutter framework
- `cupertino_icons` - iOS-style icons

## Future Enhancements

- [x] ~~Add statistics and player information~~ ✅ **COMPLETED**
- [x] ~~Player statistics per game~~ ✅ **COMPLETED**
- [x] ~~Historical player data~~ ✅ **COMPLETED**
- [ ] Add caching for API responses
- [ ] Implement team-specific queries
- [ ] Add favorite teams
- [ ] Show play-by-play data
- [ ] Dark mode support
- [ ] Player search functionality
- [ ] Filter by team
- [ ] Advanced statistics (EPA, DVOA, etc.)
- [ ] Team depth charts
- [ ] Injury reports

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
