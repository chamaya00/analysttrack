/// Data models for ESPN NFL API
library;

/// Response containing week's event IDs and URLs
class WeekEventsResponse {
  final int count;
  final List<String> eventIds;
  final List<String> eventUrls;

  WeekEventsResponse({
    required this.count,
    required this.eventIds,
    required this.eventUrls,
  });

  factory WeekEventsResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? [];
    final eventIds = items.map((item) {
      final ref = item['\$ref'] as String?;
      if (ref == null) return '';
      final match = RegExp(r'events/(\d+)').firstMatch(ref);
      return match?.group(1) ?? '';
    }).where((id) => id.isNotEmpty).toList();

    return WeekEventsResponse(
      count: json['count'] as int? ?? 0,
      eventIds: eventIds,
      eventUrls: items.map((item) => item['\$ref'] as String? ?? '').toList(),
    );
  }
}

/// Detailed information about a single NFL event/game
class EventDetails {
  final String id;
  final String name;
  final String shortName;
  final DateTime date;
  final String status;
  final Competition? competition;

  EventDetails({
    required this.id,
    required this.name,
    required this.shortName,
    required this.date,
    required this.status,
    this.competition,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    // Safe date parsing
    DateTime eventDate;
    try {
      eventDate = DateTime.parse(json['date'] as String);
    } catch (e) {
      eventDate = DateTime.now();
    }

    // Parse competition data if available
    Competition? competition;
    final competitionsData = json['competitions'] as List?;
    if (competitionsData != null && competitionsData.isNotEmpty) {
      try {
        competition = Competition.fromJson(competitionsData[0] as Map<String, dynamic>);
      } catch (e) {
        // Competition parsing failed, leave as null
      }
    }

    return EventDetails(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      shortName: json['shortName'] as String? ?? 'Unknown',
      date: eventDate,
      status: json['status']?['\$ref'] as String? ?? 'unknown',
      competition: competition,
    );
  }

  /// Returns true if the game is completed
  bool get isCompleted => status.contains('final') || status.contains('completed');

  /// Returns true if the game is in progress
  bool get isInProgress => status.contains('in-progress') || status.contains('live');

  /// Returns true if the game is scheduled
  bool get isScheduled => !isCompleted && !isInProgress;
}

/// Competition details including teams and scores
class Competition {
  final String id;
  final List<Competitor> competitors;
  final String? venue;
  final bool neutralSite;

  Competition({
    required this.id,
    required this.competitors,
    this.venue,
    this.neutralSite = false,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    final competitorsData = json['competitors'] as List?;
    final competitors = <Competitor>[];

    if (competitorsData != null) {
      for (final comp in competitorsData) {
        try {
          competitors.add(Competitor.fromJson(comp as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid competitor data
        }
      }
    }

    return Competition(
      id: json['id'] as String? ?? '',
      competitors: competitors,
      venue: json['venue']?['fullName'] as String?,
      neutralSite: json['neutralSite'] as bool? ?? false,
    );
  }

  /// Returns the home team competitor
  Competitor? get homeTeam {
    try {
      return competitors.firstWhere((c) => c.isHome);
    } catch (e) {
      return null;
    }
  }

  /// Returns the away team competitor
  Competitor? get awayTeam {
    try {
      return competitors.firstWhere((c) => !c.isHome);
    } catch (e) {
      return null;
    }
  }
}

/// Team/competitor information
class Competitor {
  final String id;
  final String name;
  final String abbreviation;
  final int? score;
  final bool isHome;
  final String? logo;

  Competitor({
    required this.id,
    required this.name,
    required this.abbreviation,
    this.score,
    required this.isHome,
    this.logo,
  });

  factory Competitor.fromJson(Map<String, dynamic> json) {
    final teamData = json['team'] as Map<String, dynamic>?;

    return Competitor(
      id: json['id'] as String? ?? '',
      name: teamData?['displayName'] as String? ?? 'Unknown',
      abbreviation: teamData?['abbreviation'] as String? ?? 'UNK',
      score: json['score'] as int?,
      isHome: json['homeAway'] == 'home',
      logo: teamData?['logo'] as String?,
    );
  }
}
