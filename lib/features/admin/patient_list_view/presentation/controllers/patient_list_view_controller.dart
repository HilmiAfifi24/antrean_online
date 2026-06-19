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
  final RxnString _errorMessage = RxnString();

  // Stream subscription
  StreamSubscription? _patientsSubscription;

  // Getters
  List<PatientListEntity> get patients => _patients;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String? get errorMessage => _errorMessage.value;

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
    final nextDay = startOfDay.add(const Duration(days: 1));
    
    return _patients.where((patient) {
      return !patient.createdAt.isBefore(startOfDay) &&
             patient.createdAt.isBefore(nextDay);
    }).length;
  }

  int get thisWeekRegistrations {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));
    final nextWeek = startOfWeek.add(const Duration(days: 7));
    
    return _patients.where((patient) {
      return !patient.createdAt.isBefore(startOfWeek) &&
             patient.createdAt.isBefore(nextWeek);
    }).length;
  }

  int get thisMonthRegistrations {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return _patients.where((patient) {
      return !patient.createdAt.isBefore(startOfMonth) &&
             patient.createdAt.isBefore(nextMonth);
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
    _errorMessage.value = null;
    _patientsSubscription?.cancel();
    
    _patientsSubscription = getAllPatients().listen(
      (patients) {
        if (isClosed) return;
        _patients.value = patients;
        _isLoading.value = false;
        _errorMessage.value = null;
      },
      onError: (error) {
        if (isClosed) return;
        _isLoading.value = false;
        _errorMessage.value = 'Gagal memuat data pasien: $error';
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
