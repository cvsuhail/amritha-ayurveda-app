import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchSortSection extends StatefulWidget {
  final TextEditingController searchController;
  final String selectedSortOption;
  final Function(String) onSearchChanged;
  final Function(String) onSortChanged;
  final bool isLoading;

  const SearchSortSection({
    super.key,
    required this.searchController,
    required this.selectedSortOption,
    required this.onSearchChanged,
    required this.onSortChanged,
    this.isLoading = false,
  });

  @override
  State<SearchSortSection> createState() => _SearchSortSectionState();
}

class _SearchSortSectionState extends State<SearchSortSection>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _sortController;
  late Animation<double> _searchScaleAnimation;
  late Animation<double> _sortFadeAnimation;

  final List<String> _sortOptions = ['Date', 'Name', 'Package'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _sortController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeOutBack,
    ));

    _sortFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sortController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _searchController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _sortController.forward();
      }
    });
  }

  void _showSortOptions() {
    if (widget.isLoading) return; // Don't show sort options when loading
    
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Sort by',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            
            ..._sortOptions.map((option) => ListTile(
              title: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: widget.selectedSortOption == option
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: widget.selectedSortOption == option
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[700],
                  fontFamily: 'Poppins',
                ),
              ),
              trailing: widget.selectedSortOption == option
                  ? const Icon(
                      Icons.check,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    )
                  : null,
              onTap: () {
                widget.onSortChanged(option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          AnimatedBuilder(
            animation: _searchScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _searchScaleAnimation.value,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: widget.searchController,
                          onChanged: widget.isLoading ? null : widget.onSearchChanged,
                          enabled: !widget.isLoading,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.isLoading ? Colors.grey[400] : const Color(0xFF2C2C2C),
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            hintText: widget.isLoading ? 'Loading...' : 'Search for treatments',
                            hintStyle: TextStyle(
                              color: widget.isLoading ? Colors.grey[400] : const Color(0xFF9E9E9E),
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            prefixIcon: widget.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF2E7D32).withOpacity(0.6),
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.search,
                                    color: const Color(0xFF9E9E9E),
                                    size: 20,
                                  ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Search Button
                    Container(
                      height: 48,
                      width: 80,
                      decoration: BoxDecoration(
                        color: widget.isLoading ? Colors.grey[400] : const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.isLoading ? null : () {
                            HapticFeedback.lightImpact();
                            widget.onSearchChanged(widget.searchController.text);
                          },
                          child: const Center(
                            child: Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Sort Section
          AnimatedBuilder(
            animation: _sortFadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _sortFadeAnimation,
                child: Row(
                  children: [
                    Text(
                      'Sort by :',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Sort Dropdown
                    GestureDetector(
                      onTap: widget.isLoading ? null : _showSortOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isLoading ? Colors.grey[100] : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.isLoading ? Colors.grey[300]! : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isLoading ? 'Loading...' : widget.selectedSortOption,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.isLoading ? Colors.grey[400] : const Color(0xFF2C2C2C),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: widget.isLoading ? Colors.grey[400] : const Color(0xFF2E7D32),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
