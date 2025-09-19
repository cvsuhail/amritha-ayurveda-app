import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/patient_card.dart';
import '../widgets/search_sort_section.dart';
import '../widgets/patient_list_app_bar.dart';
import '../widgets/patient_list_shimmer.dart';
import '../widgets/empty_patient_list.dart';
import '../widgets/loading_button.dart';
import '../widgets/reveal_animation_widget.dart';
import '../widgets/data_loading_reveal.dart';
import '../../data/models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = 
      GlobalKey<RefreshIndicatorState>();
  
  // Track which patient cards are expanded
  final Set<String> _expandedPatients = {};
  
  // Track which cards have been revealed (for animation)
  final Set<String> _revealedCards = {};
  
  // Track if data has been loaded for reveal animation
  bool _hasDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startEntryAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Use WidgetsBinding to ensure the widget tree is fully built before loading data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add a small delay to ensure all initialization is complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final success = await patientProvider.loadPatients();
      
      if (!success && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Debug: Print the error message to understand what's happening
        if (kDebugMode) {
          print('PatientListPage: Load failed with error: ${patientProvider.errorMessage}');
        }
        
        // Check if authentication is required - be more specific about auth errors
        if (patientProvider.errorMessage.contains('Authentication required') ||
            patientProvider.errorMessage.contains('login again') || 
            patientProvider.errorMessage.contains('Session expired') ||
            patientProvider.errorMessage.contains('Unauthorized')) {
          if (kDebugMode) {
            print('PatientListPage: Redirecting to login due to auth error');
          }
          await _handleAuthenticationRequired(authProvider);
        } else {
          // For other errors, just show the error message without redirecting
          if (kDebugMode) {
            print('PatientListPage: Showing error snackbar instead of redirecting');
          }
          _showErrorSnackBar(patientProvider.errorMessage);
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    
    // Reset revealed cards and data loaded state on refresh
    setState(() {
      _revealedCards.clear();
      _hasDataLoaded = false;
    });
    
    final success = await patientProvider.refreshPatients();
    
    if (!success && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if authentication is required - be more specific about auth errors
      if (patientProvider.errorMessage.contains('Authentication required') ||
          patientProvider.errorMessage.contains('login again') || 
          patientProvider.errorMessage.contains('Session expired') ||
          patientProvider.errorMessage.contains('Unauthorized')) {
        await _handleAuthenticationRequired(authProvider);
      } else {
        // For other errors, just show the error message without redirecting
        _showErrorSnackBar(patientProvider.errorMessage);
      }
    } else if (success && mounted) {
      _showSuccessSnackBar('Patient list refreshed successfully');
    }
  }

  Future<void> _handleAuthenticationRequired(AuthProvider authProvider) async {
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    patientProvider.searchPatients(query);
  }

  void _onSortChanged(String sortOption) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    patientProvider.sortPatients(sortOption);
  }




  void _onToggleExpanded(PatientModel patient) {
    setState(() {
      if (_expandedPatients.contains(patient.id)) {
        _expandedPatients.remove(patient.id);
      } else {
        _expandedPatients.add(patient.id);
      }
    });
  }

  void _onCardRevealed(String patientId) {
    setState(() {
      _revealedCards.add(patientId);
    });
  }

  void _onRegisterNow() {
    HapticFeedback.mediumImpact();
    // Navigate to registration page or show registration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening registration form...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }


  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error during logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back behavior
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showLogoutConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<PatientProvider>(
            builder: (context, patientProvider, child) {
              return Column(
                children: [
                  // App Bar
                  PatientListAppBar(
                    onBackPressed: () {
                      HapticFeedback.lightImpact();
                      _showLogoutConfirmation();
                    },
                    onNotificationPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),

                  // Search and Sort Section
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SearchSortSection(
                            searchController: _searchController,
                            selectedSortOption: patientProvider.sortOption,
                            onSearchChanged: _onSearchChanged,
                            onSortChanged: _onSortChanged,
                            isLoading: patientProvider.isLoading,
                          ),
                        ),
                      );
                    },
                  ),

                  // Patient List Content
                  Expanded(
                    child: _buildPatientListContent(patientProvider),
                  ),

                  // Register Now Button (Always visible, shows loading state)
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: LoadingButton(
                          isLoading: patientProvider.isLoading,
                          onPressed: patientProvider.isLoading ? null : _onRegisterNow,
                          text: 'Register Now',
                          loadingText: 'Loading Patients...',
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientListContent(PatientProvider patientProvider) {
    // Show loading shimmer - ensure it shows immediately during loading
    if (patientProvider.isLoading) {
      if (kDebugMode) {
        print('PatientListPage: Showing shimmer - isLoading: ${patientProvider.isLoading}');
      }
      // Reset data loaded state when loading starts
      _hasDataLoaded = false;
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: const PatientListShimmer(),
          );
        },
      );
    }

    // Show error state with retry option
    if (patientProvider.hasError && !patientProvider.hasPatients) {
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: EmptyPatientList(
              message: 'Failed to Load Patients',
              subtitle: patientProvider.errorMessage,
              onRefresh: _loadInitialData,
              showRefreshButton: true,
            ),
          );
        },
      );
    }

    // Show empty state when no patients
    if (!patientProvider.hasPatients) {
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: EmptyPatientList(
              message: 'No Patients Available',
              subtitle: 'There are no patients to display at the moment.\nPull down to refresh.',
              onRefresh: _onRefresh,
              showRefreshButton: false,
            ),
          );
        },
      );
    }

    // Show empty search results
    if (patientProvider.filteredPatients.isEmpty && 
        patientProvider.searchQuery.isNotEmpty) {
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: EmptySearchResults(
              searchQuery: patientProvider.searchQuery,
              onClearSearch: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
          );
        },
      );
    }

    // Mark data as loaded when we reach this point
    if (!_hasDataLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _hasDataLoaded = true;
        });
      });
    }

    // Show patient list with pull-to-refresh and reveal animations
    return DataLoadingReveal(
      isDataLoaded: _hasDataLoaded,
      delay: const Duration(milliseconds: 100),
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        color: const Color(0xFF2E7D32),
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          itemCount: patientProvider.filteredPatients.length,
          itemBuilder: (context, index) {
            final patient = patientProvider.filteredPatients[index];
            final hasBeenRevealed = _revealedCards.contains(patient.id);
            
            return RevealAnimationWidget(
              index: index,
              delay: const Duration(milliseconds: 50),
              shouldAnimate: _hasDataLoaded && !hasBeenRevealed,
              onRevealed: () => _onCardRevealed(patient.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: PatientCard(
                  patient: patient,
                  index: index + 1,
                  isExpanded: _expandedPatients.contains(patient.id),
                  onViewDetails: () => _onToggleExpanded(patient),
                  onToggleExpanded: () => _onToggleExpanded(patient),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
