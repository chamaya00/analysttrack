# ESPN API Guide - NFL Player Statistics

This guide explains how to use the ESPN API to pull NFL data, including player statistics per game and historical stats.

## Overview

The ESPN API provides comprehensive NFL data through multiple endpoints. This application implements access to:

1. **Game/Event Data** - Schedule, scores, and game details
2. **Player Statistics per Game** - Detailed boxscore with player performance
3. **Historical Player Stats** - Game-by-game logs and season aggregates
4. **Team Rosters** - Player information for teams in specific games
5. **Athlete Details** - Individual player profiles and information

## ESPN API Endpoints

### Base URLs

The application uses two ESPN API endpoints:

1. **Core API**: `https://sports.core.api.espn.com/v2/sports/football/leagues/nfl`
   - Used for structured data retrieval
   - Best for programmatic access to NFL data

2. **Site API**: `https://site.api.espn.com/apis/site/v2/sports/football/nfl`
   - Used for comprehensive boxscore data
   - Includes richer player statistics

### Available Data

#### 1. Game Events

**Endpoint**: `/seasons/{year}/types/{seasonType}/weeks/{week}/events`

**Example**: Get all games from Week 1 of 2024 Regular Season
```dart
final events = await service.getAllWeekEventsWithDetails(2024, 2, 1);
```

**Data Includes**:
- Event ID and name
- Date and time
- Home and away teams
- Scores (if game is completed or in progress)
- Game status (scheduled, in progress, final)
- Venue information

#### 2. Game Boxscore with Player Stats

**Endpoint**: `/summary?event={eventId}` (Site API)

**Example**: Get player statistics for a specific game
```dart
final boxscore = await service.getGameBoxscore('401671815');
```

**Data Includes**:
- **Passing Stats**: Completions, attempts, yards, TDs, interceptions, passer rating
- **Rushing Stats**: Carries, yards, yards per carry, longest run, TDs
- **Receiving Stats**: Receptions, yards, yards per catch, longest reception, TDs
- **Defensive Stats**: Tackles, sacks, interceptions, forced fumbles
- **Kicking Stats**: Field goals, extra points, accuracy
- **Punting Stats**: Number of punts, average yards, longest punt

**Usage**:
```dart
// Get boxscore for a game
final boxscore = await service.getGameBoxscore(eventId);

// Access stats for a specific team
final team1Stats = boxscore.teams[0];
final team2Stats = boxscore.teams[1];

// Get a specific stat category (e.g., passing)
final passingStats = team1Stats.getCategory('passing');

// Access individual player stats
for (final playerStats in passingStats.athletes) {
  print('${playerStats.athlete.displayName}: ${playerStats.stats}');
}
```

#### 3. Historical Player Statistics

**Endpoint**: `/seasons/{year}/types/{seasonType}/athletes/{athleteId}/eventlog`

**Example**: Get a player's game-by-game stats for the 2024 season
```dart
final gameLogs = await service.getPlayerStatsLog(athleteId, 2024, 2);
```

**Data Includes**:
- Game-by-game performance
- Opponent information
- Date of each game
- Complete statistics for each game

**Usage**:
```dart
// Get player's game logs for a season
final logs = await service.getPlayerStatsLog('123456', 2024, 2);

// Iterate through each game
for (final log in logs) {
  print('${log.date}: vs ${log.opponent}');
  print('Stats: ${log.stats}');
}
```

#### 4. Aggregated Season Statistics

**Example**: Get complete season stats with aggregation
```dart
final seasonStats = await service.getPlayerSeasonStats(athleteId, 2024, 2);
```

**Data Includes**:
- Season totals and averages
- Passing, rushing, receiving, and defensive stats
- Complete game log history
- Player information

#### 5. Team Roster

**Endpoint**: `/events/{eventId}/competitions/{eventId}/competitors/{teamId}/roster`

**Example**: Get roster for a team in a specific game
```dart
final roster = await service.getTeamRoster(eventId, teamId);
```

**Data Includes**:
- Player ID, name, and position
- Jersey number
- Headshot image URL
- Team affiliation

#### 6. Athlete Details

**Endpoint**: `/athletes/{athleteId}`

**Example**: Get detailed information about a player
```dart
final athlete = await service.getAthleteDetails('123456');
```

**Data Includes**:
- Full name (first, last, display name)
- Position
- Jersey number
- Headshot photo
- Team information

## Season Types

The API uses numeric codes for different parts of the NFL season:

- `1` = Preseason
- `2` = Regular Season
- `3` = Postseason

## Statistical Categories

### Passing Statistics
- **C/ATT**: Completions/Attempts
- **YDS**: Passing yards
- **AVG**: Yards per attempt
- **TD**: Touchdown passes
- **INT**: Interceptions
- **QBR**: Quarterback rating
- **LONG**: Longest completion

### Rushing Statistics
- **CAR**: Rushing attempts (carries)
- **YDS**: Rushing yards
- **AVG**: Yards per carry
- **TD**: Rushing touchdowns
- **LONG**: Longest run

### Receiving Statistics
- **REC**: Receptions
- **YDS**: Receiving yards
- **AVG**: Yards per reception
- **TD**: Receiving touchdowns
- **LONG**: Longest reception
- **TGTS**: Targets

