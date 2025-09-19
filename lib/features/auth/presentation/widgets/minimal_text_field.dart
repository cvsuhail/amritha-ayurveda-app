import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MinimalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool isSmallScreen;
  final bool isTablet;
  final bool isLandscape;

  const MinimalTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.isSmallScreen = false,
    this.isTablet = false,
    this.isLandscape = false,
  });

  @override
  State<MinimalTextField> createState() => MinimalTextFieldState();
}

class MinimalTextFieldState extends State<MinimalTextField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _hasError = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_isFocused) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
        _hasError = error != null;
      });
    }
  }

  // Public method to trigger validation externally
  bool validate() {
    _validateField();
    return !_hasError;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive calculations
    final labelFontSize = widget.isTablet ? 16.0 : (widget.isSmallScreen ? 12.0 : 14.0);
    final textFontSize = widget.isTablet ? 16.0 : (widget.isSmallScreen ? 13.0 : 14.0);
    final hintFontSize = widget.isTablet ? 16.0 : (widget.isSmallScreen ? 13.0 : 14.0);
    final errorFontSize = widget.isTablet ? 13.0 : (widget.isSmallScreen ? 11.0 : 12.0);
    final fieldHeight = widget.isTablet ? 64.0 : (widget.isSmallScreen ? 48.0 : 56.0);
    final labelSpacing = widget.isTablet ? 10.0 : (widget.isSmallScreen ? 6.0 : 8.0);
    final borderRadius = widget.isTablet ? 14.0 : (widget.isSmallScreen ? 10.0 : 12.0);
    final horizontalPadding = widget.isTablet ? 20.0 : (widget.isSmallScreen ? 12.0 : 16.0);
    final verticalPadding = widget.isTablet ? 20.0 : (widget.isSmallScreen ? 14.0 : 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: labelFontSize,
              color: const Color(0xFF333333),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          SizedBox(height: labelSpacing),
        ],
        
        // Text Field Container
        Container(
          height: widget.maxLines != null && widget.maxLines! > 1 ? null : fieldHeight,
          constraints: widget.maxLines != null && widget.maxLines! > 1 
              ? BoxConstraints(minHeight: fieldHeight) 
              : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: const Color(0xFFF5F5F5),
            border: _isFocused
                ? Border.all(
                    color: const Color(0xFF006837),
                    width: 2.0,
                  )
                : _hasError
                    ? Border.all(
                        color: const Color(0xFFE53E3E),
                        width: 2.0,
                      )
                    : Border.all(
                        color: Colors.transparent,
                        width: 2.0,
                      ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            inputFormatters: widget.inputFormatters,
            textAlignVertical: widget.maxLines != null && widget.maxLines! > 1 
                ? TextAlignVertical.top 
                : TextAlignVertical.center,
            style: TextStyle(
              fontSize: textFontSize,
              color: const Color(0xFF333333),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF9E9E9E),
                fontSize: hintFontSize,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              isDense: true,
            ),
            validator: null, // Handle validation manually
            ),
          ),
        ),
        
        // Error Message
        if (_hasError && _errorText != null)
          Padding(
            padding: EdgeInsets.only(
              top: labelSpacing, 
              left: widget.isSmallScreen ? 2 : 4
            ),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: const Color(0xFFE53E3E),
                fontSize: errorFontSize,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
