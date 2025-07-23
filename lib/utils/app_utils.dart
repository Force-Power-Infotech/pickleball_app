/// Utility functions and helpers for the Pickleball app
library pickleball_utils;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Constants used throughout the app
class AppConstants {
  static const String appName = 'Pickleball Scorer';
  static const String appVersion = '1.0.0';
  
  // Default match settings
  static const int defaultTargetScore = 11;
  static const List<int> availableTargetScores = [11, 15, 21];
  
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Haptic feedback patterns
  static void lightHaptic() => HapticFeedback.lightImpact();
  static void mediumHaptic() => HapticFeedback.mediumImpact();
  static void heavyHaptic() => HapticFeedback.heavyImpact();
}

/// Extension methods for common operations
extension StringExtensions on String {
  /// Capitalize first letter of each word
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isEmpty 
            ? word 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    return length <= maxLength ? this : '${substring(0, maxLength)}...';
  }
}

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Format as time string (HH:mm)
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// Format as date string (MMM dd, yyyy)
  String toDateString() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month - 1]} ${day.toString().padLeft(2, '0')}, $year';
  }
}

/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format duration as MM:SS
  String toTimerString() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Utility class for responsive design
class ResponsiveUtils {
  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > 600;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return isTablet(context) 
        ? const EdgeInsets.all(32)
        : const EdgeInsets.all(20);
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base width (iPhone)
    return baseSize * scaleFactor.clamp(0.8, 1.2);
  }
}

/// Utility class for validation
class ValidationUtils {
  /// Validate team name
  static String? validateTeamName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Team name cannot be empty';
    }
    if (value.trim().length > 20) {
      return 'Team name must be 20 characters or less';
    }
    return null;
  }
  
  /// Check if two team names are different
  static String? validateDifferentTeamNames(String? teamA, String? teamB) {
    if (teamA != null && teamB != null && teamA.trim() == teamB.trim()) {
      return 'Team names must be different';
    }
    return null;
  }
}

/// Utility class for sound and haptic feedback
class FeedbackUtils {
  static bool _hapticEnabled = true;
  
  /// Enable/disable haptic feedback
  static void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }
  
  /// Play point scored feedback
  static void pointScored() {
    if (_hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    // TODO: Add sound effect when audio is implemented
  }
  
  /// Play serve change feedback
  static void serveChange() {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    // TODO: Add sound effect when audio is implemented
  }
  
  /// Play match won feedback
  static void matchWon() {
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
    // TODO: Add sound effect when audio is implemented
  }
  
  /// Play button tap feedback
  static void buttonTap() {
    if (_hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }
}