### Defensive Statistics
- **TOT**: Total tackles
- **SOLO**: Solo tackles
- **SACKS**: Quarterback sacks
- **TFL**: Tackles for loss
- **INT**: Interceptions
- **FF**: Forced fumbles
- **FR**: Fumble recoveries

### Kicking Statistics
- **FG**: Field goals made/attempted
- **PCT**: Field goal percentage
- **LONG**: Longest field goal
- **XP**: Extra points made/attempted

### Punting Statistics
- **NO**: Number of punts
- **YDS**: Total punt yards
- **AVG**: Average yards per punt
- **LONG**: Longest punt
- **IN20**: Punts inside the 20-yard line

## Data Models

### Core Models

**Athlete**
```dart
class Athlete {
  final String id;
  final String displayName;
  final String firstName;
  final String lastName;
  final String? position;
  final String? jersey;
  final String? headshot;
  final String? teamId;
}
```

**GameBoxscore**
```dart
class GameBoxscore {
  final String eventId;
  final List<TeamPlayerStats> teams;

  TeamPlayerStats? getTeamStats(String teamId);
}
```

**TeamPlayerStats**
```dart
class TeamPlayerStats {
  final String teamId;
  final String teamName;
  final List<StatCategory> statistics;

  StatCategory? getCategory(String categoryName);
  List<PlayerStats> getAllPlayers();
}
```

**StatCategory**
```dart
class StatCategory {
  final String name;
  final String abbreviation;
  final List<String> labels;
  final List<PlayerStats> athletes;

  List<PlayerStats> sortByStatIndex(int index, {bool descending = true});
}
```

**PlayerStats**
```dart
class PlayerStats {
  final Athlete athlete;
  final List<String> stats;

  String? getStatByIndex(int index);
  double getStatAsNumber(int index);
}
```

**PlayerStatsLogEntry**
```dart
class PlayerStatsLogEntry {
  final String eventId;
  final DateTime date;
  final String opponent;
  final Map<String, dynamic> stats;
}
```

## UI Components

### 1. Game Player Stats Screen

Displays player statistics for a specific game with:
- Team selector to switch between teams
- Expandable stat categories
- Scrollable data tables with player performance

**Navigation**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => GamePlayerStatsScreen(
      eventId: 'game_id',
      eventName: 'Game Name',
    ),
  ),
);
```

### 2. Player History Screen

Shows historical statistics for a specific player with:
- Season and season type selectors
- Player profile header with photo
- Game-by-game performance logs
- Expandable game cards with detailed stats

**Navigation**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PlayerHistoryScreen(
      athleteId: 'player_id',
      athleteName: 'Player Name',
    ),
  ),
);
```

## Example Workflows

### Workflow 1: View Player Stats for a Completed Game

1. Load week events
2. Select a completed game
3. Click "View Player Stats"
4. Browse stats by team and category

### Workflow 2: Track a Player's Season Performance

1. Get player ID from a game boxscore
2. Navigate to Player History screen
3. Select season and season type
4. Review game-by-game performance

### Workflow 3: Compare Team Performance

1. Load game boxscore
2. Switch between teams using team selector
3. Compare stat categories (passing, rushing, etc.)
4. Identify top performers

## Rate Limiting and Best Practices

The ESPN API is unofficial and has no documented rate limits, but the application implements best practices:

1. **Request Throttling**: Batch requests with delays (200ms between batches)
2. **Batch Size**: Process 5 concurrent requests at a time
3. **Timeout**: 10-second timeout per request
4. **Error Handling**: Graceful degradation with retry options
5. **CORS Handling**: Automatic proxy for web platform

## CORS Proxy (Web Platform Only)

For web deployments, the application uses `corsproxy.io` to bypass browser CORS restrictions:

```dart
static String get baseUrl {
  if (kIsWeb) {
    return 'https://corsproxy.io/?https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
  } else {
    return 'https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
  }
}
```

Mobile and desktop platforms access the API directly.

## Important Notes

⚠️ **Unofficial API**: ESPN's API is not officially documented or supported. Endpoints may change without notice.

⚠️ **No Authentication**: The public ESPN API doesn't require authentication, but may be subject to IP-based rate limiting.

⚠️ **Data Availability**: Player statistics are only available for completed or in-progress games. Scheduled games won't have boxscore data.

⚠️ **Historical Data**: Historical stats depend on ESPN's data retention. Very old seasons may have limited data.

## References

- [ESPN API Community Documentation](https://gist.github.com/nntrn/ee26cb2a0716de0947a0a4e9a157bc1c)
- [ESPN Hidden API Guide](https://gist.github.com/akeaswaran/b48b02f1c94f873c6655e7129910fc3b)
- [Public ESPN API on GitHub](https://github.com/pseudo-r/Public-ESPN-API)

## Future Enhancements

Potential additions to the ESPN API integration:

- [ ] Player search functionality
- [ ] Team-specific event filtering
- [ ] Caching of API responses
- [ ] Play-by-play data
- [ ] Advanced statistics (EPA, DVOA, etc.)
- [ ] Injury reports
- [ ] Depth charts
- [ ] Betting lines and odds
- [ ] News and articles
- [ ] Video highlights (if available)
