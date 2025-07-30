import 'package:flutter/material.dart';
import '../models/match.dart';
import '../services/storage_service.dart';

/// Provider for managing match state and scoring logic
class MatchProvider extends ChangeNotifier {
  Match? _currentMatch;
  final StorageService _storageService = StorageService();
  bool _showScoreSummary = false;

  // Getters
  Match? get currentMatch => _currentMatch;
  bool get hasActiveMatch => _currentMatch != null;
  bool get showScoreSummary => _showScoreSummary;

  /// Start a new match
  void startMatch({
    required String teamAName,
    required String teamBName,
    required MatchType matchType,
    required int targetScore,
    required ServingTeam firstServingTeam,
    String? courtNo,
    String? teamAPlayer1,
    String? teamAPlayer2,
    String? teamBPlayer1,
    String? teamBPlayer2,
  }) {
    _currentMatch = Match(
      teamAName: teamAName,
      teamBName: teamBName,
      matchType: matchType,
      targetScore: targetScore,
      firstServingTeam: firstServingTeam,
      courtNo: courtNo,
      teamAPlayer1: teamAPlayer1,
      teamAPlayer2: teamAPlayer2,
      teamBPlayer1: teamBPlayer1,
      teamBPlayer2: teamBPlayer2,
    );
    _showScoreSummary = false;
    notifyListeners();
    _saveMatch();
  }

  /// Award point to a team (handles serving logic)
  void awardPoint(ServingTeam winningTeam) {
    if (_currentMatch == null || _currentMatch!.isMatchComplete) return;

    if (_currentMatch!.matchType == MatchType.singles) {
      // --- SINGLES LOGIC (unchanged) ---
      final servingTeam = _currentMatch!.currentServingTeam;
      bool pointAwarded = false;
      if (servingTeam == winningTeam) {
        pointAwarded = true;
        if (winningTeam == ServingTeam.teamA) {
          _currentMatch!.teamAScore++;
        } else {
          _currentMatch!.teamBScore++;
        }
      } else {
        _currentMatch!.currentServingTeam = winningTeam;
      }
      final scorePoint = ScorePoint(
        turnNumber: _currentMatch!.scoreHistory.length + 1,
        servingTeam: servingTeam,
        winningTeam: winningTeam,
        pointAwarded: pointAwarded,
        teamAScore: _currentMatch!.teamAScore,
        teamBScore: _currentMatch!.teamBScore,
        timestamp: DateTime.now(),
        serverNumber: null,
        serverPlayerIndex: null,
      );
      _currentMatch!.scoreHistory.add(scorePoint);
    } else {
      // --- DOUBLES LOGIC ---
      // State for doubles serving
  _currentMatch!.doublesServeState ??= DoublesServeState();
  final state = _currentMatch!.doublesServeState!;
      final servingTeam = _currentMatch!.currentServingTeam;
      bool pointAwarded = false;

      // At the start of the game, only server 2 serves
      if (state.isFirstServe) {
        state.isFirstServe = false;
        state.serverNumber = 2;
        state.serverPlayerIndex = 1;
      }

      // Capture current server info BEFORE updating state
      final currentServerNumber = state.serverNumber;
      final currentServerPlayerIndex = state.serverPlayerIndex;
      final currentServingTeam = servingTeam;

      // If serving team wins
      if (servingTeam == winningTeam) {
        pointAwarded = true;
        if (winningTeam == ServingTeam.teamA) {
          _currentMatch!.teamAScore++;
        } else {
          _currentMatch!.teamBScore++;
        }
        // Switch sides for both players
        state.switchSides(servingTeam);
        // Same server continues
      } else {
        // If first server, go to second server
        if (state.serverNumber == 1) {
          state.serverNumber = 2;
          state.serverPlayerIndex = 1;
        } else {
          // Side-out: switch to other team, server 1
          _currentMatch!.currentServingTeam = servingTeam.opposite;
          state.serverNumber = 1;
          state.serverPlayerIndex = 0;
        }
      }

      final scorePoint = ScorePoint(
        turnNumber: _currentMatch!.scoreHistory.length + 1,
        servingTeam: currentServingTeam,
        winningTeam: winningTeam,
        pointAwarded: pointAwarded,
        teamAScore: _currentMatch!.teamAScore,
        teamBScore: _currentMatch!.teamBScore,
        timestamp: DateTime.now(),
        serverNumber: currentServerNumber,
        serverPlayerIndex: currentServerPlayerIndex,
      );
      _currentMatch!.scoreHistory.add(scorePoint);
      // Persist the current server player index for doubles
      _currentMatch!.currentServerPlayerIndex = state.serverPlayerIndex;
    }

    // Check if match is complete
    if (_currentMatch!.hasWinner) {
      _currentMatch!.isMatchComplete = true;
      _currentMatch!.endTime = DateTime.now();
    }

    notifyListeners();
    _saveMatch();
  }

// Helper class for doubles serve state


  /// Toggle score summary panel visibility
  void toggleScoreSummary() {
    _showScoreSummary = !_showScoreSummary;
    notifyListeners();
  }

  /// End the current match
  void endMatch() {
    if (_currentMatch != null) {
      _currentMatch!.isMatchComplete = true;
      _currentMatch!.endTime = DateTime.now();
      notifyListeners();
      _saveMatch();
    }
  }

  /// Reset and start a new match
  void resetMatch() {
    _currentMatch = null;
    _showScoreSummary = false;
    notifyListeners();
    _storageService.clearMatch();
  }

