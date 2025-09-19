import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.isLoading) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rotationController.stop();
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startAnimations();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated loading icon
                          Transform.rotate(
                            angle: _rotationAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2E7D32),
                                    Color(0xFF4CAF50),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Loading text
                          Text(
                            widget.message ?? 'Loading Patients...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Loading dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final delay = index * 0.2;
                                  final animationValue = (_pulseController.value + delay) % 1.0;
                                  final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
                                  
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                    transform: Matrix4.identity()..scale(scale),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
