import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _backgroundFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntryAnimations() {
    // Start background animation immediately
    _backgroundController.forward();
    
    // Start logo animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoController.forward();
    });
    
    // Start form animation after logo animation
    Future.delayed(const Duration(milliseconds: 800), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    final orientation = mediaQuery.orientation;
    
    // Enhanced responsive breakpoints
    final isSmallPhone = screenHeight < 600 || (screenWidth < 360 && orientation == Orientation.portrait);
    final isMediumPhone = screenHeight >= 600 && screenHeight < 700 && screenWidth < 400;
    final isLargePhone = screenHeight >= 700 && screenHeight < 900 && screenWidth < 500;
    final isSmallTablet = screenWidth >= 600 && screenWidth < 800;
    final isLargeTablet = screenWidth >= 800 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final isLandscape = orientation == Orientation.landscape;
    
    // Dynamic calculations based on device type
    double getResponsiveValue({
      required double smallPhone,
      required double mediumPhone,
      required double largePhone,
      required double smallTablet,
      required double largeTablet,
      required double desktop,
    }) {
      if (isDesktop) return desktop;
      if (isLargeTablet) return largeTablet;
      if (isSmallTablet) return smallTablet;
      if (isLargePhone) return largePhone;
      if (isMediumPhone) return mediumPhone;
      return smallPhone;
    }
    
    // Dynamic top section height based on screen size, orientation and keyboard state
    double topSectionHeight;
    if (isKeyboardOpen) {
      if (isLandscape) {
        topSectionHeight = screenHeight * 0.08; // Minimal in landscape with keyboard
      } else {
        topSectionHeight = getResponsiveValue(
          smallPhone: screenHeight * 0.08,
          mediumPhone: screenHeight * 0.10,
          largePhone: screenHeight * 0.12,
          smallTablet: screenHeight * 0.15,
          largeTablet: screenHeight * 0.18,
          desktop: screenHeight * 0.20,
        );
      }
    } else {
      if (isLandscape) {
        topSectionHeight = screenHeight * 0.25; // Reasonable size in landscape
      } else {
        topSectionHeight = getResponsiveValue(
          smallPhone: screenHeight * 0.28,
          mediumPhone: screenHeight * 0.30,
          largePhone: screenHeight * 0.32,
          smallTablet: screenHeight * 0.35,
          largeTablet: screenHeight * 0.38,
          desktop: screenHeight * 0.40,
        );
      }
    }
    
    // Dynamic logo size with better scaling
    double logoSize = getResponsiveValue(
      smallPhone: 60.0,
      mediumPhone: 70.0,
      largePhone: 80.0,
      smallTablet: 100.0,
      largeTablet: 120.0,
      desktop: 140.0,
    );
    
    if (isKeyboardOpen) {
      logoSize *= isLandscape ? 0.6 : 0.7;
    }
    if (isLandscape && !isKeyboardOpen) {
      logoSize *= 0.8; // Slightly smaller in landscape
    }

    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true, // Essential for keyboard handling
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top section with blurred background and logo
                        AnimatedBuilder(
                          animation: _backgroundFadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _backgroundFadeAnimation,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                height: topSectionHeight,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/images/login-head-bg.png'),
                                    fit: BoxFit.cover, // Better scaling for different aspect ratios
                                    alignment: Alignment.center,
                                  ),
                                ),
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: isLandscape ? 6.0 : 8.0, 
                                      sigmaY: isLandscape ? 6.0 : 8.0
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Center(
                                        child: AnimatedBuilder(
                                          animation: Listenable.merge([_logoScaleAnimation, _logoRotationAnimation]),
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _logoScaleAnimation.value,
                                              child: Transform.rotate(
                                                angle: _logoRotationAnimation.value,
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  padding: EdgeInsets.all(
                                                    getResponsiveValue(
                                                      smallPhone: 8.0,
                                                      mediumPhone: 12.0,
                                                      largePhone: 16.0,
                                                      smallTablet: 20.0,
                                                      largeTablet: 24.0,
                                                      desktop: 28.0,
                                                    )
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/login-logo.png',
                                                    height: logoSize,
                                                    width: logoSize,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Login form section
                        Flexible(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_formSlideAnimation, _formFadeAnimation]),
                            builder: (context, child) {
                              return SlideTransition(
                                position: _formSlideAnimation,
                                child: FadeTransition(
                                  opacity: _formFadeAnimation,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight - topSectionHeight,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getResponsiveValue(
                                          smallPhone: 16.0,
                                          mediumPhone: 20.0,
                                          largePhone: 24.0,
                                          smallTablet: 32.0,
                                          largeTablet: 48.0,
                                          desktop: 64.0,
                                        ),
                                      ),
                                      child: LoginForm(
                                        isSmallPhone: isSmallPhone,
                                        isMediumPhone: isMediumPhone,
                                        isLargePhone: isLargePhone,
                                        isSmallTablet: isSmallTablet,
                                        isLargeTablet: isLargeTablet,
                                        isDesktop: isDesktop,
                                        isLandscape: isLandscape,
                                        getResponsiveValue: getResponsiveValue,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}