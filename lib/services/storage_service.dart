import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

/// Service for persisting match data locally
class StorageService {
  static const String _matchKey = 'current_match';
  static const String _matchHistoryKey = 'match_history';

  /// Save current match to local storage
  Future<void> saveMatch(Match match) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchJson = jsonEncode(match.toJson());
      await prefs.setString(_matchKey, matchJson);
    } catch (e) {
      throw Exception('Failed to save match: $e');
    }
  }

  /// Load current match from local storage
  Future<Match?> loadMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchJson = prefs.getString(_matchKey);
      
      if (matchJson != null) {
        final matchData = jsonDecode(matchJson) as Map<String, dynamic>;
        return Match.fromJson(matchData);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to load match: $e');
    }
  }

  /// Clear current match from storage
  Future<void> clearMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_matchKey);
    } catch (e) {
      throw Exception('Failed to clear match: $e');
    }
  }

  /// Save completed match to history
  Future<void> saveMatchToHistory(Match match) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_matchHistoryKey);
      
      List<Map<String, dynamic>> history = [];
      if (historyJson != null) {
        final historyData = jsonDecode(historyJson) as List;
        history = historyData.cast<Map<String, dynamic>>();
      }
      
      history.add(match.toJson());
      
      // Keep only last 50 matches
      if (history.length > 50) {
        history = history.sublist(history.length - 50);
      }
      
      await prefs.setString(_matchHistoryKey, jsonEncode(history));
    } catch (e) {
      throw Exception('Failed to save match to history: $e');
    }
  }

  /// Load match history
  Future<List<Match>> loadMatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_matchHistoryKey);
      
      if (historyJson != null) {
        final historyData = jsonDecode(historyJson) as List;
        return historyData
            .cast<Map<String, dynamic>>()
            .map((json) => Match.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load match history: $e');
    }
  }

  /// Clear all match history
  Future<void> clearMatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_matchHistoryKey);
    } catch (e) {
      throw Exception('Failed to clear match history: $e');
    }
  }

  /// Get app preferences
  Future<Map<String, dynamic>> getAppPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'defaultTargetScore': prefs.getInt('default_target_score') ?? 11,
        'soundEnabled': prefs.getBool('sound_enabled') ?? true,
        'vibrationEnabled': prefs.getBool('vibration_enabled') ?? true,
        'keepScreenOn': prefs.getBool('keep_screen_on') ?? true,
      };
    } catch (e) {
      throw Exception('Failed to get app preferences: $e');
    }
  }

  /// Save app preferences
  Future<void> saveAppPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('default_target_score', preferences['defaultTargetScore']);
      await prefs.setBool('sound_enabled', preferences['soundEnabled']);
      await prefs.setBool('vibration_enabled', preferences['vibrationEnabled']);
      await prefs.setBool('keep_screen_on', preferences['keepScreenOn']);
    } catch (e) {
      throw Exception('Failed to save app preferences: $e');
    }
  }
}
