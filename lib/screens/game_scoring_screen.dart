import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/score_summary_panel.dart';
import 'end_game_summary_screen.dart';

/// Main game scoring screen with split layout and live scoring
class GameScoringScreen extends StatefulWidget {
  const GameScoringScreen({super.key});

  @override
  State<GameScoringScreen> createState() => _GameScoringScreenState();
}

class _GameScoringScreenState extends State<GameScoringScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _serveController;
  late AnimationController _slideController;
  
  late Animation<double> _scoreAnimation;
  late Animation<double> _serveAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scoreController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _serveController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: AppTheme.bouncyCurve,
    ));

    _serveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _serveController,
      curve: AppTheme.defaultCurve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.defaultCurve,
    ));

    _serveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _serveController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _awardPoint(ServingTeam team) {
    context.read<MatchProvider>().awardPoint(team);
    _animateScoreUpdate();
    
    // Check if match is complete
    final match = context.read<MatchProvider>().currentMatch;
    if (match != null && match.isMatchComplete) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const EndGameSummaryScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: AppTheme.normalAnimation,
            ),
          );
        }
      });
    }
  }

  void _animateScoreUpdate() {
    _scoreController.forward().then((_) {
      _scoreController.reverse();
    });
  }

  void _toggleScoreSummary() {
    final provider = context.read<MatchProvider>();
    provider.toggleScoreSummary();
    
    if (provider.showScoreSummary) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final match = matchProvider.currentMatch;
        if (match == null) {
          return const Scaffold(
            body: Center(
              child: Text('No active match'),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: Stack(
              children: [
                // Main scoring interface
                _buildMainScoringInterface(match),
                
                // Score summary panel
                if (matchProvider.showScoreSummary)
                  _buildScoreSummaryPanel(match),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainScoringInterface(Match match) {
    return SafeArea(
      child: Column(
        children: [
          // Header with match info
          _buildHeader(match),
          
          // Main scoring area
          Expanded(
            flex: 3,
            child: _buildScoringArea(match),
          ),
          
          // Action buttons
          Expanded(
            flex: 2,
            child: _buildActionButtons(match),
          ),
          
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildHeader(Match match) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'LIVE MATCH',
            style: AppTheme.titleStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'First to ${match.targetScore}',
            style: AppTheme.captionStyle,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.3, duration: 500.ms, curve: AppTheme.defaultCurve);
  }

  Widget _buildScoringArea(Match match) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Team A side
          Expanded(
            child: _buildTeamSide(
              match.teamADisplayName,
              match.teamAScore,
              match.currentServingTeam == ServingTeam.teamA,
              AppTheme.primaryRed,
              ServingTeam.teamA,
            ),
          ),
          
          // VS divider
          Container(
            width: 2,
            height: 200,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(1),
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .scale(begin: const Offset(1, 0), duration: 800.ms),
          
          // Team B side
          Expanded(
            child: _buildTeamSide(
              match.teamBDisplayName,
              match.teamBScore,
              match.currentServingTeam == ServingTeam.teamB,
              AppTheme.primaryBlue,
              ServingTeam.teamB,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSide(
    String teamName,
    int score,
    bool isServing,
    Color teamColor,
    ServingTeam team,
  ) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Team name
                Text(
                  teamName.toUpperCase(),
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: 16,
                    color: teamColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Score
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        teamColor,
                        teamColor.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: teamColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: AppTheme.scoreStyle.copyWith(
                        fontSize: 48,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Serving indicator
                AnimatedBuilder(
                  animation: _serveAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: isServing ? 0.3 + (_serveAnimation.value * 0.7) : 0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isServing ? teamColor : AppTheme.textSecondary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isServing
                              ? [
                                  BoxShadow(
                                    color: teamColor.withOpacity(0.4),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 16,
                              color: AppTheme.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isServing ? 'SERVING' : 'WAITING',
                              style: AppTheme.captionStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    )
        .animate()
        .fadeIn(delay: (team == ServingTeam.teamA ? 200 : 400).ms, duration: 600.ms)
        .slideX(
          begin: team == ServingTeam.teamA ? -0.5 : 0.5,
          duration: 600.ms,
          curve: AppTheme.defaultCurve,
        );
  }

  Widget _buildActionButtons(Match match) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'TAP TO AWARD POINT',
            style: AppTheme.captionStyle.copyWith(
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              // Team A button
              Expanded(
                child: ScoreButton(
                  onPressed: () => _awardPoint(ServingTeam.teamA),
                  teamName: match.teamADisplayName,
                  color: AppTheme.primaryRed,
                  isEnabled: !match.isMatchComplete,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Team B button
              Expanded(
                child: ScoreButton(
                  onPressed: () => _awardPoint(ServingTeam.teamB),
                  teamName: match.teamBDisplayName,
                  color: AppTheme.primaryBlue,
                  isEnabled: !match.isMatchComplete,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.5, duration: 600.ms, curve: AppTheme.defaultCurve);
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo button
          Consumer<MatchProvider>(
            builder: (context, provider, child) {
              final canUndo = provider.currentMatch?.scoreHistory.isNotEmpty ?? false;
              return AnimatedButton(
                onPressed: canUndo ? () => provider.undoLastPoint() : null,
                enabled: canUndo,
                backgroundColor: AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.undo, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'UNDO',
                      style: AppTheme.captionStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Score summary toggle
          Consumer<MatchProvider>(
            builder: (context, provider, child) {
              return AnimatedButton(
                onPressed: _toggleScoreSummary,
                backgroundColor: provider.showScoreSummary 
                    ? AppTheme.accentGold 
                    : AppTheme.surfaceColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.showScoreSummary 
                          ? Icons.visibility_off 
                          : Icons.summarize,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.showScoreSummary ? 'HIDE' : 'SUMMARY',
                      style: AppTheme.captionStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: provider.showScoreSummary 
                            ? AppTheme.darkBackground 
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 500.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: AppTheme.defaultCurve);
  }

  Widget _buildScoreSummaryPanel(Match match) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScoreSummaryPanel(match: match),
    );
  }
}
