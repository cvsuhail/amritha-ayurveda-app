import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller1);

    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller2);

    _controller1.repeat();
    _controller2.repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            Color(0xFFF0F8F0),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating circles
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Positioned(
                top: 100 + (50 * _animation1.value),
                right: 50 + (30 * _animation1.value),
                child: Transform.rotate(
                  angle: _animation1.value * 2 * 3.14159,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.3),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                top: 200 + (30 * _animation2.value),
                left: 30 + (40 * _animation2.value),
                child: Transform.rotate(
                  angle: -_animation2.value * 2 * 3.14159,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.2),
                          AppColors.accent.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Decorative leaf shapes
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Positioned(
                top: 150,
                left: -20 + (20 * _animation1.value),
                child: Transform.rotate(
                  angle: _animation1.value * 0.5,
                  child: CustomPaint(
                    size: const Size(40, 60),
                    painter: LeafPainter(AppColors.primary.withOpacity(0.1)),
                  ),
                ),
              );
            },
          ),
          
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                top: 80,
                right: -10 + (15 * _animation2.value),
                child: Transform.rotate(
                  angle: -_animation2.value * 0.3,
                  child: CustomPaint(
                    size: const Size(35, 50),
                    painter: LeafPainter(AppColors.primaryLight.withOpacity(0.15)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LeafPainter extends CustomPainter {
  final Color color;

  LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create leaf shape
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width, size.height * 0.3,
      size.width * 0.8, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width * 0.2, size.height * 0.7,
    );
    path.quadraticBezierTo(
      0, size.height * 0.3,
      size.width / 2, 0,
    );

    canvas.drawPath(path, paint);
    
    // Draw leaf vein
    final veinPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height * 0.8),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
