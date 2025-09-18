import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_strings.dart';
import 'minimal_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFieldKey = GlobalKey<MinimalTextFieldState>();
  final _passwordFieldKey = GlobalKey<MinimalTextFieldState>();
  
  late AnimationController _titleController;
  late AnimationController _formController;
  late AnimationController _buttonController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutBack,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _titleController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    
    // Responsive calculations
    final isSmallScreen = screenHeight < 600;
    final isTablet = screenWidth > 600;
    
    // Dynamic spacing based on screen size and keyboard state
    final topSpacing = isKeyboardOpen 
        ? (isSmallScreen ? 20.0 : 30.0)
        : (isSmallScreen ? 30.0 : 40.0);
    
    final titleSpacing = isKeyboardOpen
        ? (isSmallScreen ? 30.0 : 40.0)
        : (isSmallScreen ? 40.0 : 50.0);
    
    final buttonSpacing = isKeyboardOpen
        ? (isSmallScreen ? 25.0 : 30.0)
        : (isSmallScreen ? 30.0 : 40.0);
    
    final titleFontSize = isTablet ? 26.0 : (isSmallScreen ? 18.0 : 22.0);
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: topSpacing),
              
              // Title
              SlideTransition(
                position: _titleSlideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Or Register To Book',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                        fontSize: titleFontSize,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      'Your Appointments',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                        fontSize: titleFontSize,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: titleSpacing),
              
              // Form Fields
              FadeTransition(
                opacity: _formFadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email field
                    MinimalTextField(
                      key: _emailFieldKey,
                      controller: _emailController,
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    
                    // Password field
                    MinimalTextField(
                      key: _passwordFieldKey,
                      controller: _passwordController,
                      hintText: 'Enter password',
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: buttonSpacing),
              
              // Login Button
              FadeTransition(
                opacity: _formFadeAnimation,
                child: AnimatedBuilder(
                  animation: _buttonScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: isSmallScreen ? 52 : 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF3D704D),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3D704D).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: authProvider.isLoading ? null : _handleSubmit,
                            onTapDown: (_) => _buttonController.forward(),
                            onTapUp: (_) => _buttonController.reverse(),
                            onTapCancel: () => _buttonController.reverse(),
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: authProvider.isLoading
                                  ? SizedBox(
                                      height: isSmallScreen ? 20 : 24,
                                      width: isSmallScreen ? 20 : 24,
                                      child: const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 16 : 18,
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
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 20 : 30),
              
              // Error message
              if (authProvider.state == AuthState.error)
                FadeTransition(
                  opacity: _formFadeAnimation,
                  child: Container(
                    margin: EdgeInsets.only(bottom: isSmallScreen ? 20 : 30),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF6B6B),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      authProvider.errorMessage,
                      style: TextStyle(
                        color: const Color(0xFFD63031),
                        fontSize: isSmallScreen ? 12 : 14,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              // Flexible spacing instead of Spacer to prevent overflow
              if (!isKeyboardOpen) ...[
                SizedBox(height: isSmallScreen ? 20 : 40),
                
                // Terms and conditions
                FadeTransition(
                  opacity: _formFadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 16.0 : 8.0),
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color(0xFF333333),
                          fontSize: isSmallScreen ? 10 : (isTablet ? 14 : 12),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          const TextSpan(text: 'By creating or logging into an account you are agreeing\nwith our '),
                          const TextSpan(
                            text: 'Terms and Conditions',
                            style: TextStyle(
                              color: Color(0xFF0028FC),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          const TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFF0028FC),
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: isKeyboardOpen ? 20 : 30),
            ],
          ),
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  void _handleSubmit() {
    // Validate both fields using their keys
    final emailValid = _emailFieldKey.currentState?.validate() ?? false;
    final passwordValid = _passwordFieldKey.currentState?.validate() ?? false;
    
    if (emailValid && passwordValid) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (authProvider.isLoginMode) {
        authProvider.login(email, password);
      } else {
        authProvider.register(email, password);
      }
    }
    // If validation fails, the MinimalTextField will automatically show errors
  }
}