  /// Load saved match from storage
  Future<void> loadSavedMatch() async {
    try {
      final savedMatch = await _storageService.loadMatch();
      if (savedMatch != null && !savedMatch.isMatchComplete) {
        _currentMatch = savedMatch;
        // After restoring doublesServeState, also set state.serverPlayerIndex = _currentMatch!.currentServerPlayerIndex;
        if (_currentMatch!.matchType == MatchType.doubles) {
          _currentMatch!.doublesServeState = DoublesServeState();
          final state = _currentMatch!.doublesServeState!;
          state.isFirstServe = true;
          for (final point in _currentMatch!.scoreHistory) {
            // At the start of the game, only server 2 serves
            if (state.isFirstServe) {
              state.isFirstServe = false;
              state.serverNumber = 2;
              state.serverPlayerIndex = 1;
            }
            if (point.servingTeam == point.winningTeam) {
              // Switch sides for both players
              state.switchSides(point.servingTeam);
              // Same server continues
            } else {
              // If first server, go to second server
              if (state.serverNumber == 1) {
                state.serverNumber = 2;
                state.serverPlayerIndex = 1;
              } else {
                // Side-out: switch to other team, server 1
                state.serverNumber = 1;
                state.serverPlayerIndex = 0;
              }
            }
          }
          state.serverPlayerIndex = _currentMatch!.currentServerPlayerIndex ?? 0;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved match: $e');
    }
  }

  /// Save current match to storage
  void _saveMatch() {
    if (_currentMatch != null) {
      _storageService.saveMatch(_currentMatch!);
    }
  }

  /// Get match statistics
  Map<String, dynamic> getMatchStats() {
    if (_currentMatch == null) return {};

    final totalRallies = _currentMatch!.scoreHistory.length;
    final teamAWins = _currentMatch!.scoreHistory
        .where((point) => point.winningTeam == ServingTeam.teamA)
        .length;
    final teamBWins = _currentMatch!.scoreHistory
        .where((point) => point.winningTeam == ServingTeam.teamB)
        .length;
    
    final teamAPointsWon = _currentMatch!.scoreHistory
        .where((point) => point.winningTeam == ServingTeam.teamA && point.pointAwarded)
        .length;
    final teamBPointsWon = _currentMatch!.scoreHistory
        .where((point) => point.winningTeam == ServingTeam.teamB && point.pointAwarded)
        .length;

    // Count duce periods (every time the match returns to a tied duce state, e.g., 10-10, 11-11, etc.)
    int ducePeriods = 0;
    final duceThreshold = _currentMatch!.targetScore - 1;
    int? lastDuceScore;
    for (final point in _currentMatch!.scoreHistory) {
      if (point.teamAScore == point.teamBScore && point.teamAScore >= duceThreshold) {
        if (lastDuceScore == null || point.teamAScore != lastDuceScore) {
          ducePeriods++;
          lastDuceScore = point.teamAScore;
        }
      }
    }

    return {
      'totalRallies': totalRallies,
      'teamAWins': teamAWins,
      'teamBWins': teamBWins,
      'teamAPointsWon': teamAPointsWon,
      'teamBPointsWon': teamBPointsWon,
      'teamAWinPercentage': totalRallies > 0 ? (teamAWins / totalRallies * 100).round() : 0,
      'teamBWinPercentage': totalRallies > 0 ? (teamBWins / totalRallies * 100).round() : 0,
      'matchDuration': _currentMatch!.matchDuration,
      'ducePeriods': ducePeriods,
      'isCurrentlyDuce': _currentMatch!.isDuce,
      'duceMessage': _currentMatch!.duceMessage,
    };
  }

  /// Undo last point (for corrections)
  void undoLastPoint() {
    if (_currentMatch == null || _currentMatch!.scoreHistory.isEmpty) return;

    final lastPoint = _currentMatch!.scoreHistory.removeLast();

    // Restore previous score
    if (lastPoint.pointAwarded) {
      if (lastPoint.winningTeam == ServingTeam.teamA) {
        _currentMatch!.teamAScore--;
      } else {
        _currentMatch!.teamBScore--;
      }
    }

    // Restore previous serving team
    if (_currentMatch!.scoreHistory.isNotEmpty) {
      if (!lastPoint.pointAwarded && lastPoint.servingTeam != lastPoint.winningTeam) {
        // If last point was a serve change, restore previous serving team
        _currentMatch!.currentServingTeam = lastPoint.servingTeam;
      }
    } else {
      // If this was the first point, restore initial serving team
      _currentMatch!.currentServingTeam = _currentMatch!.firstServingTeam;
    }

    // Restore doubles serve state by replaying history
    if (_currentMatch!.matchType == MatchType.doubles) {
      _currentMatch!.doublesServeState = DoublesServeState();
      final state = _currentMatch!.doublesServeState!;
      state.isFirstServe = true;
      for (final point in _currentMatch!.scoreHistory) {
        // At the start of the game, only server 2 serves
        if (state.isFirstServe) {
          state.isFirstServe = false;
          state.serverNumber = 2;
          state.serverPlayerIndex = 1;
        }
        if (point.servingTeam == point.winningTeam) {
          // Switch sides for both players
          state.switchSides(point.servingTeam);
          // Same server continues
        } else {
          // If first server, go to second server
          if (state.serverNumber == 1) {
            state.serverNumber = 2;
            state.serverPlayerIndex = 1;
          } else {
            // Side-out: switch to other team, server 1
            state.serverNumber = 1;
            state.serverPlayerIndex = 0;
          }
        }
      }
      state.serverPlayerIndex = _currentMatch!.currentServerPlayerIndex ?? 0;
    }

    // Reset match completion status if necessary
    if (_currentMatch!.isMatchComplete) {
      _currentMatch!.isMatchComplete = false;
      _currentMatch!.endTime = null;
    }

    notifyListeners();
    _saveMatch();
  }
}
