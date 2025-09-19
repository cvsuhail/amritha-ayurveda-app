import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/patient_card.dart';
import '../widgets/search_sort_section.dart';
import '../widgets/patient_list_app_bar.dart';
import '../../data/models/patient_model.dart';
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
  String _selectedSortOption = 'Date';
  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  PatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPatients();
    _startEntryAnimations();
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
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _loadPatients() {
    // Sample data matching the image
    _patients = [
      PatientModel(
        id: '1',
        name: 'Vikram Singh',
        packageDescription: 'Couple Combo Package (Rejuvenation Therapy)',
        date: DateTime(2024, 1, 31),
        assignedPerson: 'Jithesh',
      ),
      PatientModel(
        id: '2',
        name: 'Priya Sharma',
        packageDescription: 'Wellness Package (Detox Therapy)',
        date: DateTime(2024, 2, 1),
        assignedPerson: 'Dr. Kumar',
      ),
      PatientModel(
        id: '3',
        name: 'Rajesh Patel',
        packageDescription: 'Family Package (Stress Relief)',
        date: DateTime(2024, 2, 2),
        assignedPerson: 'Anita',
      ),
      PatientModel(
        id: '4',
        name: 'Sneha Reddy',
        packageDescription: 'Premium Package (Anti-Aging)',
        date: DateTime(2024, 2, 3),
        assignedPerson: 'Dr. Singh',
      ),
      PatientModel(
        id: '5',
        name: 'Amit Kumar',
        packageDescription: 'Basic Package (Relaxation)',
        date: DateTime(2024, 2, 4),
        assignedPerson: 'Jithesh',
      ),
    ];
    _filteredPatients = List.from(_patients);
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = List.from(_patients);
      } else {
        _filteredPatients = _patients
            .where((patient) =>
                patient.name.toLowerCase().contains(query.toLowerCase()) ||
                patient.packageDescription
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSortChanged(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      _filteredPatients.sort((a, b) {
        switch (sortOption) {
          case 'Date':
            return b.date.compareTo(a.date); // Newest first
          case 'Name':
            return a.name.compareTo(b.name);
          case 'Package':
            return a.packageDescription.compareTo(b.packageDescription);
          default:
            return 0;
        }
      });
    });
  }

  void _onViewDetails(PatientModel patient) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Show details dialog or navigate to details page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Package: ${patient.packageDescription}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(patient.date)}'),
            const SizedBox(height: 8),
            Text('Assigned to: ${patient.assignedPerson}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onPatientSelected(PatientModel patient) {
    setState(() {
      _selectedPatient = patient;
    });
    HapticFeedback.lightImpact();
  }

  void _onRegisterNow() {
    if (_selectedPatient == null) return;
    
    HapticFeedback.mediumImpact();
    // Navigate to registration page or show registration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registering ${_selectedPatient!.name}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
        child: Column(
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
                      selectedSortOption: _selectedSortOption,
                      onSearchChanged: _onSearchChanged,
                      onSortChanged: _onSortChanged,
                    ),
                  ),
                );
              },
            ),

            // Patient List
            Expanded(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _filteredPatients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No patients found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search criteria',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            itemCount: _filteredPatients.length,
                            itemBuilder: (context, index) {
                              final patient = _filteredPatients[index];
                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 300 + (index * 100),
                                ),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: PatientCard(
                                  patient: patient,
                                  index: index + 1,
                                  isSelected: _selectedPatient?.id == patient.id,
                                  onViewDetails: () => _onViewDetails(patient),
                                  onPatientSelected: () => _onPatientSelected(patient),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),

            // Register Now Button
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedPatient != null ? _onRegisterNow : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPatient != null 
                              ? const Color(0xFF2E7D32) 
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          elevation: _selectedPatient != null ? 4 : 0,
                          shadowColor: _selectedPatient != null 
                              ? const Color(0xFF2E7D32).withOpacity(0.3) 
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
