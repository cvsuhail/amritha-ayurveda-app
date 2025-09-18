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
    
    // Responsive calculations
    final isSmallScreen = screenHeight < 600;
    final isMediumScreen = screenHeight >= 600 && screenHeight < 800;
    final isTablet = screenWidth > 600;
    
    // Dynamic top section height based on screen size and keyboard state
    double topSectionHeight;
    if (isKeyboardOpen) {
      topSectionHeight = isSmallScreen ? screenHeight * 0.20 : screenHeight * 0.25;
    } else {
      if (isSmallScreen) {
        topSectionHeight = screenHeight * 0.30;
      } else if (isMediumScreen) {
        topSectionHeight = screenHeight * 0.35;
      } else {
        topSectionHeight = screenHeight * 0.40;
      }
    }
    
    // Dynamic logo size
    double logoSize = isTablet ? 140 : (isSmallScreen ? 80 : 120);
    if (isKeyboardOpen) {
      logoSize *= 0.7; // Reduce logo size when keyboard is open
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
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
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
                                                  padding: EdgeInsets.all(isKeyboardOpen ? 10 : 20),
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
                                        horizontal: isTablet ? 48.0 : 24.0,
                                      ),
                                      child: const LoginForm(),
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