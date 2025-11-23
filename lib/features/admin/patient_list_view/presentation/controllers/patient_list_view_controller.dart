import 'package:get/get.dart';
import 'dart:async';
import '../../domain/entities/patient_list_entity.dart';
import '../../domain/usecases/get_all_patients.dart';

class PatientListViewController extends GetxController {
  final GetAllPatients getAllPatients;

  PatientListViewController({required this.getAllPatients});

  // Observable variables
  final RxList<PatientListEntity> _patients = <PatientListEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;

  // Stream subscription
  StreamSubscription? _patientsSubscription;

  // Getters
  List<PatientListEntity> get patients => _patients;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;

  // Filtered patients based on search query
  List<PatientListEntity> get filteredPatients {
    if (_searchQuery.value.isEmpty) {
      return _patients;
    }
    
    final query = _searchQuery.value.toLowerCase();
    return _patients.where((patient) {
      return patient.name.toLowerCase().contains(query) ||
             patient.email.toLowerCase().contains(query);
    }).toList();
  }

  // Statistics
  int get totalPatients => _patients.length;
  int get todayRegistrations {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return _patients.where((patient) {
      return patient.createdAt.isAfter(startOfDay) && 
             patient.createdAt.isBefore(endOfDay);
    }).length;
  }

  int get thisWeekRegistrations {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday));
    
    return _patients.where((patient) {
      return patient.createdAt.isAfter(startOfWeek);
    }).length;
  }

  int get thisMonthRegistrations {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return _patients.where((patient) {
      return patient.createdAt.isAfter(startOfMonth);
    }).length;
  }

  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
  }

  @override
  void onClose() {
    _patientsSubscription?.cancel();
    super.onClose();
  }

  // Setup realtime listener for patients
  void _setupRealtimeListener() {
    _isLoading.value = true;
    _patientsSubscription?.cancel();
    
    _patientsSubscription = getAllPatients().listen(
      (patients) {
        _patients.value = patients;
        _isLoading.value = false;
      },
      onError: (error) {
        _isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat data pasien: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  // Refresh data
  Future<void> refreshData() async {
    _setupRealtimeListener();
  }
}
