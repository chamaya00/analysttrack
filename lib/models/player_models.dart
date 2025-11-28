/// Data models for ESPN NFL Player Statistics
library;

/// Represents an NFL athlete/player
class Athlete {
  final String id;
  final String displayName;
  final String firstName;
  final String lastName;
  final String? position;
  final String? jersey;
  final String? headshot;
  final String? teamId;

  Athlete({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    this.position,
    this.jersey,
    this.headshot,
    this.teamId,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Unknown',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      position: json['position']?['abbreviation'] as String?,
      jersey: json['jersey'] as String?,
      headshot: json['headshot']?['href'] as String?,
      teamId: json['team']?['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'jersey': jersey,
      'headshot': headshot,
      'teamId': teamId,
    };
  }
}

/// Game boxscore with player statistics
class GameBoxscore {
  final String eventId;
  final List<TeamPlayerStats> teams;

  GameBoxscore({
    required this.eventId,
    required this.teams,
  });

  factory GameBoxscore.fromJson(Map<String, dynamic> json, String eventId) {
    final teamsData = json['players'] as List?;
    final teams = <TeamPlayerStats>[];

    if (teamsData != null) {
      for (final teamData in teamsData) {
        try {
          teams.add(TeamPlayerStats.fromJson(teamData as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid team data
        }
      }
    }

    return GameBoxscore(
      eventId: eventId,
      teams: teams,
    );
  }

  /// Get stats for a specific team by ID
  TeamPlayerStats? getTeamStats(String teamId) {
    try {
      return teams.firstWhere((t) => t.teamId == teamId);
    } catch (e) {
      return null;
    }
  }
}

/// Player statistics for a team in a game
class TeamPlayerStats {
  final String teamId;
  final String teamName;
  final String teamAbbreviation;
  final List<StatCategory> statistics;

  TeamPlayerStats({
    required this.teamId,
    required this.teamName,
    required this.teamAbbreviation,
    required this.statistics,
  });

  factory TeamPlayerStats.fromJson(Map<String, dynamic> json) {
    final statsData = json['statistics'] as List?;
    final statistics = <StatCategory>[];

    if (statsData != null) {
      for (final statData in statsData) {
        try {
          statistics.add(StatCategory.fromJson(statData as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid stat data
        }
      }
    }

    final teamData = json['team'] as Map<String, dynamic>?;

    return TeamPlayerStats(
      teamId: teamData?['id'] as String? ?? '',
      teamName: teamData?['displayName'] as String? ?? 'Unknown',
      teamAbbreviation: teamData?['abbreviation'] as String? ?? 'UNK',
      statistics: statistics,
    );
  }

  /// Get a specific stat category by name (e.g., "passing", "rushing")
  StatCategory? getCategory(String categoryName) {
    try {
      return statistics.firstWhere(
        (s) => s.name.toLowerCase() == categoryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all players who have stats in any category
  List<PlayerStats> getAllPlayers() {
    final playerMap = <String, PlayerStats>{};

    for (final category in statistics) {
      for (final player in category.athletes) {
        playerMap[player.athlete.id] = player;
      }
    }

    return playerMap.values.toList();
  }
}

/// Statistical category (passing, rushing, receiving, etc.)
class StatCategory {
  final String name;
  final String abbreviation;
  final String? displayName;
  final List<String> labels; // Stat column names
  final List<PlayerStats> athletes;

  StatCategory({
    required this.name,
    required this.abbreviation,
    this.displayName,
    required this.labels,
    required this.athletes,
  });

  factory StatCategory.fromJson(Map<String, dynamic> json) {
    final athletesData = json['athletes'] as List?;
    final athletes = <PlayerStats>[];

    if (athletesData != null) {
      for (final athleteData in athletesData) {
        try {
          athletes.add(PlayerStats.fromJson(athleteData as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid athlete data
        }
      }
    }

    final labelsData = json['labels'] as List?;
    final labels = labelsData?.map((l) => l.toString()).toList() ?? [];

    return StatCategory(
      name: json['name'] as String? ?? '',
      abbreviation: json['abbreviation'] as String? ?? '',
      displayName: json['displayName'] as String?,
      labels: labels,
      athletes: athletes,
    );
  }

  /// Sort athletes by a specific stat index
  List<PlayerStats> sortByStatIndex(int statIndex, {bool descending = true}) {
    final sorted = List<PlayerStats>.from(athletes);
    sorted.sort((a, b) {
      if (statIndex >= a.stats.length || statIndex >= b.stats.length) {
        return 0;
      }

      final aValue = double.tryParse(a.stats[statIndex]) ?? 0;
      final bValue = double.tryParse(b.stats[statIndex]) ?? 0;

      return descending ? bValue.compareTo(aValue) : aValue.compareTo(bValue);
    });

    return sorted;
  }
}

/// Player statistics for a specific category
class PlayerStats {
  final Athlete athlete;
  final List<String> stats; // Array of stat values matching the labels

  PlayerStats({
    required this.athlete,
    required this.stats,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    final athleteData = json['athlete'] as Map<String, dynamic>?;
    final athlete = athleteData != null
        ? Athlete.fromJson(athleteData)
        : Athlete(
            id: '',
            displayName: 'Unknown',
            firstName: '',
            lastName: '',
          );

    final statsData = json['stats'] as List?;
    final stats = statsData?.map((s) => s.toString()).toList() ?? [];

    return PlayerStats(
      athlete: athlete,
      stats: stats,
    );
  }

  /// Get a specific stat value by index
  String? getStatByIndex(int index) {
    if (index < 0 || index >= stats.length) return null;
    return stats[index];
  }

  /// Get a stat as a number (returns 0 if not parseable)
  double getStatAsNumber(int index) {
    final stat = getStatByIndex(index);
    return double.tryParse(stat ?? '') ?? 0;
  }
}

/// Historical player statistics log entry
class PlayerStatsLogEntry {
  final String eventId;
  final DateTime date;
  final String opponent;
  final Map<String, dynamic> stats;

  PlayerStatsLogEntry({
    required this.eventId,
    required this.date,
    required this.opponent,
    required this.stats,
  });

  factory PlayerStatsLogEntry.fromJson(Map<String, dynamic> json) {
    DateTime eventDate;
    try {
      eventDate = DateTime.parse(json['date'] as String);
    } catch (e) {
      eventDate = DateTime.now();
    }

    return PlayerStatsLogEntry(
      eventId: json['eventId'] as String? ?? '',
      date: eventDate,
      opponent: json['opponent'] as String? ?? 'Unknown',
      stats: json['stats'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'date': date.toIso8601String(),
      'opponent': opponent,
      'stats': stats,
    };
  }
}

/// Aggregated player statistics over a season or career
class AggregatedPlayerStats {
  final String athleteId;
  final String athleteName;
  final int season;
  final int seasonType;
  final Map<String, dynamic> passingStats;
  final Map<String, dynamic> rushingStats;
  final Map<String, dynamic> receivingStats;
  final Map<String, dynamic> defensiveStats;
  final List<PlayerStatsLogEntry> gameLogs;

  AggregatedPlayerStats({
    required this.athleteId,
    required this.athleteName,
    required this.season,
    required this.seasonType,
    required this.passingStats,
    required this.rushingStats,
    required this.receivingStats,
    required this.defensiveStats,
    required this.gameLogs,
  });

  factory AggregatedPlayerStats.fromJson(Map<String, dynamic> json) {
    final gameLogsData = json['gameLogs'] as List?;
    final gameLogs = <PlayerStatsLogEntry>[];

    if (gameLogsData != null) {
      for (final logData in gameLogsData) {
        try {
          gameLogs.add(PlayerStatsLogEntry.fromJson(logData as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid log entry
        }
      }
    }

    return AggregatedPlayerStats(
      athleteId: json['athleteId'] as String? ?? '',
      athleteName: json['athleteName'] as String? ?? 'Unknown',
      season: json['season'] as int? ?? DateTime.now().year,
      seasonType: json['seasonType'] as int? ?? 2,
      passingStats: json['passingStats'] as Map<String, dynamic>? ?? {},
      rushingStats: json['rushingStats'] as Map<String, dynamic>? ?? {},
      receivingStats: json['receivingStats'] as Map<String, dynamic>? ?? {},
      defensiveStats: json['defensiveStats'] as Map<String, dynamic>? ?? {},
      gameLogs: gameLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'athleteId': athleteId,
      'athleteName': athleteName,
      'season': season,
      'seasonType': seasonType,
      'passingStats': passingStats,
      'rushingStats': rushingStats,
      'receivingStats': receivingStats,
      'defensiveStats': defensiveStats,
      'gameLogs': gameLogs.map((log) => log.toJson()).toList(),
    };
  }
}
