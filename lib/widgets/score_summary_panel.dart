import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../models/match.dart';

/// Panel showing live score summary and match timeline
class ScoreSummaryPanel extends StatefulWidget {
  final Match match;

  const ScoreSummaryPanel({
    super.key,
    required this.match,
  });

  @override
  State<ScoreSummaryPanel> createState() => _ScoreSummaryPanelState();
}

class _ScoreSummaryPanelState extends State<ScoreSummaryPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _scrollController = ScrollController();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ScoreSummaryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.match.scoreHistory.length != oldWidget.match.scoreHistory.length) {
      // Scroll to bottom when new point is added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppTheme.fastAnimation,
            curve: AppTheme.defaultCurve,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(),
          
          // Header
          _buildHeader(),
          
          // Score timeline
          Expanded(
            child: _buildScoreTimeline(),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1, duration: 400.ms, curve: AppTheme.defaultCurve)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'MATCH TIMELINE',
            style: AppTheme.titleStyle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          
      // Show duce status if applicable
          if (widget.match.isDuce)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
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
          widget.match.duceMessage != null
            ? widget.match.duceMessage!.replaceAll('Duce', 'Deuce')
            : 'Match Deuce',
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
            ),
          
          Row(
            children: [
              Expanded(
                child: _buildTeamScore(
                  widget.match.teamAName,
                  widget.match.teamAScore,
                  AppTheme.primaryEmerald,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'VS',
                  style: AppTheme.captionStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: _buildTeamScore(
                  widget.match.teamBName,
                  widget.match.teamBScore,
                  AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Duration: ${_formatDuration(widget.match.matchDuration)}',
            style: AppTheme.captionStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            teamName,
            textAlign: TextAlign.center,
            style: AppTheme.captionStyle.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: AppTheme.titleStyle.copyWith(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreTimeline() {
    if (widget.match.scoreHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No points scored yet',
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Use the actual scoreHistory for timeline (doubles logic is already correct)
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: widget.match.scoreHistory.length,
      itemBuilder: (context, index) {
        final point = widget.match.scoreHistory[index];
        return _buildTimelineItem(point, index);
      },
    );
  }

  Widget _buildTimelineItem(ScorePoint point, int index) {
    // Check if it's a duce situation first
    final duceThreshold = widget.match.targetScore - 1;
    final isDuce = point.teamAScore >= duceThreshold && 
                   point.teamBScore >= duceThreshold && 
                   point.teamAScore == point.teamBScore;
    // Match point is when one team is at target score or above AND ahead by 1+, but NOT in duce
    final isMatchPoint = !isDuce && 
                        ((point.teamAScore >= widget.match.targetScore && point.teamAScore > point.teamBScore) ||
                         (point.teamBScore >= widget.match.targetScore && point.teamBScore > point.teamAScore));
    final servingTeamColor = point.servingTeam == ServingTeam.teamA 
        ? AppTheme.primaryEmerald 
        : AppTheme.primaryBlue;
    final winningTeamColor = point.winningTeam == ServingTeam.teamA 
        ? AppTheme.primaryEmerald 
        : AppTheme.primaryBlue;
    final isDoubles = widget.match.matchType == MatchType.doubles;
    String? serverName;
    if (isDoubles) {
  // Always show as Server 1 and Server 2 for doubles
  if (point.serverPlayerIndex == 0) serverName = 'Server 1';
  if (point.serverPlayerIndex == 1) serverName = 'Server 2';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isMatchPoint || isDuce) ? AppTheme.accentGold : winningTeamColor,
                  border: Border.all(
                    color: AppTheme.textPrimary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    point.turnNumber.toString(),
                    style: AppTheme.captionStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: (isMatchPoint || isDuce) ? AppTheme.textPrimary : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              if (index < widget.match.scoreHistory.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Point details
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: (isMatchPoint || isDuce) 
                    ? LinearGradient(
                        colors: [
                          AppTheme.accentGold.withOpacity(0.2),
                          AppTheme.accentGold.withOpacity(0.1),
                        ],
                      )
                    : AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(12),
                border: (isMatchPoint || isDuce)
                    ? Border.all(color: AppTheme.accentGold, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 16,
                              color: servingTeamColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: isDoubles
                                    ? Text(
                                        serverName != null
                                            ? '${_getTeamName(point.servingTeam)} (${serverName}) serving'
                                            : '${_getTeamName(point.servingTeam)} serving',
                                        style: AppTheme.captionStyle.copyWith(
                                          color: servingTeamColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        '${_getTeamName(point.servingTeam)} serving',
                                        style: AppTheme.captionStyle.copyWith(
                                          color: servingTeamColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          DateFormat('HH:mm:ss').format(point.timestamp),
                          style: AppTheme.captionStyle.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        point.pointAwarded ? Icons.add_circle : Icons.swap_horiz,
                        size: 18,
                        color: winningTeamColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point.pointAwarded
                              ? '${_getTeamName(point.winningTeam)} wins point'
                              : '${_getTeamName(point.winningTeam)} wins rally (serve change)',
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Score: ${point.teamAScore} - ${point.teamBScore}',
                          style: AppTheme.titleStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isMatchPoint)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'MATCH POINT',
                              style: AppTheme.captionStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      if (isDuce && point.teamAScore == point.teamBScore)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'DEUCE',
                              style: AppTheme.captionStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 50).ms)
        .slideX(begin: 0.3, duration: 300.ms, curve: AppTheme.defaultCurve)
        .fadeIn(duration: 200.ms);
  }

  String _getTeamName(ServingTeam team) {
    return team == ServingTeam.teamA 
        ? widget.match.teamAName 
        : widget.match.teamBName;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
