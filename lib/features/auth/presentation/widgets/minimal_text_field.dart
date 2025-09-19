import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MinimalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const MinimalTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Minimal Text Field Container
        Container(
          height: widget.maxLines != null && widget.maxLines! > 1 ? null : 56,
          constraints: widget.maxLines != null && widget.maxLines! > 1 
              ? const BoxConstraints(minHeight: 56) 
              : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFF5F5F5),
            border: _isFocused
                ? Border.all(
                    color: const Color(0xFF3D704D),
                    width: 1.5,
                  )
                : _hasError
                    ? Border.all(
                        color: const Color(0xFFFF6B6B),
                        width: 1.5,
                      )
                    : null,
          ),
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
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF999999).withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: true,
            ),
            validator: null, // Handle validation manually
          ),
        ),
        
        // Error Message
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Color(0xFFFF6B6B),
                fontSize: 12,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
