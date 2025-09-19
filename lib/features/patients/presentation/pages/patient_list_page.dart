import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/patient_card.dart';
import '../widgets/simple_shimmer.dart';
import '../../data/models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/pages/register_page.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = 
      GlobalKey<RefreshIndicatorState>();
  
  // Track which patient cards are expanded
  final Set<String> _expandedPatients = {};
  
  String _selectedSortOption = 'Date';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }


  Future<void> _loadInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final success = await patientProvider.loadPatients();
      
      if (!success && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        if (kDebugMode) {
          print('PatientListPage: Load failed with error: ${patientProvider.errorMessage}');
        }
        
        if (patientProvider.errorMessage.contains('Authentication required') ||
            patientProvider.errorMessage.contains('login again') || 
            patientProvider.errorMessage.contains('Session expired') ||
            patientProvider.errorMessage.contains('Unauthorized')) {
          if (kDebugMode) {
            print('PatientListPage: Redirecting to login due to auth error');
          }
          await _handleAuthenticationRequired(authProvider);
        } else {
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
    
    final success = await patientProvider.refreshPatients();
    
    if (!success && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (patientProvider.errorMessage.contains('Authentication required') ||
          patientProvider.errorMessage.contains('login again') || 
          patientProvider.errorMessage.contains('Session expired') ||
          patientProvider.errorMessage.contains('Unauthorized')) {
        await _handleAuthenticationRequired(authProvider);
      } else {
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
    setState(() {
      _selectedSortOption = sortOption;
    });
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


  void _onRegisterNow() {
    HapticFeedback.mediumImpact();
    // Navigate to registration page with smooth transition
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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
                  // Custom App Bar
                  _buildAppBar(),

                  // Search and Sort Section
                  _buildSearchAndSort(patientProvider),

                  // Patient List Content
                  Expanded(
                    child: _buildPatientListContent(patientProvider),
                  ),

                  // Register Now Button
                  _buildRegisterButton(patientProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showLogoutConfirmation();
            },
            child: Container(
              width: 40,
              height: 40,
              child: Center(
                child: Image.asset(
                  'assets/icons/back.png',
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Notification Button
          GestureDetector(
            onTap: () {
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
            child: Container(
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/icons/notificaion.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(PatientProvider patientProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar with Button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for treatments',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Search Button
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Search',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Sort Section
          Row(
            children: [
              const Text(
                'Sort by :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              // Sort Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSortOption,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                    items: ['Date', 'Name', 'Amount'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _onSortChanged(newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(PatientProvider patientProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: patientProvider.isLoading ? null : _onRegisterNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          patientProvider.isLoading ? 'Loading...' : 'Register Now',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildPatientListContent(PatientProvider patientProvider) {
    // Show loading state with shimmer
    if (patientProvider.isLoading) {
      return const PatientListShimmer();
    }

    // Show error state with retry option
    if (patientProvider.hasError && !patientProvider.hasPatients) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Patients',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              patientProvider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty state when no patients
    if (!patientProvider.hasPatients) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Patients Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no patients to display at the moment.\nPull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    // Show empty search results
    if (patientProvider.filteredPatients.isEmpty && 
        patientProvider.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No patients found for "${patientProvider.searchQuery}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    // Show optimized patient list with smooth scrolling
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        itemCount: patientProvider.filteredPatients.length,
        physics: const AlwaysScrollableScrollPhysics(), // Ensures smooth scrolling
        itemBuilder: (context, index) {
          final patient = patientProvider.filteredPatients[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: PatientCard(
              patient: patient,
              index: index + 1,
              isExpanded: _expandedPatients.contains(patient.id),
              onViewDetails: () => _onToggleExpanded(patient),
              onToggleExpanded: () => _onToggleExpanded(patient),
            ),
          );
        },
      ),
    );
  }
}
