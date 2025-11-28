import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/event_models.dart';
import '../models/player_models.dart';

/// Service for interacting with ESPN's NFL API
class ESPNNFLService {
  /// Base URL for ESPN API
  /// On web, uses CORS proxy to avoid browser CORS restrictions
  /// On mobile/desktop, uses direct API access
  static String get baseUrl {
    if (kIsWeb) {
      // Use CORS proxy for web browsers
      return 'https://corsproxy.io/?https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
    } else {
      // Direct API access for mobile/desktop
      return 'https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
    }
  }

  /// Timeout duration for HTTP requests
  static const Duration requestTimeout = Duration(seconds: 10);

  /// Delay between request batches to avoid rate limiting
  static const Duration batchDelay = Duration(milliseconds: 200);

  /// Number of concurrent requests per batch
  static const int batchSize = 5;

  /// Get all event IDs for a specific week
  ///
  /// [season] - Year (e.g., 2024, 2025)
  /// [seasonType] - 1=preseason, 2=regular season, 3=postseason
  /// [week] - Week number
  ///
  /// Throws [ESPNServiceException] if the request fails
  Future<WeekEventsResponse> getWeekEvents(
    int season,
    int seasonType,
    int week,
  ) async {
    final url =
        '$baseUrl/seasons/$season/types/$seasonType/weeks/$week/events';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeekEventsResponse.fromJson(json);
      } else {
        throw ESPNServiceException(
          'Failed to load events: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading week events: $e',
        originalError: e,
      );
    }
  }

  /// Get detailed information about a specific event
  ///
  /// Throws [ESPNServiceException] if the request fails
  Future<EventDetails> getEventDetails(String eventId) async {
    final url = '$baseUrl/events/$eventId';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return EventDetails.fromJson(json);
      } else {
        throw ESPNServiceException(
          'Failed to load event $eventId: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading event $eventId: $e',
        originalError: e,
      );
    }
  }

  /// Get all events with details for a week
  ///
  /// This method throttles requests to avoid overwhelming the API.
  /// Events are fetched in batches of [batchSize] with a delay between batches.
  ///
  /// [onProgress] - Optional callback to track loading progress (current, total)
  ///
  /// Throws [ESPNServiceException] if any request fails
  Future<List<EventDetails>> getAllWeekEventsWithDetails(
    int season,
    int seasonType,
    int week, {
    void Function(int current, int total)? onProgress,
  }) async {
    final weekData = await getWeekEvents(season, seasonType, week);

    if (weekData.eventIds.isEmpty) {
      return [];
    }

    final events = <EventDetails>[];
    final total = weekData.eventIds.length;

    // Process events in batches to avoid rate limiting
    for (var i = 0; i < weekData.eventIds.length; i += batchSize) {
      final batch = weekData.eventIds.skip(i).take(batchSize);

      // Fetch batch concurrently
      final batchFutures = batch.map((id) => getEventDetails(id));
      final batchResults = await Future.wait(batchFutures);

      events.addAll(batchResults);

      // Report progress
      if (onProgress != null) {
        onProgress(events.length, total);
      }

      // Small delay between batches to be respectful to the API
      if (i + batchSize < weekData.eventIds.length) {
        await Future.delayed(batchDelay);
      }
    }

    return events;
  }

  /// Get events for a specific team across multiple weeks
  ///
  /// [teamAbbreviation] - Team abbreviation (e.g., 'KC', 'SF')
  /// Returns events where either home or away team matches
  Future<List<EventDetails>> getTeamEvents(
    int season,
    int seasonType,
    String teamAbbreviation,
  ) async {
    // This would require fetching multiple weeks and filtering
    // Left as an exercise or future enhancement
    throw UnimplementedError('Team-specific queries not yet implemented');
  }

  /// Get game boxscore with player statistics
  ///
  /// Uses the site API endpoint which includes comprehensive boxscore data
  /// with player statistics organized by category (passing, rushing, etc.)
  ///
  /// [eventId] - The event/game ID
  /// Throws [ESPNServiceException] if the request fails
  Future<GameBoxscore> getGameBoxscore(String eventId) async {
    // Use the site API for boxscore which has better player stats
    final url = kIsWeb
        ? 'https://corsproxy.io/?https://site.api.espn.com/apis/site/v2/sports/football/nfl/summary?event=$eventId'
        : 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/summary?event=$eventId';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract boxscore data
        final boxscoreData = json['boxscore'] as Map<String, dynamic>?;
        if (boxscoreData == null) {
          throw ESPNServiceException(
            'No boxscore data available for event $eventId',
          );
        }

        return GameBoxscore.fromJson(boxscoreData, eventId);
      } else {
        throw ESPNServiceException(
          'Failed to load boxscore for event $eventId: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading boxscore for event $eventId: $e',
        originalError: e,
      );
    }
  }

  /// Get roster for a specific team in a game
  ///
  /// [eventId] - The event/game ID
  /// [teamId] - The team ID
  /// Throws [ESPNServiceException] if the request fails
  Future<List<Athlete>> getTeamRoster(String eventId, String teamId) async {
    final url = '$baseUrl/events/$eventId/competitions/$eventId/competitors/$teamId/roster';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final athletesData = json['athletes'] as List?;
        final athletes = <Athlete>[];

        if (athletesData != null) {
          for (final athleteData in athletesData) {
            try {
              athletes.add(Athlete.fromJson(athleteData as Map<String, dynamic>));
            } catch (e) {
              // Skip invalid athlete data
            }
          }
        }

        return athletes;
      } else {
        throw ESPNServiceException(
          'Failed to load roster for team $teamId: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading roster for team $teamId: $e',
        originalError: e,
      );
    }
  }

  /// Get detailed athlete information
  ///
  /// [athleteId] - The athlete/player ID
  /// Throws [ESPNServiceException] if the request fails
  Future<Athlete> getAthleteDetails(String athleteId) async {
    final url = '$baseUrl/athletes/$athleteId';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Athlete.fromJson(json);
      } else {
        throw ESPNServiceException(
          'Failed to load athlete $athleteId: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading athlete $athleteId: $e',
        originalError: e,
      );
    }
  }

  /// Get player statistics log (historical stats per game)
  ///
  /// Returns a list of game log entries showing the player's performance
  /// in each game of the specified season.
  ///
  /// [athleteId] - The athlete/player ID
  /// [season] - Year (e.g., 2024, 2025)
  /// [seasonType] - 1=preseason, 2=regular season, 3=postseason
  /// Throws [ESPNServiceException] if the request fails
  Future<List<PlayerStatsLogEntry>> getPlayerStatsLog(
    String athleteId,
    int season,
    int seasonType,
  ) async {
    final url = '$baseUrl/seasons/$season/types/$seasonType/athletes/$athleteId/eventlog';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final eventsData = json['events'] as List?;
        final logEntries = <PlayerStatsLogEntry>[];

        if (eventsData != null) {
          for (final eventData in eventsData) {
            try {
              logEntries.add(PlayerStatsLogEntry.fromJson(eventData as Map<String, dynamic>));
            } catch (e) {
              // Skip invalid event data
            }
          }
        }

        return logEntries;
      } else {
        throw ESPNServiceException(
          'Failed to load stats log for athlete $athleteId: ${response.statusCode}',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (e) {
      if (e is ESPNServiceException) rethrow;
      throw ESPNServiceException(
        'Network error loading stats log for athlete $athleteId: $e',
        originalError: e,
      );
    }
  }

  /// Get aggregated player statistics for a season
  ///
  /// This fetches summary statistics across all games in a season,
  /// including totals and averages for various statistical categories.
  ///
  /// [athleteId] - The athlete/player ID
  /// [season] - Year (e.g., 2024, 2025)
  /// [seasonType] - 1=preseason, 2=regular season, 3=postseason
  /// Throws [ESPNServiceException] if the request fails
  Future<AggregatedPlayerStats> getPlayerSeasonStats(
    String athleteId,
    int season,
    int seasonType,
  ) async {
    // Get the statistics log which contains game-by-game stats
    final gameLogs = await getPlayerStatsLog(athleteId, season, seasonType);

    // Get athlete details for name
    final athlete = await getAthleteDetails(athleteId);

    // Aggregate stats from game logs
    final passingStats = <String, dynamic>{};
    final rushingStats = <String, dynamic>{};
    final receivingStats = <String, dynamic>{};
    final defensiveStats = <String, dynamic>{};

    // This is a simplified aggregation
    // In a real implementation, you would sum/average the stats appropriately
    for (final log in gameLogs) {
      // Aggregate logic would go here
      // For now, we just collect the data structure
    }

    return AggregatedPlayerStats(
      athleteId: athleteId,
      athleteName: athlete.displayName,
      season: season,
      seasonType: seasonType,
      passingStats: passingStats,
      rushingStats: rushingStats,
      receivingStats: receivingStats,
      defensiveStats: defensiveStats,
      gameLogs: gameLogs,
    );
  }

  /// Search for players by name
  ///
  /// Note: This is a helper method that would typically use a search endpoint.
  /// ESPN's public API doesn't have a direct search endpoint, so this is
  /// left as a placeholder for future implementation.
  ///
  /// [query] - Player name to search for
  /// Throws [UnimplementedError]
  Future<List<Athlete>> searchPlayers(String query) async {
    throw UnimplementedError('Player search not yet implemented');
  }
}

/// Custom exception for ESPN service errors
class ESPNServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;
  final Object? originalError;

  ESPNServiceException(
    this.message, {
    this.statusCode,
    this.responseBody,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ESPNServiceException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    return buffer.toString();
  }

  /// Returns true if this is a network connectivity error
  bool get isNetworkError => statusCode == null && originalError != null;

  /// Returns true if this is a 4xx client error
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Returns true if this is a 5xx server error
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
