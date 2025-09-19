import 'package:flutter/material.dart';

class EmptyPatientList extends StatefulWidget {
  final String? message;
  final String? subtitle;
  final VoidCallback? onRefresh;
  final bool showRefreshButton;

  const EmptyPatientList({
    super.key,
    this.message,
    this.subtitle,
    this.onRefresh,
    this.showRefreshButton = true,
  });

  @override
  State<EmptyPatientList> createState() => _EmptyPatientListState();
}

class _EmptyPatientListState extends State<EmptyPatientList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Empty state illustration
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 60,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main message
                    Text(
                      widget.message ?? 'No Patients Found',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      widget.subtitle ?? 
                      'There are no patients to display at the moment.\nTry refreshing or check back later.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.showRefreshButton && widget.onRefresh != null) ...[
                      const SizedBox(height: 24),
                      
                      // Refresh button
                      ElevatedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(
                          Icons.refresh,
                          size: 20,
                        ),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF2E7D32).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmptySearchResults extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchResults({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Search illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.search_off,
                size: 50,
                color: Color(0xFF9E9E9E),
              ),
            ),

            const SizedBox(height: 20),

            // Main message
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Search query and suggestion
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontFamily: 'Poppins',
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'No patients found for "'),
                  TextSpan(
                    text: searchQuery,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const TextSpan(text: '".\nTry adjusting your search criteria.'),
                ],
              ),
            ),

            if (onClearSearch != null) ...[
              const SizedBox(height: 20),
              
              // Clear search button
              TextButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(
                  Icons.clear,
                  size: 18,
                ),
                label: const Text(
                  'Clear Search',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
