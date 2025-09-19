import 'package:amritha_ayurveda/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../patients/presentation/pages/patient_list_page.dart';
import 'minimal_text_field.dart';

class LoginForm extends StatefulWidget {
  final bool isSmallPhone;
  final bool isMediumPhone;
  final bool isLargePhone;
  final bool isSmallTablet;
  final bool isLargeTablet;
  final bool isDesktop;
  final bool isLandscape;
  final double Function({
    required double smallPhone,
    required double mediumPhone,
    required double largePhone,
    required double smallTablet,
    required double largeTablet,
    required double desktop,
  }) getResponsiveValue;

  const LoginForm({
    super.key,
    required this.isSmallPhone,
    required this.isMediumPhone,
    required this.isLargePhone,
    required this.isSmallTablet,
    required this.isLargeTablet,
    required this.isDesktop,
    required this.isLandscape,
    required this.getResponsiveValue,
  });

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

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutBack),
        );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeInOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
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
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    // Enhanced responsive spacing calculations
    final topSpacing = isKeyboardOpen
        ? widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 10.0 : 15.0,
            mediumPhone: widget.isLandscape ? 12.0 : 18.0,
            largePhone: widget.isLandscape ? 15.0 : 22.0,
            smallTablet: widget.isLandscape ? 18.0 : 25.0,
            largeTablet: widget.isLandscape ? 20.0 : 28.0,
            desktop: widget.isLandscape ? 22.0 : 30.0,
          )
        : widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 20.0 : 25.0,
            mediumPhone: widget.isLandscape ? 25.0 : 30.0,
            largePhone: widget.isLandscape ? 30.0 : 35.0,
            smallTablet: widget.isLandscape ? 35.0 : 40.0,
            largeTablet: widget.isLandscape ? 40.0 : 45.0,
            desktop: widget.isLandscape ? 45.0 : 50.0,
          );

    final titleSpacing = isKeyboardOpen
        ? widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 20.0 : 25.0,
            mediumPhone: widget.isLandscape ? 25.0 : 30.0,
            largePhone: widget.isLandscape ? 30.0 : 35.0,
            smallTablet: widget.isLandscape ? 35.0 : 40.0,
            largeTablet: widget.isLandscape ? 40.0 : 45.0,
            desktop: widget.isLandscape ? 45.0 : 50.0,
          )
        : widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 30.0 : 35.0,
            mediumPhone: widget.isLandscape ? 35.0 : 40.0,
            largePhone: widget.isLandscape ? 40.0 : 45.0,
            smallTablet: widget.isLandscape ? 45.0 : 50.0,
            largeTablet: widget.isLandscape ? 50.0 : 55.0,
            desktop: widget.isLandscape ? 55.0 : 60.0,
          );

    final buttonSpacing = isKeyboardOpen
        ? widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 15.0 : 20.0,
            mediumPhone: widget.isLandscape ? 18.0 : 25.0,
            largePhone: widget.isLandscape ? 22.0 : 28.0,
            smallTablet: widget.isLandscape ? 25.0 : 32.0,
            largeTablet: widget.isLandscape ? 28.0 : 35.0,
            desktop: widget.isLandscape ? 32.0 : 40.0,
          )
        : widget.getResponsiveValue(
            smallPhone: widget.isLandscape ? 25.0 : 30.0,
            mediumPhone: widget.isLandscape ? 30.0 : 35.0,
            largePhone: widget.isLandscape ? 35.0 : 40.0,
            smallTablet: widget.isLandscape ? 40.0 : 45.0,
            largeTablet: widget.isLandscape ? 45.0 : 50.0,
            desktop: widget.isLandscape ? 50.0 : 55.0,
          );

    final titleFontSize = widget.getResponsiveValue(
      smallPhone: widget.isLandscape ? 16.0 : 18.0,
      mediumPhone: widget.isLandscape ? 18.0 : 20.0,
      largePhone: widget.isLandscape ? 20.0 : 22.0,
      smallTablet: widget.isLandscape ? 22.0 : 24.0,
      largeTablet: widget.isLandscape ? 24.0 : 26.0,
      desktop: widget.isLandscape ? 26.0 : 28.0,
    );

    final fieldSpacing = widget.getResponsiveValue(
      smallPhone: 16.0,
      mediumPhone: 18.0,
      largePhone: 20.0,
      smallTablet: 22.0,
      largeTablet: 24.0,
      desktop: 26.0,
    );

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            label: 'Email',
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            isSmallScreen: widget.isSmallPhone,
                            isTablet: widget.isSmallTablet || widget.isLargeTablet || widget.isDesktop,
                            isLandscape: widget.isLandscape,
                          ),

                          SizedBox(height: fieldSpacing),

                          // Password field
                          MinimalTextField(
                            key: _passwordFieldKey,
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Enter password',
                            obscureText: true,
                            validator: _validatePassword,
                            isSmallScreen: widget.isSmallPhone,
                            isTablet: widget.isSmallTablet || widget.isLargeTablet || widget.isDesktop,
                            isLandscape: widget.isLandscape,
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
                              height: widget.getResponsiveValue(
                                smallPhone: 48.0,
                                mediumPhone: 52.0,
                                largePhone: 56.0,
                                smallTablet: 60.0,
                                largeTablet: 64.0,
                                desktop: 68.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3D704D,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: authProvider.isLoading
                                      ? null
                                      : _handleSubmit,
                                  onTapDown: (_) => _buttonController.forward(),
                                  onTapUp: (_) => _buttonController.reverse(),
                                  onTapCancel: () =>
                                      _buttonController.reverse(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: authProvider.isLoading
                                        ? SizedBox(
                                            height: widget.getResponsiveValue(
                                              smallPhone: 18.0,
                                              mediumPhone: 20.0,
                                              largePhone: 22.0,
                                              smallTablet: 24.0,
                                              largeTablet: 26.0,
                                              desktop: 28.0,
                                            ),
                                            width: widget.getResponsiveValue(
                                              smallPhone: 18.0,
                                              mediumPhone: 20.0,
                                              largePhone: 22.0,
                                              smallTablet: 24.0,
                                              largeTablet: 26.0,
                                              desktop: 28.0,
                                            ),
                                            child: const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Login',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: widget.getResponsiveValue(
                                                smallPhone: 14.0,
                                                mediumPhone: 16.0,
                                                largePhone: 18.0,
                                                smallTablet: 20.0,
                                                largeTablet: 22.0,
                                                desktop: 24.0,
                                              ),
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

                    // Success/Error messages
                    if (authProvider.state == AuthState.error)
                      FadeTransition(
                        opacity: _formFadeAnimation,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: widget.getResponsiveValue(
                              smallPhone: 12.0,
                              mediumPhone: 14.0,
                              largePhone: 16.0,
                              smallTablet: 18.0,
                              largeTablet: 20.0,
                              desktop: 22.0,
                            ),
                            bottom: widget.getResponsiveValue(
                              smallPhone: 12.0,
                              mediumPhone: 14.0,
                              largePhone: 16.0,
                              smallTablet: 18.0,
                              largeTablet: 20.0,
                              desktop: 22.0,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            widget.getResponsiveValue(
                              smallPhone: 10.0,
                              mediumPhone: 12.0,
                              largePhone: 14.0,
                              smallTablet: 16.0,
                              largeTablet: 18.0,
                              desktop: 20.0,
                            ),
                          ),
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
                              fontSize: widget.getResponsiveValue(
                                smallPhone: 11.0,
                                mediumPhone: 12.0,
                                largePhone: 13.0,
                                smallTablet: 14.0,
                                largeTablet: 15.0,
                                desktop: 16.0,
                              ),
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    if (authProvider.state == AuthState.authenticated)
                      FadeTransition(
                        opacity: _formFadeAnimation,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: widget.getResponsiveValue(
                              smallPhone: 12.0,
                              mediumPhone: 14.0,
                              largePhone: 16.0,
                              smallTablet: 18.0,
                              largeTablet: 20.0,
                              desktop: 22.0,
                            ),
                            bottom: widget.getResponsiveValue(
                              smallPhone: 12.0,
                              mediumPhone: 14.0,
                              largePhone: 16.0,
                              smallTablet: 18.0,
                              largeTablet: 20.0,
                              desktop: 22.0,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            widget.getResponsiveValue(
                              smallPhone: 10.0,
                              mediumPhone: 12.0,
                              largePhone: 14.0,
                              smallTablet: 16.0,
                              largeTablet: 18.0,
                              desktop: 20.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F7E6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Login successful! Welcome back.',
                            style: TextStyle(
                              color: const Color(0xFF2E7D32),
                              fontSize: widget.getResponsiveValue(
                                smallPhone: 11.0,
                                mediumPhone: 12.0,
                                largePhone: 13.0,
                                smallTablet: 14.0,
                                largeTablet: 15.0,
                                desktop: 16.0,
                              ),
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    // Add minimal spacing and terms directly after button
                    SizedBox(
                      height: widget.getResponsiveValue(
                        smallPhone: screenHeight * 0.06,
                        mediumPhone: screenHeight * 0.07,
                        largePhone: screenHeight * 0.08,
                        smallTablet: screenHeight * 0.09,
                        largeTablet: screenHeight * 0.10,
                        desktop: screenHeight * 0.12,
                      ),
                    ),

                    // Terms and conditions
                    if (!isKeyboardOpen || widget.isLandscape)
                      FadeTransition(
                        opacity: _formFadeAnimation,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF333333),
                              fontSize: widget.getResponsiveValue(
                                smallPhone: 9.0,
                                mediumPhone: 10.0,
                                largePhone: 11.0,
                                smallTablet: 12.0,
                                largeTablet: 13.0,
                                desktop: 14.0,
                              ),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'By creating or logging into an account you are agreeing\nwith our ',
                              ),
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
                  ],
                ),
              ),
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
    // Removed email format validation to allow usernames like 'test_user'
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
        authProvider.login(email, password).then((_) async {
          if (authProvider.state == AuthState.authenticated) {
            // Add a small delay to ensure token is properly stored
            await Future.delayed(const Duration(milliseconds: 500));
            _navigateToPatientList();
          }
        });
      } else {
        authProvider.register(email, password).then((_) async {
          if (authProvider.state == AuthState.authenticated) {
            // Add a small delay to ensure token is properly stored
            await Future.delayed(const Duration(milliseconds: 500));
            _navigateToPatientList();
          }
        });
      }
    }
    // If validation fails, the MinimalTextField will automatically show errors
  }

  void _navigateToPatientList() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PatientListPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
      (route) => false, // Remove all previous routes
    );
  }
}
