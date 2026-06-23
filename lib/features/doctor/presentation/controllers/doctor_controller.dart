import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../../../core/routes/app_routes.dart';

class DoctorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DoctorRepository _doctorRepository;

  DoctorController({DoctorRepository? doctorRepository})
      : _doctorRepository = doctorRepository ?? DoctorRepositoryImpl();

  // Observable variables
  final RxString _doctorName = ''.obs;
  final RxString _doctorSpecialization = ''.obs;
  final RxString _doctorId = ''.obs;
  final RxString _doctorEmail = ''.obs;
  final RxString _doctorPhone = ''.obs;
  final RxString _doctorNomorId = ''.obs;
  final RxBool _isLoading = false.obs;
  final RxInt _totalPatientsToday = 0.obs;
  final RxInt _completedPatientsToday = 0.obs;
  final RxInt _waitingPatientsToday = 0.obs;

  // Date selection
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<DateTime> _currentViewMonth = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final RxList<String> _activeDaysOfWeek = <String>[].obs;

  // Getters
  String get doctorName => _doctorName.value;
  String get doctorSpecialization => _doctorSpecialization.value;
  String get doctorId => _doctorId.value;
  String get doctorEmail => _doctorEmail.value;
  String get doctorPhone => _doctorPhone.value;
  String get doctorNomorId => _doctorNomorId.value;
  bool get isLoading => _isLoading.value;
  int get totalPatientsToday => _totalPatientsToday.value;
  int get completedPatientsToday => _completedPatientsToday.value;
  int get waitingPatientsToday => _waitingPatientsToday.value;

  DateTime get selectedDate => _selectedDate.value;
  DateTime get currentViewMonth => _currentViewMonth.value;
  List<String> get activeDaysOfWeek => _activeDaysOfWeek;
  
  bool get isTodaySelected {
    final now = DateTime.now();
    return _selectedDate.value.year == now.year &&
        _selectedDate.value.month == now.month &&
        _selectedDate.value.day == now.day;
  }

  List<DateTime> get availableDatesInMonth {
    final List<DateTime> dates = [];
    final month = _currentViewMonth.value;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    
    final Map<String, int> dayNameMap = {
      'Senin': DateTime.monday,
      'Selasa': DateTime.tuesday,
      'Rabu': DateTime.wednesday,
      'Kamis': DateTime.thursday,
      'Jumat': DateTime.friday,
      'Sabtu': DateTime.saturday,
      'Minggu': DateTime.sunday,
    };

    final activeWeekdays = _activeDaysOfWeek
        .map((dayName) => dayNameMap[dayName])
        .whereType<int>()
        .toList();

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(month.year, month.month, i);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (date.isBefore(today)) {
        continue;
      }

      if (activeWeekdays.contains(date.weekday)) {
        dates.add(date);
      }
    }
    
    return dates;
  }

  void nextMonth() {
    final current = _currentViewMonth.value;
    _currentViewMonth.value = DateTime(current.year, current.month + 1, 1);
  }
  
  void previousMonth() {
    final current = _currentViewMonth.value;
    final now = DateTime.now();
    final newMonth = DateTime(current.year, current.month - 1, 1);
    
    if (newMonth.year == now.year && newMonth.month < now.month) return;
    if (newMonth.year < now.year) return;
    
    _currentViewMonth.value = newMonth;
  }

  // Greeting based on time
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _validateDoctorSession();
  }

  Future<void> _validateDoctorSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.offAllNamed(AppRoutes.roleSelection);
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      final role = data?['role'] as String?;
      final isActive = data?['is_active'] != false;

      if (!userDoc.exists || role != 'dokter' || !isActive) {
        await _auth.signOut();
        Get.offAllNamed(AppRoutes.roleSelection);
        return;
      }

      _loadDoctorData();
      _loadDoctorSchedule();
      _loadQueueStats();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memverifikasi sesi dokter: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  // Load doctor data from Firestore
  Future<void> _loadDoctorData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _doctorId.value = user.uid;
        _doctorEmail.value = user.email ?? '';

        // Get detailed doctor data from doctors collection
        final doctorQuery = await _firestore
            .collection('doctors')
            .where('user_id', isEqualTo: user.uid)
            .limit(1)
            .get();

        if (doctorQuery.docs.isNotEmpty) {
          final doctorData = doctorQuery.docs.first.data();
          _doctorName.value = doctorData['nama_lengkap'] ?? '';
          _doctorSpecialization.value = doctorData['spesialisasi'] ?? '';
          _doctorPhone.value = doctorData['nomor_telepon'] ?? '';
          _doctorNomorId.value = doctorData['nomor_identifikasi'] ?? '';
        }

        // Fallback: jika nama masih kosong, coba dari users collection
        if (_doctorName.value.isEmpty) {
          final userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            _doctorName.value = userDoc.data()?['name'] ?? 'Dokter';
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data dokter: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadDoctorSchedule() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final scheduleQuery = await _firestore
            .collection('schedules')
            .where('doctor_id', isEqualTo: user.uid)
            .where('is_active', isEqualTo: true)
            .get();

        final Set<String> days = {};
        for (var doc in scheduleQuery.docs) {
          final data = doc.data();
          final daysOfWeek = List<String>.from(data['days_of_week'] ?? []);
          days.addAll(daysOfWeek);
        }
        _activeDaysOfWeek.value = days.toList();
        
        // If the initially selected date is not in available days, auto select the first available
        if (_activeDaysOfWeek.isNotEmpty && availableDatesInMonth.isNotEmpty) {
           final Map<String, int> dayNameMap = {
              'Senin': DateTime.monday, 'Selasa': DateTime.tuesday, 'Rabu': DateTime.wednesday,
              'Kamis': DateTime.thursday, 'Jumat': DateTime.friday, 'Sabtu': DateTime.saturday, 'Minggu': DateTime.sunday,
            };
           final activeWeekdays = _activeDaysOfWeek.map((dayName) => dayNameMap[dayName]).toList();
           if (!activeWeekdays.contains(_selectedDate.value.weekday)) {
              _selectedDate.value = availableDatesInMonth.first;
              _loadQueueStats();
           }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading schedule: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.roleSelection);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load queue statistics for today
  Future<void> _loadQueueStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final targetDate = _selectedDate.value;
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // Get all queues for this doctor today
      final queuesSnapshot = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      final total = queuesSnapshot.docs.length;
      final completed = queuesSnapshot.docs
          .where((doc) =>
              doc.data()['status'] == 'selesai' ||
              doc.data()['status'] == 'completed')
          .length;
      final waiting = queuesSnapshot.docs
          .where((doc) =>
              doc.data()['status'] == 'menunggu' ||
              doc.data()['status'] == 'waiting' ||
              doc.data()['status'] == 'rescheduled')
          .length;

      _totalPatientsToday.value = total;
      _completedPatientsToday.value = completed;
      _waitingPatientsToday.value = waiting;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading stats: $e');
    }
  }

  // Call next patient
  Future<void> callNextPatient() async {
    try {
      _isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null || !isTodaySelected) return;

      await _doctorRepository.callNextPatient(user.uid);

      Get.snackbar(
        'Berhasil',
        'Pasien berikutnya dipanggil',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh stats
      await _loadQueueStats();
    } on Exception catch (e) {
      final message = e.toString();
      if (message.contains('no_waiting_patient')) {
        Get.snackbar(
          'Info',
          'Tidak ada pasien yang menunggu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      Get.snackbar(
        'Error',
        'Gagal memanggil pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memanggil pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Mark current patient as completed
  Future<void> completeCurrentPatient() async {
    try {
      _isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null || !isTodaySelected) return;

      await _doctorRepository.completeCurrentPatient(user.uid);

      Get.snackbar(
        'Berhasil',
        'Pasien selesai dilayani',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh stats
      await _loadQueueStats();
    } on Exception catch (e) {
      final message = e.toString();
      if (message.contains('no_called_patient')) {
        Get.snackbar(
          'Info',
          'Tidak ada pasien yang sedang dipanggil',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyelesaikan pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Skip current patient (move to end)
  Future<void> skipCurrentPatient() async {
    try {
      _isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      try {
        await _doctorRepository.skipCurrentPatient(user.uid);

        Get.snackbar(
          'Info',
          'Pasien dilewati',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Refresh stats
        await _loadQueueStats();
      } on Exception catch (e) {
        if (e.toString().contains('no_called_patient')) {
          Get.snackbar(
            'Info',
            'Tidak ada pasien yang sedang dipanggil',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal melewati pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([_loadDoctorData(), _loadQueueStats()]);
  }

  Future<int> cancelDoctorSession(String reason) async {
    try {
      _isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Dokter belum login');
      }

      final affectedCount = await _doctorRepository.cancelDoctorSession(
        user.uid,
        _selectedDate.value,
        reason,
      );

      await _loadQueueStats();

      Get.snackbar(
        'Berhasil',
        '$affectedCount pasien terdampak dan sudah diberi notifikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return affectedCount;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return 0;
    } finally {
      _isLoading.value = false;
    }
  }

  // Handle date selection
  void selectDate(DateTime date) {
    _selectedDate.value = date;
    refreshData();
  }

  // Mark absence for selected date
  Future<void> markAbsenceForSelectedDate() async {
    try {
      _isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;

      final targetDate = _selectedDate.value;
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );
      final absenceId = '${user.uid}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';

      // Save as a deterministic document to avoid duplicate absence records
      await _firestore.collection('doctor_absences').doc(absenceId).set({
        'doctor_id': user.uid,
        'doctor_name': _doctorName.value,
        'date': Timestamp.fromDate(startOfDay),
        'created_at': FieldValue.serverTimestamp(),
        'status': 'reported', // e.g., 'reported', 'processed_by_admin'
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Berhasil',
        'Jadwal libur berhasil dikonfirmasi. Admin akan menginformasikan antrean pasien.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menandai jadwal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
