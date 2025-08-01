import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../models/match.dart';
import '../providers/match_provider.dart';
import '../widgets/animated_button.dart';
import '../widgets/custom_text_field.dart';
import 'game_scoring_screen.dart';

/// Screen for setting up a new pickleball match
class MatchSetupScreen extends StatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> with TickerProviderStateMixin {
  bool get _showTeamANameField {
    return _teamAPlayer1Controller.text.trim().isNotEmpty && _teamAPlayer2Controller.text.trim().isNotEmpty;
  }
  bool get _showTeamBNameField {
    return _teamBPlayer1Controller.text.trim().isNotEmpty && _teamBPlayer2Controller.text.trim().isNotEmpty;
  }
  // Helper to auto-generate team name from player names
  String _generateTeamName(String player1, String player2) {
    String getInitial(String name) {
      final parts = name.trim().split(RegExp(r'\s+'));
      return parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    final initial1 = getInitial(player1);
    final initial2 = getInitial(player2);
    if (initial1.isNotEmpty && initial2.isNotEmpty) {
      return '$initial1-$initial2';
    }
    return '';
  }

  void _updateTeamANameFromPlayers() {
    if (_teamANameController.text.trim().isEmpty) {
      final autoName = _generateTeamName(_teamAPlayer1Controller.text, _teamAPlayer2Controller.text);
      if (autoName.isNotEmpty) {
        _teamANameController.text = autoName;
        _teamANameController.selection = TextSelection.fromPosition(TextPosition(offset: autoName.length));
      }
    }
  }

  void _updateTeamBNameFromPlayers() {
    if (_teamBNameController.text.trim().isEmpty) {
      final autoName = _generateTeamName(_teamBPlayer1Controller.text, _teamBPlayer2Controller.text);
      if (autoName.isNotEmpty) {
        _teamBNameController.text = autoName;
        _teamBNameController.selection = TextSelection.fromPosition(TextPosition(offset: autoName.length));
      }
    }
  }
  
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  
  // Controllers for team names in doubles mode
  final _teamANameController = TextEditingController();
  final _teamBNameController = TextEditingController();
  
  // Controllers for doubles players
  final _teamAPlayer1Controller = TextEditingController();
  final _teamAPlayer2Controller = TextEditingController();
  final _teamBPlayer1Controller = TextEditingController();
  final _teamBPlayer2Controller = TextEditingController();
  
  int _selectedTargetScore = 11;
  ServingTeam _firstServingTeam = ServingTeam.teamA;
  MatchType _selectedMatchType = MatchType.singles;
  int? _selectedCourtNo = 1;
  String? _customCourtNo;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupDefaultValues();
    _setupTextControllerListeners();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  void _setupDefaultValues() {
    // Leave controllers empty for user input
    // For singles: users enter player names
    // For doubles: users enter player names, team names are auto-generated
  }

  void _setupTextControllerListeners() {
    // Add listeners to rebuild the UI when text changes
    _teamAController.addListener(() {
      setState(() {});
    });
    
    _teamBController.addListener(() {
      setState(() {});
    });
    
    // Team name controllers for doubles mode
    _teamANameController.addListener(() {
      setState(() {});
    });
    
    _teamBNameController.addListener(() {
      setState(() {});
    });
    
    _teamAPlayer1Controller.addListener(() {
      _updateTeamANameFromPlayers();
      setState(() {});
    });
    _teamAPlayer2Controller.addListener(() {
      _updateTeamANameFromPlayers();
      setState(() {});
    });
    _teamBPlayer1Controller.addListener(() {
      _updateTeamBNameFromPlayers();
      setState(() {});
    });
    _teamBPlayer2Controller.addListener(() {
      _updateTeamBNameFromPlayers();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _teamANameController.dispose();
    _teamBNameController.dispose();
    _teamAPlayer1Controller.dispose();
    _teamAPlayer2Controller.dispose();
    _teamBPlayer1Controller.dispose();
    _teamBPlayer2Controller.dispose();
    super.dispose();
  }

  void _startMatch() {
    if (_formKey.currentState!.validate()) {
      // Determine selected court number as string
      String? courtNo;
      if (_selectedCourtNo != null) {
        courtNo = _selectedCourtNo.toString();
      } else if (_customCourtNo != null && _customCourtNo!.isNotEmpty) {
        courtNo = _customCourtNo;
      }

      if (_selectedMatchType == MatchType.singles) {
        // Singles match
        context.read<MatchProvider>().startMatch(
          teamAName: _teamAController.text.trim(),
          teamBName: _teamBController.text.trim(),
          matchType: _selectedMatchType,
          targetScore: _selectedTargetScore,
          firstServingTeam: _firstServingTeam,
          courtNo: courtNo,
        );
      } else {
        // Doubles match - use custom team names or defaults
        String teamAName = _teamANameController.text.trim().isNotEmpty 
            ? _teamANameController.text.trim() 
            : 'Team A';
        String teamBName = _teamBNameController.text.trim().isNotEmpty 
            ? _teamBNameController.text.trim() 
            : 'Team B';

        context.read<MatchProvider>().startMatch(
          teamAName: teamAName,
          teamBName: teamBName,
          matchType: _selectedMatchType,
          targetScore: _selectedTargetScore,
          firstServingTeam: _firstServingTeam,
          courtNo: courtNo,
          teamAPlayer1: _teamAPlayer1Controller.text.trim(),
          teamAPlayer2: _teamAPlayer2Controller.text.trim(),
          teamBPlayer1: _teamBPlayer1Controller.text.trim(),
          teamBPlayer2: _teamBPlayer2Controller.text.trim(),
        );
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const GameScoringScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: AppTheme.defaultCurve)),
              ),
              child: child,
            );
          },
          transitionDuration: AppTheme.normalAnimation,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 40),
                  // Team setup section
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildMatchTypeSection(),
                          const SizedBox(height: 40),
                          _buildTeamSetupSection(),
                          const SizedBox(height: 40),
                          _buildMatchConfigSection(),
                          const SizedBox(height: 60),
                          _buildStartButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Column(
            children: [
              Text(
                'SETUP MATCH',
                style: AppTheme.headlineStyle.copyWith(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure your pickleball game',
                style: AppTheme.captionStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchTypeSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: AppTheme.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Type',
                    style: AppTheme.titleStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMatchTypeOption(MatchType.singles),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMatchTypeOption(MatchType.doubles),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    )
        .animate(delay: 100.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: AppTheme.defaultCurve)
        .fadeIn();
  }

  Widget _buildMatchTypeOption(MatchType matchType) {
    final isSelected = _selectedMatchType == matchType;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMatchType = matchType;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        curve: AppTheme.defaultCurve,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: isSelected 
            ? AppTheme.selectedButtonDecoration 
            : AppTheme.inactiveButtonDecoration,
        child: Column(
          children: [
            Icon(
              matchType == MatchType.singles ? Icons.person : Icons.groups,
              size: screenWidth * 0.08,
              color: isSelected 
                  ? Colors.white 
                  : AppTheme.textSecondary,
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              matchType.displayName,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.035,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              matchType.description,
              style: AppTheme.captionStyle.copyWith(
                fontSize: screenWidth * 0.025,
                color: isSelected 
                    ? Colors.white.withOpacity(0.9)
                    : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSetupSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedMatchType == MatchType.singles ? 'Teams' : 'Teams & Players',
                  style: AppTheme.titleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),
                
                if (_selectedMatchType == MatchType.singles) ...[
                  // Singles Mode - Team A Section
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: AppTheme.cardRadius,
                      
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppTheme.primaryEmerald,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Team A',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryEmerald,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        
                        CustomTextField(
                          controller: _teamAController,
                          label: 'Player Name',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter player name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 100.ms)
                      .slideX(begin: -0.3, duration: 400.ms, curve: AppTheme.defaultCurve)
                      .fadeIn(),
                  
                  SizedBox(height: screenWidth * 0.04),
                  
                  // Singles Mode - Team B Section
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: AppTheme.cardRadius,
                      
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppTheme.primaryBlue,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Team B',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        
                        CustomTextField(
                          controller: _teamBController,
                          label: 'Player Name',
                          prefixIcon: Icons.person,
                          accentColor: AppTheme.primaryBlue,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter player name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 200.ms)
                      .slideX(begin: 0.3, duration: 400.ms, curve: AppTheme.defaultCurve)
                      .fadeIn(),
                ] else ...[
                  // Doubles Mode - Team A Section
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: AppTheme.cardRadius,
                      
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: AppTheme.primaryEmerald,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Team A',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryEmerald,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        
                        // Team A Name Input
                        if (_showTeamANameField)
                          CustomTextField(
                            controller: _teamANameController,
                            label: 'Team A Name',
                            prefixIcon: Icons.sports_tennis,
                            suffixIcon: Icons.edit,
                            onSuffixPressed: () {
                              // Optionally, you can focus the field or show a dialog
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Team name required';
                              }
                              return null;
                            },
                          ),
                        SizedBox(height: screenWidth * 0.03),
                        
                        // Team A Players
                        Column(
                          children: [
                            CustomTextField(
                              controller: _teamAPlayer1Controller,
                              label: 'Player 1',
                              prefixIcon: Icons.person,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            CustomTextField(
                              controller: _teamAPlayer2Controller,
                              label: 'Player 2',
                              prefixIcon: Icons.person,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 100.ms)
                      .slideX(begin: -0.3, duration: 400.ms, curve: AppTheme.defaultCurve)
                      .fadeIn(),
                  
                  SizedBox(height: screenWidth * 0.04),
                  
                  // Doubles Mode - Team B Section
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: AppTheme.cardRadius,
                      
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              color: AppTheme.primaryBlue,
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              'Team B',
                              style: AppTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                                fontSize: screenWidth * 0.045,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.04),
                        
                        // Team B Name Input
                        if (_showTeamBNameField)
                          CustomTextField(
                            controller: _teamBNameController,
                            label: 'Team B Name',
                            prefixIcon: Icons.sports_tennis,
                            accentColor: AppTheme.primaryBlue,
                            suffixIcon: Icons.edit,
                            onSuffixPressed: () {
                              // Optionally, you can focus the field or show a dialog
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Team name required';
                              }
                              return null;
                            },
                          ),
                        SizedBox(height: screenWidth * 0.03),
                        
                        // Team B Players
                        Column(
                          children: [
                            CustomTextField(
                              controller: _teamBPlayer1Controller,
                              label: 'Player 1',
                              prefixIcon: Icons.person,
                              accentColor: AppTheme.primaryBlue,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenWidth * 0.03),
                            CustomTextField(
                              controller: _teamBPlayer2Controller,
                              label: 'Player 2',
                              prefixIcon: Icons.person,
                              accentColor: AppTheme.primaryBlue,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate(delay: 200.ms)
                      .slideX(begin: 0.3, duration: 400.ms, curve: AppTheme.defaultCurve)
                      .fadeIn(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchConfigSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 70 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Configuration',
                  style: AppTheme.titleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 20),
                // Target score selector
                _buildTargetScoreSelector(),
                const SizedBox(height: 30),
                // Court No selector (moved here)
                _buildCourtNoSelector(),
                const SizedBox(height: 30),
                // First serving team selector
                _buildFirstServingTeamSelector(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourtNoSelector() {
    final List<int> courtNumbers = [1, 2, 3, 4, 5];
    final bool isCustom = _selectedCourtNo == null && _customCourtNo != null && _customCourtNo!.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
  final buttonSize = screenWidth * 0.18; // Slightly smaller for better fit
  final minButtonSize = 48.0;
  final maxButtonSize = 80.0;
  final actualButtonSize = buttonSize.clamp(minButtonSize, maxButtonSize);
  final fontSize = 17.0; 
    final customFontSize = (screenWidth * 0.04).clamp(12.0, 18.0);
    final padding = EdgeInsets.all(screenWidth * 0.05);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Court Number',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: fontSize),
          ),
          SizedBox(height: screenWidth * 0.04),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: screenWidth * 0.05,
              runSpacing: screenWidth * 0.05,
              children: [
                ...courtNumbers.map((num) {
                  final bool selected = _selectedCourtNo == num && !isCustom;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                    child: SizedBox(
                      width: actualButtonSize,
                      height: actualButtonSize,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCourtNo = num;
                            _customCourtNo = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: AppTheme.fastAnimation,
                          curve: AppTheme.defaultCurve,
                          decoration: selected
                              ? AppTheme.selectedButtonDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(actualButtonSize / 2),
                                )
                              : AppTheme.inactiveButtonDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(actualButtonSize / 2),
                                ),
                          child: Center(
                            child: Text(
                              num.toString(),
                              style: AppTheme.titleStyle.copyWith(
                                fontSize: fontSize + 6,
                                color: selected ? Colors.white : AppTheme.textSecondary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
                  child: SizedBox(
                    width: actualButtonSize,
                    height: actualButtonSize,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await showDialog<String>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.6),
                          builder: (context) {
                            final TextEditingController controller = TextEditingController(text: _customCourtNo);
                            final screenWidth = MediaQuery.of(context).size.width;
                            final neonRed = AppTheme.primaryEmerald;
                            final neonBlue = AppTheme.primaryBlue;
                            final borderRadius = AppTheme.cardRadius;
                            return Center(
                              child: Material(
                                color: Colors.transparent,
                                child: AnimatedContainer(
                                  duration: AppTheme.normalAnimation,
                                  curve: AppTheme.defaultCurve,
                                  width: screenWidth * 0.85,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                  decoration: BoxDecoration(
                                    borderRadius: borderRadius,
                                    gradient: AppTheme.cardGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: neonBlue.withOpacity(0.10),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: neonRed.withOpacity(0.18),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.sports_tennis, size: 38, color: neonBlue),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Court Number',
                                        style: AppTheme.titleStyle.copyWith(
                                          fontSize: 22,
                                          color: neonRed,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 18),
                                     TextField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                                style: AppTheme.bodyStyle.copyWith(
                                          color: AppTheme.textPrimary,
                                          fontSize: 18,
                                        ),
                                        cursorColor: neonBlue,
                                        decoration: InputDecoration(
                                          hintText: 'Enter court number',
                                          hintStyle: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.85),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: borderRadius,
                                            borderSide: BorderSide(color: neonBlue.withOpacity(0.3), width: 1.2),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: borderRadius,
                                            borderSide: BorderSide(color: neonRed, width: 2.0),
                                      ),
                                       prefixIcon: Icon(Icons.edit, color: neonBlue.withOpacity(0.8)),
                                        ),
                                        autofocus: true,
                                        onSubmitted: (val) {
                                          Navigator.of(context).pop(val.trim());
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                   style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: neonBlue,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: borderRadius,
                                                  side: BorderSide(color: neonBlue.withOpacity(0.7), width: 1.2),
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                              ),
                                              child: Text('Cancel', style: AppTheme.buttonStyle.copyWith(fontSize: 16, color: neonBlue)),
                                            ),
                                      ),
                                     const SizedBox(width: 16),
                                          Expanded(
                                            child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(controller.text.trim());
                                  },
                                   style: ElevatedButton.styleFrom(
                                                backgroundColor: neonRed,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: borderRadius,
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                              ),
                                              child: Text('OK', style: AppTheme.buttonStyle.copyWith(fontSize: 16, color: Colors.white)),
                                            ),
                                ),
                              ],
                             ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                        if (result != null && result.isNotEmpty) {
                          setState(() {
                            _selectedCourtNo = null;
                            _customCourtNo = result;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: AppTheme.fastAnimation,
                        curve: AppTheme.defaultCurve,
                        decoration: isCustom
                            ? AppTheme.selectedButtonDecoration.copyWith(
                                borderRadius: BorderRadius.circular(actualButtonSize / 2),
                              )
                            : AppTheme.inactiveButtonDecoration.copyWith(
                                borderRadius: BorderRadius.circular(actualButtonSize / 2),
                              ),
                        child: Center(
                          child: Text(
                            'Custom',
                            style: AppTheme.titleStyle.copyWith(
                              fontSize: (customFontSize * 0.85).clamp(11.0, 14.0),
                              color: isCustom ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCustom && _customCourtNo != null && _customCourtNo!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.03),
              child: Text(
                'Selected: ${_customCourtNo}',
                style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.buttonViolet,
                  fontWeight: FontWeight.w600,
                  fontSize: customFontSize,
                ),
              ),
            ),
        ],
      ),
    )
        .animate(delay: 250.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: AppTheme.defaultCurve)
        .fadeIn();
  }

  Widget _buildTargetScoreSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: AppTheme.cardRadius,
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Score',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [11, 18, 21].map((score) {
              final isSelected = _selectedTargetScore == score;
              return Flexible(
                child: FittedBox(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTargetScore = score;
                      });
                    },
                    child: AnimatedContainer(
                      duration: AppTheme.fastAnimation,
                      curve: AppTheme.defaultCurve,
                      width: 60,
                      height: 60,
                      constraints: const BoxConstraints(
                        minWidth: 50,
                        minHeight: 50,
                        maxWidth: 70,
                        maxHeight: 70,
                      ),
                      decoration: isSelected 
                          ? AppTheme.selectedButtonDecoration.copyWith(
                              borderRadius: BorderRadius.circular(30),
                            )
                          : AppTheme.inactiveButtonDecoration.copyWith(
                              borderRadius: BorderRadius.circular(30),
                            ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            score.toString(),
                            style: AppTheme.titleStyle.copyWith(
                              fontSize: 20,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate(delay: 300.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: AppTheme.defaultCurve)
        .fadeIn();
  }

  Widget _buildFirstServingTeamSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: AppTheme.cardRadius,
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Serving Team',
            style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamSelector(
                  team: ServingTeam.teamA,
                  isSelected: _firstServingTeam == ServingTeam.teamA,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamSelector(
                  team: ServingTeam.teamB,
                  isSelected: _firstServingTeam == ServingTeam.teamB,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .slideY(begin: 0.3, duration: 500.ms, curve: AppTheme.defaultCurve)
        .fadeIn();
  }


  Widget _buildTeamSelector({
    required ServingTeam team,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _firstServingTeam = team;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        curve: AppTheme.defaultCurve,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: isSelected 
            ? AppTheme.selectedButtonDecoration 
            : AppTheme.inactiveButtonDecoration,
        child: Center(
          child: _buildTeamContent(team, isSelected),
        ),
      ),
    );
  }

  Widget _buildTeamContent(ServingTeam team, bool isSelected) {
    String teamName;
    
  if (_selectedMatchType == MatchType.doubles) {
    // Use custom team names for doubles
    teamName = team == ServingTeam.teamA 
      ? (_teamANameController.text.isNotEmpty 
        ? _teamANameController.text 
        : 'Team A')
      : (_teamBNameController.text.isNotEmpty 
        ? _teamBNameController.text 
        : 'Team B');
  } else {
    // Use player names for singles
    teamName = team == ServingTeam.teamA 
      ? (_teamAController.text.isNotEmpty 
        ? _teamAController.text 
        : 'Team A')
      : (_teamBController.text.isNotEmpty 
        ? _teamBController.text 
        : 'Team B');
  }
    
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        teamName,
        style: AppTheme.bodyStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isSelected 
              ? Colors.white 
              : AppTheme.textSecondary,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedButton(
      onPressed: _startMatch,
      backgroundColor: AppTheme.buttonViolet,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_arrow, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              child: Text(
                'START MATCH',
                style: AppTheme.buttonStyle.copyWith(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 500.ms)
        .slideY(begin: 0.5, duration: 600.ms, curve: AppTheme.bouncyCurve)
        .fadeIn();
  }
}
