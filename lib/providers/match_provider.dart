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

    final servingTeam = _currentMatch!.currentServingTeam;
    bool pointAwarded = false;

    // Pickleball scoring rules:
    // - Only the serving team can score points
    // - If serving team wins the rally, they get a point and continue serving
    // - If receiving team wins the rally, they get the serve but no point
    
    if (servingTeam == winningTeam) {
      // Serving team wins - they get a point and continue serving
      pointAwarded = true;
      if (winningTeam == ServingTeam.teamA) {
        _currentMatch!.teamAScore++;
      } else {
        _currentMatch!.teamBScore++;
      }
    } else {
      // Receiving team wins - serve switches but no point awarded
      _currentMatch!.currentServingTeam = winningTeam;
    }

    // Add to score history
    final scorePoint = ScorePoint(
      turnNumber: _currentMatch!.scoreHistory.length + 1,
      servingTeam: servingTeam,
      winningTeam: winningTeam,
      pointAwarded: pointAwarded,
      teamAScore: _currentMatch!.teamAScore,
      teamBScore: _currentMatch!.teamBScore,
      timestamp: DateTime.now(),
    );

    _currentMatch!.scoreHistory.add(scorePoint);

    // Check if match is complete
    if (_currentMatch!.hasWinner) {
      _currentMatch!.isMatchComplete = true;
      _currentMatch!.endTime = DateTime.now();
    }

    notifyListeners();
    _saveMatch();
  }

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

    return {
      'totalRallies': totalRallies,
      'teamAWins': teamAWins,
      'teamBWins': teamBWins,
      'teamAPointsWon': teamAPointsWon,
      'teamBPointsWon': teamBPointsWon,
      'teamAWinPercentage': totalRallies > 0 ? (teamAWins / totalRallies * 100).round() : 0,
      'teamBWinPercentage': totalRallies > 0 ? (teamBWins / totalRallies * 100).round() : 0,
      'matchDuration': _currentMatch!.matchDuration,
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

    // Reset match completion status if necessary
    if (_currentMatch!.isMatchComplete) {
      _currentMatch!.isMatchComplete = false;
      _currentMatch!.endTime = null;
    }

    notifyListeners();
    _saveMatch();
  }
}
