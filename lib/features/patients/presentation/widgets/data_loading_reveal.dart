import 'package:flutter/material.dart';

class DataLoadingReveal extends StatefulWidget {
  final Widget child;
  final bool isDataLoaded;
  final Duration delay;

  const DataLoadingReveal({
    super.key,
    required this.child,
    required this.isDataLoaded,
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<DataLoadingReveal> createState() => _DataLoadingRevealState();
}

class _DataLoadingRevealState extends State<DataLoadingReveal>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  
  late Animation<double> _opacityAnimation;

  bool _hasRevealed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Simple fade in animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasRevealed) {
        _hasRevealed = true;
      }
    });
  }

  @override
  void didUpdateWidget(DataLoadingReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger reveal when data loads
    if (widget.isDataLoaded && !oldWidget.isDataLoaded && !_hasRevealed) {
      _startRevealAnimation();
    }
  }

  void _startRevealAnimation() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}
