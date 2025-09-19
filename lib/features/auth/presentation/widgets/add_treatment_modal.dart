import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/treatment.dart';
import '../../../../core/services/api_service.dart';

class AddTreatmentModal extends StatefulWidget {
  final Function(Treatment) onSave;

  const AddTreatmentModal({
    super.key,
    required this.onSave,
  });

  @override
  State<AddTreatmentModal> createState() => _AddTreatmentModalState();
}

class _AddTreatmentModalState extends State<AddTreatmentModal>
    with TickerProviderStateMixin {
  Treatment? _selectedTreatment;
  int _maleCount = 0;
  int _femaleCount = 0;
  
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  List<Treatment> _treatments = [];
  bool _isTreatmentLoading = false;
  String? _treatmentError;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _fetchTreatments();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
  }

  Future<void> _fetchTreatments() async {
    if (!mounted) return;
    
    setState(() {
      _isTreatmentLoading = true;
      _treatmentError = null;
    });

    try {
      final result = await ApiService.getTreatmentList();
      
      if (!mounted) return;

      if (result['success'] == true) {
        final treatmentData = result['data'] as List;
        setState(() {
          _treatments = treatmentData.map((json) => Treatment.fromJson(json)).toList();
          _isTreatmentLoading = false;
        });
      } else {
        setState(() {
          _treatmentError = result['message'] ?? 'Failed to load treatments';
          _isTreatmentLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _treatmentError = 'Failed to load treatments. Please try again.';
        _isTreatmentLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    
    // Responsive margins and padding
    final horizontalMargin = isSmallScreen ? 16.0 : (isTablet ? 40.0 : 60.0);
    final verticalMargin = isSmallScreen ? 20.0 : 40.0;
    final contentPadding = isSmallScreen ? 20.0 : 24.0;
    
    // Responsive max width
    final maxWidth = isSmallScreen ? double.infinity : (isTablet ? 500.0 : 400.0);
    
    return Material(
      color: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                  vertical: verticalMargin,
                ),
                padding: EdgeInsets.all(contentPadding),
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: screenSize.height * 0.85, // Prevent overflow on small screens
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      _buildTreatmentDropdown(),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      _buildPatientsSection(context),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      _buildSaveButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Choose Treatment',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close, 
            color: const Color(0xFF666666),
            size: isSmallScreen ? 20 : 24,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildTreatmentDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF3D704D),
          width: 2,
        ),
      ),
      child: _isTreatmentLoading
          ? Container(
              height: 48,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3D704D).withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Loading treatments...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            )
          : _treatmentError != null
              ? Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _treatmentError!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _fetchTreatments,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: const Color(0xFF3D704D).withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Treatment>(
                    isExpanded: true,
                    value: _selectedTreatment,
                    hint: const Text(
                      'Choose preferred treatment',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: _treatments.map((Treatment treatment) {
                      return DropdownMenuItem<Treatment>(
                        value: treatment,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            treatment.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _treatments.isEmpty
                        ? null
                        : (Treatment? value) {
                            setState(() {
                              _selectedTreatment = value;
                            });
                          },
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF3D704D),
                      size: 24,
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
    );
  }

  Widget _buildPatientsSection(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Patients',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildPatientCounter(context, 'Male', _maleCount, (count) {
          setState(() => _maleCount = count);
        }),
        SizedBox(height: isSmallScreen ? 12 : 16),
        _buildPatientCounter(context, 'Female', _femaleCount, (count) {
          setState(() => _femaleCount = count);
        }),
      ],
    );
  }

  Widget _buildPatientCounter(BuildContext context, String gender, int count, Function(int) onChanged) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    if (isSmallScreen) {
      // Stack layout for small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              gender,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                context: context,
                icon: Icons.remove,
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),
              const SizedBox(width: 20),
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildCounterButton(
                context: context,
                icon: Icons.add,
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      );
    }
    
    // Original row layout for larger screens
    return Row(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            gender,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildCounterButton(
          context: context,
          icon: Icons.remove,
          onPressed: count > 0 ? () => onChanged(count - 1) : null,
        ),
        const SizedBox(width: 16),
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildCounterButton(
          context: context,
          icon: Icons.add,
          onPressed: () => onChanged(count + 1),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isEnabled = onPressed != null;
    final buttonSize = isSmallScreen ? 36.0 : 40.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: const Color(0xFF3D704D),
        borderRadius: BorderRadius.circular(buttonSize / 2),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: const Color(0xFF3D704D).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
            size: iconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final canSave = _selectedTreatment != null && (_maleCount > 0 || _femaleCount > 0);
    final buttonHeight = isSmallScreen ? 48.0 : 50.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              color: canSave ? const Color(0xFF3D704D) : const Color(0xFFCCCCCC),
              boxShadow: canSave ? [
                BoxShadow(
                  color: const Color(0xFF3D704D).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canSave ? _handleSave : null,
                onTapDown: canSave ? (_) => _scaleController.forward() : null,
                onTapUp: canSave ? (_) => _scaleController.reverse() : null,
                onTapCancel: canSave ? () => _scaleController.reverse() : null,
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: canSave ? Colors.white : const Color(0xFF666666),
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSave() {
    if (_selectedTreatment != null && (_maleCount > 0 || _femaleCount > 0)) {
      HapticFeedback.lightImpact();
      
      // Create a copy of the selected treatment with the counts
      final treatmentWithCounts = _selectedTreatment!.copyWith(
        maleCount: _maleCount,
        femaleCount: _femaleCount,
      );
      
      widget.onSave(treatmentWithCounts);
      Navigator.pop(context);
    }
  }
}

// Helper function to show the modal
Future<void> showAddTreatmentModal(
  BuildContext context,
  Function(Treatment) onSave,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AddTreatmentModal(onSave: onSave);
    },
  );
}
