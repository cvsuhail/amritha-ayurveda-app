import 'package:flutter/material.dart';

class RevealAnimationWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final bool shouldAnimate;
  final VoidCallback? onRevealed;

  const RevealAnimationWidget({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 200),
    this.shouldAnimate = true,
    this.onRevealed,
  });

  @override
  State<RevealAnimationWidget> createState() => _RevealAnimationWidgetState();
}

class _RevealAnimationWidgetState extends State<RevealAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _opacityController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  bool _hasBeenRevealed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.shouldAnimate) {
      _startRevealAnimation();
    } else {
      // If no animation needed, set to final state
      _slideController.value = 1.0;
      _opacityController.value = 1.0;
    }
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Subtle slide from bottom with smooth easing
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _opacityController,
      curve: Curves.easeInOut,
    ));

    // Add listener to track when animation completes
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasBeenRevealed) {
        _hasBeenRevealed = true;
        // Schedule the callback for after the current build cycle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onRevealed?.call();
        });
      }
    });
  }

  void _startRevealAnimation() {
    // Staggered delay based on index
    final totalDelay = Duration(
      milliseconds: widget.delay.inMilliseconds + (widget.index * 100),
    );
    
    Future.delayed(totalDelay, () {
      if (mounted) {
        _slideController.forward();
        _opacityController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideAnimation,
        _opacityAnimation,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
