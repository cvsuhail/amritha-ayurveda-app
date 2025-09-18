import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool enabled;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<AnimatedTextField> createState() => AnimatedTextFieldState();
}


class AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _errorController;
  late AnimationController _shakeController;
  late Animation<double> _focusAnimation;
  late Animation<double> _errorFadeAnimation;
  late Animation<double> _errorSlideAnimation;
  late Animation<double> _shakeAnimation;

  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _hasError = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _focusNode.addListener(_onFocusChange);
  }

  void _initializeAnimations() {
    // Focus animation for border and colors
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Error animation for validation messages
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Shake animation for error feedback
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _errorFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeInOut,
    ));

    _errorSlideAnimation = Tween<double>(
      begin: -10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeOutCubic,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _focusController.forward();
      _triggerHapticFeedback(HapticFeedbackType.light);
    } else {
      _focusController.reverse();
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      if (error != _errorText) {
        setState(() {
          _errorText = error;
          _hasError = error != null;
        });

        if (_hasError) {
          _errorController.forward();
          _triggerShake();
          _triggerHapticFeedback(HapticFeedbackType.error);
        } else {
          _errorController.reverse();
        }
      }
    }
  }

  // Public method to trigger validation externally
  bool validate() {
    _validateField();
    return !_hasError;
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeController.forward();
  }

  void _triggerHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.error:
        // Create a custom error haptic pattern
        _customErrorHaptic();
        break;
    }
  }

  void _customErrorHaptic() async {
    // Custom error haptic pattern: medium-light-medium
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  Color _getBorderColor() {
    if (_hasError) {
      return AppColors.error;
    }
    if (_isFocused) {
      return AppColors.primary;
    }
    return AppColors.textHint.withOpacity(0.2);
  }

  Color _getBackgroundColor() {
    if (_hasError) {
      return AppColors.error.withOpacity(0.03);
    }
    if (_isFocused) {
      return Colors.white;
    }
    return const Color(0xFFFAFAFA);
  }

  @override
  void dispose() {
    _focusController.dispose();
    _errorController.dispose();
    _shakeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    
    // Responsive calculations
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;
    
    // Dynamic sizing with better proportions
    final labelFontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final inputFontSize = isTablet ? 17.0 : (isSmallScreen ? 15.0 : 16.0);
    final hintFontSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    final errorFontSize = isTablet ? 13.0 : (isSmallScreen ? 11.0 : 12.0);
    final iconSize = isTablet ? 16.0 : (isSmallScreen ? 14.0 : 15.0);
    
    // Improved padding for better touch targets and visual balance
    final horizontalPadding = isTablet ? 24.0 : (isSmallScreen ? 18.0 : 20.0);
    final labelSpacing = isSmallScreen ? 10.0 : 12.0;
    final errorSpacing = isSmallScreen ? 8.0 : 10.0;
    
    // Field height for consistent touch targets
    final fieldHeight = isTablet ? 60.0 : (isSmallScreen ? 54.0 : 58.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with enhanced styling
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Poppins',
            color: _hasError 
                ? AppColors.error 
                : _isFocused 
                    ? AppColors.primary 
                    : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: labelFontSize,
            letterSpacing: 0.2,
          ),
          child: Text(widget.label),
        ),
        SizedBox(height: labelSpacing),
        
        // Animated Text Field Container
        AnimatedBuilder(
          animation: Listenable.merge([_focusAnimation, _shakeAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value * 2 * (1 - _shakeAnimation.value) * 4, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _getBackgroundColor(),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: _isFocused ? 2.0 : 1.0,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: _getBorderColor().withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: _getBorderColor().withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                ),
                child: SizedBox(
                  height: fieldHeight,
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    enabled: widget.enabled,
                    onTap: widget.onTap,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      fontSize: inputFontSize,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: AppColors.textHint.withOpacity(0.7),
                        fontSize: hintFontSize,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 0, // Let SizedBox handle height
                      ),
                      isDense: true,
                    ),
                    // Remove validator from here since we handle it manually
                    validator: null,
                  ),
                ),
              ),
            );
          },
        ),
        
        // Animated Error Message
        AnimatedBuilder(
          animation: Listenable.merge([_errorFadeAnimation, _errorSlideAnimation]),
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _errorFadeAnimation,
              child: FadeTransition(
                opacity: _errorFadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _errorSlideAnimation.value),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: errorSpacing),
                    child: _hasError
                        ? Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: iconSize,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorText ?? '',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: errorFontSize,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  error,
}
