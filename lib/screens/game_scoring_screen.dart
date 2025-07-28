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
  late AnimationController _serveController;
  late AnimationController _slideController;
  
  late Animation<double> _serveAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {    
    _serveController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );

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
    _serveController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _awardPoint(ServingTeam team) {
    context.read<MatchProvider>().awardPoint(team);
    
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
          // Rally counter below action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13.0),
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 70,
                  maxWidth: MediaQuery.of(context).size.width * 0.45,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.038,
                  vertical: MediaQuery.of(context).size.height * 0.014,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB39DDB), // Light violet
                      AppTheme.buttonViolet, // Main violet
                      Color(0xFF4527A0), // Deep violet
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.buttonViolet, width: 2.2),
                  boxShadow: AppTheme.metallicShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_tennis, color: Colors.white, size: 18),
                    const SizedBox(width: 7),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${match.scoreHistory.length} Rallies',
                        style: AppTheme.titleStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.036,
                          color: Colors.white,
                          letterSpacing: 1.08,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildHeader(Match match) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BlinkingRedDot(size: screenWidth * 0.032, margin: EdgeInsets.only(right: screenWidth * 0.032)),
              Text(
                'LIVE MATCH',
                style: AppTheme.titleStyle.copyWith(
                  fontSize: screenWidth * 0.052, // Slightly smaller, responsive
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Show duce status or target score
          if (match.isDuce)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentGold, AppTheme.accentGold.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  match.duceMessage ?? 'Match Duce',
                  style: AppTheme.titleStyle.copyWith(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Text(
              'First to ${match.targetScore}',
              style: AppTheme.captionStyle.copyWith(
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
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
              match.teamAName, // Use team name instead of display name
              match.teamAScore,
              match.currentServingTeam == ServingTeam.teamA,
              AppTheme.primaryEmerald,
              ServingTeam.teamA,
            ),
          ),
          
          
          // Team B side
          Expanded(
            child: _buildTeamSide(
              match.teamBName, // Use team name instead of display name
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
    return LayoutBuilder(
      builder: (context, constraints) {
  // Responsive sizing
  final double maxCircle = (constraints.maxHeight * 0.48).clamp(64.0, 130.0);
  final double fontSize = (maxCircle * 0.45).clamp(24.0, 52.0);
  final double vSpace = constraints.maxHeight < 300 ? 10 : 18;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 180 ? 8 : 16,
            vertical: vSpace,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Team name inside squared colored container with padding
              Container(
                width: maxCircle * 1.25,
                height: maxCircle * 0.34,
                padding: EdgeInsets.symmetric(
                  horizontal: maxCircle * 0.13,
                  vertical: maxCircle * 0.04,
                ),
                decoration: BoxDecoration(
                  color: teamColor,
                  borderRadius: BorderRadius.circular(maxCircle * 0.10),
                  boxShadow: [
                    BoxShadow(
                      color: teamColor.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    teamName,
                    style: AppTheme.titleStyle.copyWith(
                      fontSize: fontSize * 0.38,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: vSpace),
              // Score with smooth fade animation
              AnimatedSwitcher(
                duration: AppTheme.normalAnimation,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Container(
                  key: ValueKey<int>(score),
                  width: maxCircle,
                  height: maxCircle,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        teamColor,
                        teamColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        score.toString(),
                        style: AppTheme.scoreStyle.copyWith(
                          fontSize: fontSize,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: vSpace),
              // Serving indicator
              AnimatedBuilder(
                animation: _serveAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: isServing ? 0.3 + (_serveAnimation.value * 0.7) : 0.2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 180 ? 10 : 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isServing ? teamColor : AppTheme.textSecondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_tennis,
                            size: 22,
                            color: AppTheme.textPrimary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isServing ? 'SERVING' : 'WAITING',
                            style: AppTheme.captionStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
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
          // ...removed 'TAP TO AWARD POINT' text...
          const SizedBox(height: 20),
          Row(
            children: [
              // Team A button
              Expanded(
                child: ScoreButton(
                  onPressed: () => _awardPoint(ServingTeam.teamA),
                  teamName: match.teamAName, // Use team name instead of display name
                  color: AppTheme.primaryEmerald,
                  isEnabled: !match.isMatchComplete,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Team B button
              Expanded(
                child: ScoreButton(
                  onPressed: () => _awardPoint(ServingTeam.teamB),
                  teamName: match.teamBName, // Use team name instead of display name
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
                boxShadow: AppTheme.metallicShadow,
                gradient: AppTheme.buttonGradient,
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
        boxShadow: AppTheme.metallicShadow,
        gradient: provider.showScoreSummary ? AppTheme.selectedButtonGradient : AppTheme.buttonGradient,
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
                            ? AppTheme.textPrimary 
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

// Blinking red dot widget
class _BlinkingRedDot extends StatefulWidget {
  final double size;
  final EdgeInsets margin;
  const _BlinkingRedDot({required this.size, required this.margin});

  @override
  State<_BlinkingRedDot> createState() => _BlinkingRedDotState();
}

class _BlinkingRedDotState extends State<_BlinkingRedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 1.0, end: 0.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, child) => Opacity(
        opacity: _opacityAnim.value,
        child: Container(
          width: widget.size,
          height: widget.size,
          margin: widget.margin,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
