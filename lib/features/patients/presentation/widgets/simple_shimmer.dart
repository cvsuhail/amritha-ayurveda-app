import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SimpleShimmer extends StatefulWidget {
  final Widget child;
  
  const SimpleShimmer({
    super.key,
    required this.child,
  });

  @override
  State<SimpleShimmer> createState() => _SimpleShimmerState();
}

class _SimpleShimmerState extends State<SimpleShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class PatientListShimmer extends StatelessWidget {
  const PatientListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: List.generate(2, (index) => // Reduced from 3 to 2 for faster initial render 
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: SimpleShimmer(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 200,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
