import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../theme/carbon_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _globeController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final AnimationController _exitController;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Globe rotation — continuous for 3 seconds
    _globeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Pulse ring effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Staggered fade-ins for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );

    // Exit animation
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize anonymous session
    await ref.read(authProvider.notifier).initialize();
    final userId = ref.read(authProvider);

    if (userId != null) {
      await ref.read(profileProvider.notifier).initialize(userId);
      await ref.read(activityProvider.notifier).initialize(userId);
      await ref.read(goalProvider.notifier).initialize(userId);
      await ref.read(recommendationProvider.notifier).initialize(userId);
    }

    // Total splash duration: 3 seconds
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    // Play exit animation
    await _exitController.forward();

    if (!mounted) return;

    final profile = ref.read(profileProvider);
    if (profile != null && profile.onboardingCompleted) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _globeController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? CarbonColors.backgroundDark : CarbonColors.backgroundLight;
    final textColor =
        isDark ? CarbonColors.textPrimaryDark : CarbonColors.textPrimaryLight;
    final subtleColor =
        isDark ? CarbonColors.textMutedDark : CarbonColors.textMutedLight;
    final accentColor =
        isDark ? CarbonColors.tealPrimaryDark : CarbonColors.tealPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _globeController,
          _pulseController,
          _fadeController,
          _exitController,
        ]),
        builder: (context, _) {
          return FadeTransition(
            opacity: _exitFade,
            child: Stack(
              children: [
                // Background particle field
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticleFieldPainter(
                      progress: _globeController.value,
                      color: accentColor,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 3D Globe
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse rings
                            ..._buildPulseRings(accentColor),

                            // Glow backdrop
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(
                                      alpha: 0.25 +
                                          0.15 *
                                              sin(
                                                _pulseController.value *
                                                    2 *
                                                    pi,
                                              ),
                                    ),
                                    blurRadius: 50,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                            ),

                            // 3D Wireframe Globe
                            CustomPaint(
                              size: const Size(140, 140),
                              painter: _WireframeGlobePainter(
                                rotationY: _globeController.value * 2 * pi,
                                rotationX: pi / 8,
                                color: accentColor,
                                isDark: isDark,
                              ),
                            ),

                            // Center leaf icon
                            _buildLeafIcon(accentColor),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // App title
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: Text(
                            'CarbonLens',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -1.0,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      FadeTransition(
                        opacity: _taglineFade,
                        child: SlideTransition(
                          position: _taglineSlide,
                          child: Text(
                            'See the impact behind your day.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: subtleColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeafIcon(Color accentColor) {
    // Scale in with a spring feel
    final scaleVal = _fadeController.value < 0.35
        ? Curves.elasticOut
            .transform((_fadeController.value / 0.35).clamp(0.0, 1.0))
        : 1.0;

    return Transform.scale(
      scale: scaleVal * 0.9,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor,
              accentColor.withValues(alpha: 0.7),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.eco_rounded,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> _buildPulseRings(Color accentColor) {
    return List.generate(3, (i) {
      final delay = i * 0.33;
      final t = ((_pulseController.value + delay) % 1.0);
      final scale = 0.6 + t * 0.6;
      final opacity = (1.0 - t).clamp(0.0, 0.5);

      return Transform.scale(
        scale: scale,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withValues(alpha: opacity),
              width: 1.5,
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════
// 3D Wireframe Globe Painter
// ═══════════════════════════════════════════════════════
class _WireframeGlobePainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final Color color;
  final bool isDark;

  _WireframeGlobePainter({
    required this.rotationY,
    required this.rotationX,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw latitude lines
    for (int lat = -60; lat <= 60; lat += 30) {
      final latRad = lat * pi / 180;
      final y = sin(latRad);
      final r = cos(latRad);

      final path = Path();
      bool first = true;

      for (int lon = 0; lon <= 360; lon += 5) {
        final lonRad = lon * pi / 180 + rotationY;
        final x3d = r * cos(lonRad);
        final z3d = r * sin(lonRad);
        final y3d = y;

        // Apply X rotation
        final y3dRot = y3d * cos(rotationX) - z3d * sin(rotationX);
        final z3dRot = y3d * sin(rotationX) + z3d * cos(rotationX);

        // Project to 2D
        final scale = 1.0 / (1.0 + z3dRot * 0.3);
        final px = center.dx + x3d * radius * scale;
        final py = center.dy - y3dRot * radius * scale;

        // Depth-based opacity
        final depthAlpha = ((z3dRot + 1) / 2 * 0.6 + 0.15).clamp(0.0, 1.0);
        paint.color = color.withValues(alpha: depthAlpha);

        if (first) {
          path.moveTo(px, py);
          first = false;
        } else {
          path.lineTo(px, py);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Draw longitude lines
    for (int lon = 0; lon < 360; lon += 30) {
      final lonRad = lon * pi / 180 + rotationY;

      final path = Path();
      bool first = true;

      for (int lat = -90; lat <= 90; lat += 5) {
        final latRad = lat * pi / 180;
        final x3d = cos(latRad) * cos(lonRad);
        final z3d = cos(latRad) * sin(lonRad);
        final y3d = sin(latRad);

        final y3dRot = y3d * cos(rotationX) - z3d * sin(rotationX);
        final z3dRot = y3d * sin(rotationX) + z3d * cos(rotationX);

        final scale = 1.0 / (1.0 + z3dRot * 0.3);
        final px = center.dx + x3d * radius * scale;
        final py = center.dy - y3dRot * radius * scale;

        final depthAlpha = ((z3dRot + 1) / 2 * 0.6 + 0.15).clamp(0.0, 1.0);
        paint.color = color.withValues(alpha: depthAlpha);

        if (first) {
          path.moveTo(px, py);
          first = false;
        } else {
          path.lineTo(px, py);
        }
      }

      canvas.drawPath(path, paint);
    }

    // Equator highlight
    final equatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final equatorPath = Path();
    bool eFirst = true;
    for (int lon = 0; lon <= 360; lon += 3) {
      final lonRad = lon * pi / 180 + rotationY;
      final x3d = cos(lonRad);
      final z3d = sin(lonRad);

      final z3dRot = sin(rotationX) * 0 + cos(rotationX) * z3d;

      final scale = 1.0 / (1.0 + z3dRot * 0.3);
      final px = center.dx + x3d * radius * scale;
      final py = center.dy - (cos(rotationX) * 0 - sin(rotationX) * z3d) * radius * scale;

      final depthAlpha = ((z3dRot + 1) / 2 * 0.7 + 0.2).clamp(0.0, 1.0);
      equatorPaint.color = color.withValues(alpha: depthAlpha);

      if (eFirst) {
        equatorPath.moveTo(px, py);
        eFirst = false;
      } else {
        equatorPath.lineTo(px, py);
      }
    }
    canvas.drawPath(equatorPath, equatorPaint);

    // Outer circle glow
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius + 2, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _WireframeGlobePainter oldDelegate) =>
      oldDelegate.rotationY != rotationY;
}

// ═══════════════════════════════════════════════════════
// Background Particle Field Painter
// ═══════════════════════════════════════════════════════
class _ParticleFieldPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  static final List<_Particle> _particles = _generateParticles(60);

  _ParticleFieldPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  static List<_Particle> _generateParticles(int count) {
    final rng = Random(42);
    return List.generate(count, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.5 + 0.8,
        speed: rng.nextDouble() * 0.3 + 0.1,
        phase: rng.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final x = p.x * size.width;
      final y = (p.y + t * 0.3) % 1.0 * size.height;
      final alpha = (sin(t * 2 * pi) * 0.3 + 0.2).clamp(0.05, 0.4);

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }

    // Draw faint connection lines between nearby particles
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i < _particles.length; i++) {
      final pi1 = _particles[i];
      final t1 = (progress * pi1.speed + pi1.phase) % 1.0;
      final x1 = pi1.x * size.width;
      final y1 = (pi1.y + t1 * 0.3) % 1.0 * size.height;

      for (int j = i + 1; j < _particles.length; j++) {
        final pj = _particles[j];
        final t2 = (progress * pj.speed + pj.phase) % 1.0;
        final x2 = pj.x * size.width;
        final y2 = (pj.y + t2 * 0.3) % 1.0 * size.height;

        final dist = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
        if (dist < 80) {
          final lineAlpha = (1.0 - dist / 80) * 0.12;
          linePaint.color = color.withValues(alpha: lineAlpha);
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}
