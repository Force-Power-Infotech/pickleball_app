import '../services/pdf_export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

import '../theme/app_theme.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/animated_button.dart';
import 'match_setup_screen.dart';

/// Helper function to check if the match was in duce state at a given point
bool isDuceAtPoint(ScorePoint point, Match match) {
  final duceThreshold = match.targetScore - 1; // 10 for 11-point, 17 for 18-point, 20 for 21-point
  
  // Both teams must be at or above duce threshold
  if (point.teamAScore < duceThreshold || point.teamBScore < duceThreshold) {
    return false;
  }
  
  // Duce indicator only shows when scores are tied (active duce state)
  // Examples: 10-10, 11-11, 17-17, 20-20
  return point.teamAScore == point.teamBScore;
}

// Helper class for timeline items
class TimelineItem {
  final bool isDuce;
  final ScorePoint? point;
  final int? pointNumber;
  final int? score;
  
  TimelineItem.duce(this.score) : isDuce = true, point = null, pointNumber = null;
  TimelineItem.point(this.point, this.pointNumber) : isDuce = false, score = null;
}

/// Screen displayed when match ends with winner celebration and stats
class EndGameSummaryScreen extends StatefulWidget {
  const EndGameSummaryScreen({super.key});

  @override
  State<EndGameSummaryScreen> createState() => _EndGameSummaryScreenState();
}

