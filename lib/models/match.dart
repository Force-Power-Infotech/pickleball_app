

class DoublesServeState {
  bool isFirstServe = true;
  int serverNumber = 2; // Start with server 2
  int serverPlayerIndex = 1;
  // Track player positions for each team if needed
  void switchSides(ServingTeam team) {
    // Implement side switching logic if you track player positions
  }
}

/// Match model representing a pickleball game
class Match {
  // For doubles mode: serving state tracking
  DoublesServeState? doublesServeState;
  final String teamAName;
  final String teamBName;
  final MatchType matchType;
  final int targetScore; // 11, 18, or 21
  final ServingTeam firstServingTeam;

  /// Court number (can be int or custom string)
  final String? courtNo;

  // Player names for doubles matches
  final String? teamAPlayer1;
  final String? teamAPlayer2;
  final String? teamBPlayer1;
  final String? teamBPlayer2;

  int teamAScore;
  int teamBScore;
  ServingTeam currentServingTeam;
  bool isMatchComplete;
  DateTime startTime;
  DateTime? endTime;

  List<ScorePoint> scoreHistory;

  Match({
    required this.teamAName,
    required this.teamBName,
    required this.matchType,
    required this.targetScore,
    required this.firstServingTeam,
    this.courtNo,
    this.teamAPlayer1,
    this.teamAPlayer2,
    this.teamBPlayer1,
    this.teamBPlayer2,
    this.teamAScore = 0,
    this.teamBScore = 0,
    this.isMatchComplete = false,
  }) : currentServingTeam = firstServingTeam,
       startTime = DateTime.now(),
       scoreHistory = [];

  /// Get formatted team A display name
  String get teamADisplayName {
    if (matchType == MatchType.singles) {
      return teamAName;
    } else {
      final player1 = teamAPlayer1 ?? 'Player 1';
      final player2 = teamAPlayer2 ?? 'Player 2';
      return '$player1 & $player2';
    }
  }

  /// Get formatted team B display name
  String get teamBDisplayName {
    if (matchType == MatchType.singles) {
      return teamBName;
    } else {
      final player1 = teamBPlayer1 ?? 'Player 1';
      final player2 = teamBPlayer2 ?? 'Player 2';
      return '$player1 & $player2';
    }
  }

  /// Check if the match has been won by any team
  bool get hasWinner {
    // Must reach target score first
    if (teamAScore < targetScore && teamBScore < targetScore) {
      return false;
    }
    
    // Must win by at least 2 points
    final scoreDifference = (teamAScore - teamBScore).abs();
    return (teamAScore >= targetScore || teamBScore >= targetScore) && scoreDifference >= 2;
  }

  /// Check if the match is in duce state
  bool get isDuce {
    final duceThreshold = targetScore - 1; // 10 for 11-point, 17 for 18-point, 20 for 21-point
    
    // Both teams must be at or above duce threshold
    if (teamAScore < duceThreshold || teamBScore < duceThreshold) {
      return false;
    }
    
    // Score difference must be less than 2
    final scoreDifference = (teamAScore - teamBScore).abs();
    return scoreDifference < 2;
  }

  /// Get deuce message for display
  String? get duceMessage {
    if (!isDuce) return null;
    
    if (teamAScore == teamBScore) {
      return 'Match Deuce ${teamAScore} all';
    } else {
      final leadingTeam = teamAScore > teamBScore ? teamAName : teamBName;
      // Truncate team name if too long for mobile
      final shortTeamName = leadingTeam.length > 12 ? '${leadingTeam.substring(0, 9)}...' : leadingTeam;
      return 'ADV: $shortTeamName';
    }
  }

  /// Get the winning team
  ServingTeam? get winner {
    if (!hasWinner) return null;
    
    if (teamAScore > teamBScore) return ServingTeam.teamA;
    if (teamBScore > teamAScore) return ServingTeam.teamB;
    return null;
  }

  /// Get the current score as a formatted string
  String get scoreDisplay => '$teamAScore - $teamBScore';

