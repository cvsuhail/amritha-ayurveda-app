import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _petalController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _petalAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _petalController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutSine,
    ));

    _petalAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _petalController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _petalController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _rotationController.forward();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _petalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _petalAnimation]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 0.5,
            child: CustomPaint(
              size: const Size(120, 120),
              painter: LogoPainter(_petalAnimation.value),
            ),
          );
        },
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final double animationProgress;

  LogoPainter(this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    _drawOuterCircle(canvas, center, radius);

    // Draw flower petals
    _drawFlowerPetals(canvas, center, radius);

    // Draw center medical symbol
    _drawMedicalSymbol(canvas, center);
  }

  void _drawOuterCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        colors: [AppColors.primaryLight, AppColors.accent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 2, paint);
  }

  void _drawFlowerPetals(Canvas canvas, Offset center, double radius) {
    final petalPaint = Paint()..style = PaintingStyle.fill;

    // Draw 6 petals around the center
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180); // Convert to radians
      final progress = (animationProgress * 6 - i).clamp(0.0, 1.0);

      if (progress > 0) {
        _drawPetal(canvas, center, angle, radius * 0.4, progress, petalPaint, i);
      }
    }
  }

  void _drawPetal(Canvas canvas, Offset center, double angle, double petalRadius,
      double progress, Paint paint, int index) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Alternate colors for petals
    final gradient = index % 2 == 0
        ? const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          )
        : const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.accent],
          );

    paint.shader = gradient.createShader(
      Rect.fromCenter(center: Offset.zero, width: petalRadius * 2, height: petalRadius * 2),
    );

    final path = Path();
    final scaledRadius = petalRadius * progress;

    // Create petal shape
    path.moveTo(0, -scaledRadius);
    path.quadraticBezierTo(-scaledRadius * 0.6, -scaledRadius * 0.3, -scaledRadius * 0.3, 0);
    path.quadraticBezierTo(-scaledRadius * 0.6, scaledRadius * 0.3, 0, scaledRadius * 0.7);
    path.quadraticBezierTo(scaledRadius * 0.6, scaledRadius * 0.3, scaledRadius * 0.3, 0);
    path.quadraticBezierTo(scaledRadius * 0.6, -scaledRadius * 0.3, 0, -scaledRadius);

    paint.color = paint.color.withOpacity(0.8 * progress);
    canvas.drawPath(path, paint);

    canvas.restore();
  }

  void _drawMedicalSymbol(Canvas canvas, Offset center) {
    if (animationProgress < 0.7) return;

    final symbolProgress = ((animationProgress - 0.7) / 0.3).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * symbolProgress
      ..strokeCap = StrokeCap.round;

    // Draw caduceus staff
    paint.color = AppColors.primary.withOpacity(symbolProgress);
    canvas.drawLine(
      Offset(center.dx, center.dy - 25 * symbolProgress),
      Offset(center.dx, center.dy + 25 * symbolProgress),
      paint,
    );

    // Draw snakes
    paint.strokeWidth = 2 * symbolProgress;
    _drawSnake(canvas, center, symbolProgress, true);
    _drawSnake(canvas, center, symbolProgress, false);

    // Draw wings
    _drawWings(canvas, center, symbolProgress);
  }

  void _drawSnake(Canvas canvas, Offset center, double progress, bool leftSide) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * progress
      ..color = (leftSide ? AppColors.primary : AppColors.primaryLight)
          .withOpacity(progress);

    final path = Path();
    final startX = center.dx + (leftSide ? -8 : 8) * progress;
    final startY = center.dy - 20 * progress;

    path.moveTo(startX, startY);

    // Create sinuous snake path
    for (double t = 0; t <= 1; t += 0.1) {
      final y = startY + (40 * progress * t);
      final x = center.dx + (leftSide ? 1 : -1) * 8 * progress * 
                 (t % 0.4 < 0.2 ? 1 : -1);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawWings(Canvas canvas, Offset center, double progress) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.primaryLight.withOpacity(progress * 0.8);

    // Left wing
    final leftWing = Path();
    leftWing.moveTo(center.dx - 15 * progress, center.dy - 22 * progress);
    leftWing.quadraticBezierTo(
      center.dx - 25 * progress,
      center.dy - 25 * progress,
      center.dx - 20 * progress,
      center.dy - 15 * progress,
    );
    leftWing.lineTo(center.dx - 10 * progress, center.dy - 20 * progress);
    leftWing.close();

    // Right wing
    final rightWing = Path();
    rightWing.moveTo(center.dx + 15 * progress, center.dy - 22 * progress);
    rightWing.quadraticBezierTo(
      center.dx + 25 * progress,
      center.dy - 25 * progress,
      center.dx + 20 * progress,
      center.dy - 15 * progress,
    );
    rightWing.lineTo(center.dx + 10 * progress, center.dy - 20 * progress);
    rightWing.close();

    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is LogoPainter &&
        oldDelegate.animationProgress != animationProgress;
  }
}