class _EndGameSummaryScreenState extends State<EndGameSummaryScreen>
    with TickerProviderStateMixin {
  late final AudioPlayer _winnerAudioPlayer;
  late AnimationController _slideController;
  late AnimationController _statsController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsAnimation;
  bool _showFireworks = true;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _winnerAudioPlayer = AudioPlayer();
    _playWinnerSound();
    _confettiController.play();
    // Wait for confetti to finish, then wait 1s more before hiding widget for smooth fade-out
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _confettiController.stop();
        _winnerAudioPlayer.stop();
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _showFireworks = false);
        });
      }
    });
  }

  Future<void> _playWinnerSound() async {
    try {
      await _winnerAudioPlayer.stop();
      await _winnerAudioPlayer.play(AssetSource('winner.mp3'), volume: 1.0);
      // Optionally, stop after 5 seconds to match confetti
      Future.delayed(const Duration(seconds: 5), () {
        _winnerAudioPlayer.stop();
      });
    } catch (_) {}
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _statsController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.defaultCurve,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: AppTheme.defaultCurve,
    ));
  }

  void _startAnimations() {
    // Start animations immediately
    _slideController.forward();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _statsController.dispose();
    _confettiController.dispose();
    _winnerAudioPlayer.dispose();
    super.dispose();
  }

  void _startNewMatch() {
    context.read<MatchProvider>().resetMatch();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MatchSetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  void _showPointAnalysis() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PointAnalysisScreen(
          match: context.read<MatchProvider>().currentMatch!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppTheme.defaultCurve,
            )),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  void _showScorecard() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ScorecardScreen(
          match: context.read<MatchProvider>().currentMatch!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppTheme.defaultCurve,
            )),
            child: child,
          );
        },
        transitionDuration: AppTheme.normalAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final match = matchProvider.currentMatch;
        if (match == null || !match.isMatchComplete) {
          return const Scaffold(
            body: Center(
              child: Text('No completed match found'),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Winner celebration - always fits
                        _buildWinnerCelebration(match),
                        const SizedBox(height: 20),
                        // Match summary - responsive
                        _buildMatchSummary(match),
                        const SizedBox(height: 60),
                        // Action buttons - responsive
                        _buildActionButtons(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              if (_showFireworks)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      emissionFrequency: 0.12,
                      numberOfParticles: 30,
                      maxBlastForce: 30,
                      minBlastForce: 10,
                      gravity: 0.2,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Celebration background removed for cleaner UI

  String _getWinnerDisplayName(Match match, ServingTeam? winner) {
    if (winner == null) return 'No Winner';
    
    // For both singles and doubles, use team names
    return winner == ServingTeam.teamA ? match.teamAName : match.teamBName;
  }

  Widget _buildWinnerCelebration(Match match) {
    final winner = match.winner;
    
    // Get the winning team name
    final winnerName = _getWinnerDisplayName(match, winner);
    
    final winnerColor = winner == ServingTeam.teamA 
        ? AppTheme.primaryEmerald 
        : AppTheme.primaryBlue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon - responsive
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGold,
                  AppTheme.accentGold.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 48,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Winner announcement
          Text(
            'WINNER!',
            style: AppTheme.headlineStyle.copyWith(
              fontSize: 32,
              color: AppTheme.accentGold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Winner name - fully responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final maxWidth = constraints.maxWidth;
              
              // Calculate responsive font size based on screen width
              double fontSize = screenWidth < 320 ? 18 : // Very small screens
                               screenWidth < 360 ? 20 : // Small screens 
                               screenWidth < 400 ? 22 : // Medium screens
                               24; // Large screens
              
              // Adjust for very long names in doubles mode
              final isDoublesWithLongNames = match.matchType == MatchType.doubles && 
                                            winnerName.length > 15;
              if (isDoublesWithLongNames) {
                fontSize = fontSize * 0.9; // Reduce font size for long names
              }
              
              return Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    winnerName,
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: fontSize,
                      color: winnerColor,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Final score
          Text(
            'Final Score: ${match.scoreDisplay}',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildMatchSummary(Match match) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: AppTheme.cardRadius,
          boxShadow: AppTheme.metallicShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MATCH SUMMARY',
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
            ),
            
            const SizedBox(height: 16),
            
            // Match stats in compact layout
            _buildMatchStats(match),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchStats(Match match) {
    // Calculate percentages based on final points (not serves or rallies)
    final int teamAScore = match.teamAScore;
    final int teamBScore = match.teamBScore;
    final int totalPoints = teamAScore + teamBScore;
    double teamAPercentage = 0;
    double teamBPercentage = 0;
    if (totalPoints > 0) {
      teamAPercentage = (teamAScore / totalPoints) * 100;
      teamBPercentage = (teamBScore / totalPoints) * 100;
    }

    final stats = context.read<MatchProvider>().getMatchStats();

    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _statsAnimation.value,
          child: Column(
            children: [
              // Top row - Duration and Rallies
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Duration',
                      _formatDuration(match.matchDuration),
                      Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Rallies',
                      stats['totalRallies'].toString(),
                      Icons.sports_tennis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row - Team points (actual points scored, percentage based on final points)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      _truncateName(match.teamAName),
                      '$teamAScore points (${teamAPercentage.toStringAsFixed(0)}%)',
                      Icons.trending_up,
                      color: AppTheme.primaryEmerald,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      _truncateName(match.teamBName),
                      '$teamBScore points (${teamBPercentage.toStringAsFixed(0)}%)',
                      Icons.trending_up,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Third row - Deuce and Final Score
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Deuce Periods',
                      stats['ducePeriods'].toString(),
                      Icons.balance,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Final Score',
                      '${match.teamAScore} - ${match.teamBScore}',
                      Icons.scoreboard,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? AppTheme.textSecondary).withOpacity(0.3),
        ),
        boxShadow: AppTheme.metallicShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? AppTheme.textSecondary,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTheme.captionStyle.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color ?? AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateName(String name) {
    if (name.length <= 10) return name;
    return '${name.substring(0, 10)}...';
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Point Analysis Button
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: _showPointAnalysis,
            backgroundColor: AppTheme.primaryBlue,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'POINT ANALYSIS',
                    style: AppTheme.buttonStyle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Scorecard Button
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: _showScorecard,
            backgroundColor: AppTheme.neonGreen,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.scoreboard,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SCORECARD',
                    style: AppTheme.buttonStyle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // New Match Button
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: _startNewMatch,
            backgroundColor: AppTheme.buttonViolet,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NEW MATCH',
                    style: AppTheme.buttonStyle.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate(delay: 1500.ms)
        .slideY(begin: 0.5, duration: 600.ms, curve: AppTheme.defaultCurve)
        .fadeIn(duration: 500.ms);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

/// Full-screen point analysis screen
class PointAnalysisScreen extends StatelessWidget {
  final Match match;

  const PointAnalysisScreen({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'POINT BY POINT ANALYSIS',
                        style: AppTheme.titleStyle.copyWith(fontSize: 18),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Match summary header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTeamSummary(
                        match.teamAName,
                        match.teamAScore,
                        AppTheme.primaryEmerald,
                        match.winner == ServingTeam.teamA,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'FINAL',
                              style: AppTheme.captionStyle.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildTeamSummary(
                        match.teamBName,
                        match.teamBScore,
                        AppTheme.primaryBlue,
                        match.winner == ServingTeam.teamB,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Timeline list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timeline,
                              color: AppTheme.accentGold,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Match Timeline',
                              style: AppTheme.bodyStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentGold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${match.scoreHistory.length} Rallies',
                                style: AppTheme.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: match.scoreHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports_tennis,
                                      size: 64,
                                      color: AppTheme.textSecondary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No scoring history available',
                                      style: AppTheme.bodyStyle.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: _getTimelineItemCount(match),
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildTimelineItemAtIndex(match, index)
                                      .animate(delay: (index * 50).ms)
                                      .slideX(begin: 0.3, duration: 400.ms, curve: AppTheme.defaultCurve)
                                      .fadeIn();
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for timeline with duce cards
  int _getTimelineItemCount(Match match) {
    final timelineItems = _buildTimelineData(match);
    return timelineItems.length;
  }

  List<TimelineItem> _buildTimelineData(Match match) {
    // Use the actual scoreHistory for all timeline/analysis (doubles logic is already correct)
    final timelineItems = <TimelineItem>[];
    final duceThreshold = match.targetScore - 1;
    final seenDuceScores = <String>{};
    for (int i = 0; i < match.scoreHistory.length; i++) {
      final point = match.scoreHistory[i];
      // Check if this point created a duce condition
      if (point.teamAScore >= duceThreshold && 
          point.teamBScore >= duceThreshold && 
          point.teamAScore == point.teamBScore) {
        final duceKey = '${point.teamAScore}-${point.teamBScore}';
        if (!seenDuceScores.contains(duceKey)) {
          timelineItems.add(TimelineItem.duce(point.teamAScore));
          seenDuceScores.add(duceKey);
        }
      }
      timelineItems.add(TimelineItem.point(point, i + 1));
    }
    return timelineItems;
  }

  Widget _buildTimelineItemAtIndex(Match match, int index) {
    final timelineItems = _buildTimelineData(match);
    
    if (index >= timelineItems.length) {
      return const SizedBox.shrink();
    }
    
    final item = timelineItems[index];
    
    if (item.isDuce) {
      return _buildDuceCard(item.score!);
    } else {
      return _buildTimelineItem(item.point!, match, item.pointNumber!);
    }
  }

  Widget _buildDuceCard(int score) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentGold, AppTheme.accentGold.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Match Deuce $score all',
          style: AppTheme.titleStyle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTeamSummary(String teamName, int score, Color teamColor, bool isWinner) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Responsive height container for winner badge to ensure visibility on all devices
        SizedBox(
          height: 32, // Increased height for better visibility on all mobile screens
          child: isWinner
              ? Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'WINNER',
                      style: AppTheme.captionStyle.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                )
              : null, // Empty space when not winner
        ),
        
        const SizedBox(height: 4), // Reduced spacing to accommodate larger winner badge
        
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            teamName,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isWinner ? AppTheme.accentGold : teamColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                teamColor,
                teamColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: AppTheme.headlineStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(ScorePoint point, Match match, int pointNumber) {
    final winningTeamName = point.winningTeam == ServingTeam.teamA 
        ? match.teamAName 
        : match.teamBName;
    final winningTeamColor = point.winningTeam == ServingTeam.teamA 
        ? AppTheme.primaryEmerald 
        : AppTheme.primaryBlue;
    final isDoubles = match.matchType == MatchType.doubles;
    String? serverName;
    if (isDoubles) {
  // Always show as Server 1 and Server 2 for doubles
  if (point.serverPlayerIndex == 0) serverName = 'Server 1';
  if (point.serverPlayerIndex == 1) serverName = 'Server 2';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: winningTeamColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Point number circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  winningTeamColor,
                  winningTeamColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Text(
                pointNumber.toString(),
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Point details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      point.pointAwarded ? Icons.sports_score : Icons.sports_tennis,
                      size: 16,
                      color: winningTeamColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$winningTeamName ${point.pointAwarded ? "scores point" : "wins rally"}',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Score: ',
                      style: AppTheme.captionStyle.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${point.teamAScore} - ${point.teamBScore}',
                      style: AppTheme.captionStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.sports_volleyball,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: isDoubles
                            ? Text(
                                'Serving: '
                                '${serverName ?? (point.servingTeam == ServingTeam.teamA ? match.teamAName : match.teamBName)}'
                                ' (${point.servingTeam == ServingTeam.teamA ? match.teamAName : match.teamBName})',
                                style: AppTheme.captionStyle.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                'Serving: ${point.servingTeam == ServingTeam.teamA ? match.teamAName : match.teamBName}',
                                style: AppTheme.captionStyle.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen scorecard screen with rally-by-rally breakdown
class ScorecardScreen extends StatelessWidget {
  final Match match;

  const ScorecardScreen({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.primaryEmerald,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SCORECARD',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 28,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Rally by Rally Analysis',
                          style: AppTheme.captionStyle.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _downloadScorecard(context),
                    icon: const Icon(
                      Icons.share,
                      color: AppTheme.primaryEmerald,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _buildScorecardTable(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for scorecard cell content (doubles: W•/W••/L•/L••, singles: W/L/W•/L•)
  String _getScorecardCellContent(ScorePoint point, bool isTeamA, Match match) {
    if (match.matchType == MatchType.doubles) {
      bool isTeamAServing = point.servingTeam == ServingTeam.teamA;
      bool isTeamBServing = point.servingTeam == ServingTeam.teamB;
      bool isTeamAWon = point.winningTeam == ServingTeam.teamA;
      bool isTeamBWon = point.winningTeam == ServingTeam.teamB;
      int? serverNumber;
      if (isTeamAServing && point.serverPlayerIndex != null && isTeamA) {
        serverNumber = point.serverPlayerIndex! + 1;
      } else if (isTeamBServing && point.serverPlayerIndex != null && !isTeamA) {
        serverNumber = point.serverPlayerIndex! + 1;
      }
      if ((isTeamA && isTeamAServing) || (!isTeamA && isTeamBServing)) {
        String prefix = (isTeamA && isTeamAWon) || (!isTeamA && isTeamBWon) ? 'W' : 'L';
        if (serverNumber == 1) {
          return '$prefix•';
        } else if (serverNumber == 2) {
          return '$prefix••';
        }
      }
      return (isTeamA ? (isTeamAWon ? 'W' : 'L') : (isTeamBWon ? 'W' : 'L'));
    } else {
      String winLoss = isTeamA
          ? (point.winningTeam == ServingTeam.teamA ? 'W' : 'L')
          : (point.winningTeam == ServingTeam.teamB ? 'W' : 'L');
      bool isServing = (isTeamA && point.servingTeam == ServingTeam.teamA) ||
          (!isTeamA && point.servingTeam == ServingTeam.teamB);
      if (isServing) {
        return winLoss + '•';
      }
      return winLoss;
    }
  }

  Widget _buildScorecardTable(BuildContext context) {
    final scoreHistory = match.scoreHistory;
    List<String> playerNamesA = [];
    List<String> playerNamesB = [];
    
    // Get player names based on match type
    if (match.matchType == MatchType.doubles) {
      // For doubles, combine both players into one column per team
      String teamANames = '';
      String teamBNames = '';
      
      if (match.teamAPlayer1 != null && match.teamAPlayer2 != null) {
        teamANames = '${match.teamAPlayer1!} & ${match.teamAPlayer2!}';
      } else if (match.teamAPlayer1 != null) {
        teamANames = match.teamAPlayer1!;
      } else {
        teamANames = match.teamAName;
      }
      
      if (match.teamBPlayer1 != null && match.teamBPlayer2 != null) {
        teamBNames = '${match.teamBPlayer1!} & ${match.teamBPlayer2!}';
      } else if (match.teamBPlayer1 != null) {
        teamBNames = match.teamBPlayer1!;
      } else {
        teamBNames = match.teamBName;
      }
      
      playerNamesA.add(teamANames);
      playerNamesB.add(teamBNames);
    } else {
      // For singles, use player names or team names as fallback
      playerNamesA.add(match.teamAPlayer1 ?? match.teamAName);
      playerNamesB.add(match.teamBPlayer1 ?? match.teamBName);
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'PICKLEBALL SCORECARD',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${match.matchType.displayName} • Final: ${match.teamAScore}-${match.teamBScore}',
                  style: AppTheme.captionStyle.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Responsive Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columnSpacing: MediaQuery.of(context).size.width * 0.04,
                horizontalMargin: 0,
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                headingRowHeight: 56,
                dataRowHeight: 48,
                columns: [
                  const DataColumn(
                    label: Expanded(
                      child: Text(
                        'Rally',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ...playerNamesA.map(
                    (name) => DataColumn(
                      label: Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryEmerald,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...playerNamesB.map(
                    (name) => DataColumn(
                      label: Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryBlue,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: List.generate(scoreHistory.length, (index) {
                  final point = scoreHistory[index];
                  return DataRow(
                    color: MaterialStateProperty.all(
                      index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    ),
                    cells: [
                      DataCell(
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      ...playerNamesA.map(
                        (name) => DataCell(
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isDuceAtPoint(point, match)) ...[
                                  Container(
                                    width: 18,
                                    height: 18,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'D',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                Builder(
                                  builder: (context) {
                                    final cellContent = _getScorecardCellContent(point, true, match);
                                    final isWin = cellContent.startsWith('W');
                                    // Render W•/W••/L•/L•• with larger dot(s)
                                    String mainChar = cellContent.replaceAll('•', '');
                                    int dotCount = cellContent.split('•').length - 1;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isWin ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isWin ? Colors.green.shade300 : Colors.red.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            mainChar,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: isWin ? Colors.green.shade800 : Colors.red.shade800,
                                            ),
                                          ),
                                          if (dotCount > 0) ...List.generate(dotCount, (i) => Padding(
                                            padding: const EdgeInsets.only(left: 2, right: 1),
                                            child: Container(
                                              width: 10, // Increased dot size
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: isWin ? Colors.green.shade800 : Colors.red.shade800,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (point.servingTeam == ServingTeam.teamA && point.winningTeam == ServingTeam.teamA) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${point.teamAScore}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      ...playerNamesB.map(
                        (name) => DataCell(
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isDuceAtPoint(point, match)) ...[
                                  Container(
                                    width: 18,
                                    height: 18,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.yellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'D',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                Builder(
                                  builder: (context) {
                                    final cellContent = _getScorecardCellContent(point, false, match);
                                    final isWin = cellContent.startsWith('W');
                                    String mainChar = cellContent.replaceAll('•', '');
                                    int dotCount = cellContent.split('•').length - 1;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isWin ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isWin ? Colors.green.shade300 : Colors.red.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            mainChar,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: isWin ? Colors.green.shade800 : Colors.red.shade800,
                                            ),
                                          ),
                                          if (dotCount > 0) ...List.generate(dotCount, (i) => Padding(
                                            padding: const EdgeInsets.only(left: 2, right: 1),
                                            child: Container(
                                              width: 10, // Increased dot size
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: isWin ? Colors.green.shade800 : Colors.red.shade800,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                if (point.servingTeam == ServingTeam.teamB && point.winningTeam == ServingTeam.teamB) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${point.teamBScore}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          
          // Legend
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        'W',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Won Rally',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        'L',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lost Rally',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                // Singles-specific legend
                if (match.matchType == MatchType.singles) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'W',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Serving & won',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'L',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.red.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Serving & lost',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                // Doubles-specific legend
                if (match.matchType == MatchType.doubles) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'W',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Server 1 serving & won',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'W',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Server 2 serving & won',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'L',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.red.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Server 1 serving & lost',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'L',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.red.shade800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 1),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade800,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Server 2 serving & lost',
                        style: AppTheme.captionStyle.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
                // End doubles legend
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Score',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'D',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Deuce',
                      style: AppTheme.captionStyle.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _downloadScorecard(BuildContext context) {
  final match = context.read<MatchProvider>().currentMatch;
  if (match == null) return;
  PdfExportService.exportScorecard(match);
  }
}