  /// Get match duration
  Duration get matchDuration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'teamAName': teamAName,
      'teamBName': teamBName,
      'matchType': matchType.index,
      'targetScore': targetScore,
      'firstServingTeam': firstServingTeam.index,
      'courtNo': courtNo,
      'teamAPlayer1': teamAPlayer1,
      'teamAPlayer2': teamAPlayer2,
      'teamBPlayer1': teamBPlayer1,
      'teamBPlayer2': teamBPlayer2,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'currentServingTeam': currentServingTeam.index,
      'isMatchComplete': isMatchComplete,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'scoreHistory': scoreHistory.map((e) => e.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    final match = Match(
      teamAName: json['teamAName'],
      teamBName: json['teamBName'],
      matchType: MatchType.values[json['matchType'] ?? 0],
      targetScore: json['targetScore'],
      firstServingTeam: ServingTeam.values[json['firstServingTeam']],
      courtNo: json['courtNo'],
      teamAPlayer1: json['teamAPlayer1'],
      teamAPlayer2: json['teamAPlayer2'],
      teamBPlayer1: json['teamBPlayer1'],
      teamBPlayer2: json['teamBPlayer2'],
      teamAScore: json['teamAScore'],
      teamBScore: json['teamBScore'],
      isMatchComplete: json['isMatchComplete'],
    );

    match.currentServingTeam = ServingTeam.values[json['currentServingTeam']];
    match.startTime = DateTime.parse(json['startTime']);
    if (json['endTime'] != null) {
      match.endTime = DateTime.parse(json['endTime']);
    }

    match.scoreHistory = (json['scoreHistory'] as List)
        .map((e) => ScorePoint.fromJson(e))
        .toList();

    return match;
  }
}

/// Enum for match types
enum MatchType {
  singles,
  doubles;

  String get displayName {
    switch (this) {
      case MatchType.singles:
        return 'Singles';
      case MatchType.doubles:
        return 'Doubles';
    }
  }

  String get description {
    switch (this) {
      case MatchType.singles:
        return '1 vs 1 Player';
      case MatchType.doubles:
        return '2 vs 2 Players';
    }
  }
}

/// Represents which team is currently serving
enum ServingTeam {
  teamA,
  teamB;

  /// Get the opposite team
  ServingTeam get opposite {
    return this == ServingTeam.teamA ? ServingTeam.teamB : ServingTeam.teamA;
  }
}

/// Represents a single point in the match history
class ScorePoint {
  final int turnNumber;
  final ServingTeam servingTeam;
  final ServingTeam winningTeam;
  final bool pointAwarded;
  final int teamAScore;
  final int teamBScore;
  final DateTime timestamp;
  // For doubles: 1 or 2 (null for singles)
  final int? serverNumber;
  // For doubles: 0 or 1 (null for singles), index of player serving
  final int? serverPlayerIndex;

  ScorePoint({
    required this.turnNumber,
    required this.servingTeam,
    required this.winningTeam,
    required this.pointAwarded,
    required this.teamAScore,
    required this.teamBScore,
    required this.timestamp,
    this.serverNumber,
    this.serverPlayerIndex,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'turnNumber': turnNumber,
      'servingTeam': servingTeam.index,
      'winningTeam': winningTeam.index,
      'pointAwarded': pointAwarded,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'timestamp': timestamp.toIso8601String(),
      'serverNumber': serverNumber,
      'serverPlayerIndex': serverPlayerIndex,
    };
  }

  /// Create from JSON
  factory ScorePoint.fromJson(Map<String, dynamic> json) {
    return ScorePoint(
      turnNumber: json['turnNumber'],
      servingTeam: ServingTeam.values[json['servingTeam']],
      winningTeam: ServingTeam.values[json['winningTeam']],
      pointAwarded: json['pointAwarded'],
      teamAScore: json['teamAScore'],
      teamBScore: json['teamBScore'],
      timestamp: DateTime.parse(json['timestamp']),
      serverNumber: json['serverNumber'],
      serverPlayerIndex: json['serverPlayerIndex'],
    );
  }
}
