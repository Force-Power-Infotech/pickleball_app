import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/match_provider.dart';
import 'match_setup_screen.dart';
import 'game_scoring_screen.dart';

/// Animated splash screen with logo and app intro
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedMatchAndNavigate();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: AppTheme.splashAnimation,
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: AppTheme.splashAnimation,
      vsync: this,
    );

    // Start animations
    _backgroundController.forward();
    _logoController.forward();
    
    // Delayed text animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _textController.forward();
    });
  }

  Future<void> _loadSavedMatchAndNavigate() async {
    // Load any saved match
    await context.read<MatchProvider>().loadSavedMatch();
    
    // Wait for splash animation to complete
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return;
    
    // Navigate to appropriate screen
    final matchProvider = context.read<MatchProvider>();
    if (matchProvider.hasActiveMatch && !matchProvider.currentMatch!.isMatchComplete) {
      // Resume active match
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
    } else {
      // Start new match setup
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
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedBackground(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  _buildAnimatedLogo(),
                  
                  const SizedBox(height: 40),
                  
                  // App title
                  _buildAnimatedTitle(),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle
                  _buildAnimatedSubtitle(),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: ParticlesPainter(_backgroundController.value),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoController.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              boxShadow: AppTheme.metallicShadow,
            ),
            child: const Icon(
              Icons.sports_tennis,
              size: 60,
              color: AppTheme.textPrimary,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 800.ms, curve: AppTheme.defaultCurve)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
              .then()
              .shimmer(duration: 1500.ms, color: AppTheme.accentGold.withOpacity(0.3)),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textController.value)),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Color(0xFFFFF9C4), // Light gold
                    AppTheme.accentGold,
                    Color(0xFFF57F17), // Deep amber
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              child: Text(
                'PICKLEBLAZE',
                style: AppTheme.headlineStyle.copyWith(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                  color: Colors.white,
                  // No shadow or glow
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value * 0.8,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - _textController.value)),
            child: Text(
              'SCORE TRACKER',
              style: AppTheme.captionStyle.copyWith(
                fontSize: 17,
                letterSpacing: 2.2,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTheme.buttonViolet.withOpacity(0.8),
        ),
      ),
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}

/// Custom painter for animated background particles
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> particleColors = [
      AppTheme.accentGold.withOpacity(0.45),
      Colors.white.withOpacity(0.38),
      AppTheme.buttonViolet.withOpacity(0.32),
      AppTheme.primaryBlue.withOpacity(0.28),
    ];
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw animated particles (brighter, more visible)
    for (int i = 0; i < 18; i++) {
      final x = (size.width / 18) * i + (animationValue * 60 * (i % 2 == 0 ? 1 : -1));
      final y = (size.height / 10) * (i % 10) + (animationValue * 40 * (i % 3 == 0 ? 1 : -1));
      final radius = 3.5 + (animationValue * (i % 2 == 0 ? 4 : 2));
      paint.color = particleColors[i % particleColors.length];
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        radius,
        paint,
      );
    }

    // Draw larger, soft orbs for depth
    for (int i = 0; i < 6; i++) {
      final x = (size.width / 6) * i + (animationValue * -40 * (i % 2 == 0 ? 1 : -1));
      final y = (size.height / 5) * (i % 5) + (animationValue * 30 * (i % 2 == 0 ? 1 : -1));
      final radius = 16 + (animationValue * 8);
      paint.color = particleColors[(i + 1) % particleColors.length].withOpacity(0.18);
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
