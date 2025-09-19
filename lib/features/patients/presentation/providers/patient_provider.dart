import 'package:flutter/foundation.dart';
import '../../data/models/patient_model.dart';
import '../../../../core/services/api_service.dart';

class PatientProvider with ChangeNotifier {
  List<PatientModel> _patients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _sortOption = 'Date';

  // Getters
  List<PatientModel> get patients => _patients;
  List<PatientModel> get filteredPatients => _filteredPatients;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;
  bool get hasPatients => _patients.isNotEmpty;
  bool get hasError => _errorMessage.isNotEmpty;

  // Load patients from API
  Future<bool> loadPatients() async {
    if (_isRefreshing) return false; // Prevent multiple simultaneous loads
    
    _setLoading(true);
    _clearError();
    
    if (kDebugMode) {
      print('PatientProvider: Setting loading state to true');
    }
    
    try {
      if (kDebugMode) {
        print('PatientProvider: Loading patients...');
      }
      
      final result = await ApiService.getPatientList();
      
      if (result['success'] == true) {
        final List<dynamic> patientData = result['data'] ?? [];
        _patients = patientData
            .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (kDebugMode) {
          print('PatientProvider: Loaded ${_patients.length} patients');
        }
        
        _applyFiltersAndSort();
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to load patients');
        _setLoading(false);
        
        // Check if authentication is required
        if (result['requiresAuth'] == true) {
          _setError('Authentication required. Please login again.');
          return false; // Caller should handle authentication
        }
        
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('PatientProvider: Error loading patients: $e');
      }
      _setError('An unexpected error occurred while loading patients');
      _setLoading(false);
      return false;
    }
  }

  // Refresh patients (for pull-to-refresh)
  Future<bool> refreshPatients() async {
    if (_isLoading) return false; // Prevent refresh during initial load
    
    _setRefreshing(true);
    _clearError();
    
    try {
      if (kDebugMode) {
        print('PatientProvider: Refreshing patients...');
      }
      
      final result = await ApiService.getPatientList();
      
      if (result['success'] == true) {
        final List<dynamic> patientData = result['data'] ?? [];
        _patients = patientData
            .map((json) => PatientModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        if (kDebugMode) {
          print('PatientProvider: Refreshed ${_patients.length} patients');
        }
        
        _applyFiltersAndSort();
        _setRefreshing(false);
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to refresh patients');
        _setRefreshing(false);
        
        // Check if authentication is required
        if (result['requiresAuth'] == true) {
          _setError('Authentication required. Please login again.');
          return false; // Caller should handle authentication
        }
        
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('PatientProvider: Error refreshing patients: $e');
      }
      _setError('An unexpected error occurred while refreshing patients');
      _setRefreshing(false);
      return false;
    }
  }

  // Search functionality
  void searchPatients(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Sort functionality
  void sortPatients(String sortOption) {
    _sortOption = sortOption;
    _applyFiltersAndSort();
    notifyListeners();
  }


  // Apply filters and sorting
  void _applyFiltersAndSort() {
    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredPatients = List.from(_patients);
    } else {
      _filteredPatients = _patients
          .where((patient) =>
              patient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              patient.packageDescription
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              patient.assignedPerson
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    _filteredPatients.sort((a, b) {
      switch (_sortOption) {
        case 'Date':
          return b.date.compareTo(a.date); // Newest first
        case 'Name':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case 'Package':
          return a.packageDescription
              .toLowerCase()
              .compareTo(b.packageDescription.toLowerCase());
        default:
          return 0;
      }
    });
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _patients.clear();
    _filteredPatients.clear();
    _searchQuery = '';
    _sortOption = 'Date';
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = '';
    notifyListeners();
  }
}
