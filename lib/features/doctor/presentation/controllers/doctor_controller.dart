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
      // Error loading stats
    }
  }

  // Call next patient
  Future<void> callNextPatient() async {
    try {
      _isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null || !isTodaySelected) return;

      final targetDate = _selectedDate.value;
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // Find next waiting patient
      final waitingQueues = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', whereIn: ['menunggu', 'waiting', 'rescheduled'])
          .orderBy('queue_number')
          .limit(1)
          .get();

      if (waitingQueues.docs.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada pasien yang menunggu',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Update status to 'dipanggil'
      final queueDoc = waitingQueues.docs.first;
      await _firestore.collection('queues').doc(queueDoc.id).update({
        'status': 'dipanggil',
        'called_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Berhasil',
        'Pasien ${queueDoc.data()['patient_name']} dipanggil',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh stats
      await _loadQueueStats();
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

      final targetDate = _selectedDate.value;
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      // Find currently called patient
      final calledQueues = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'dipanggil')
          .limit(1)
          .get();

      if (calledQueues.docs.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada pasien yang sedang dipanggil',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Update status to 'selesai'
      final queueDoc = calledQueues.docs.first;
      await _firestore.collection('queues').doc(queueDoc.id).update({
        'status': 'selesai',
        'completed_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Berhasil',
        'Pasien selesai dilayani',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh stats
      await _loadQueueStats();
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

      // Use repository implementation to handle skip logic (move to end)
      final DoctorRepository repo = DoctorRepositoryImpl();
      try {
        await repo.skipCurrentPatient(user.uid);

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

      final targetDate = _selectedDate.value;
      final startOfDay = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
      );

      final schedulesSnapshot = await _firestore
          .collection('schedules')
          .where('doctor_id', isEqualTo: user.uid)
          .where('is_active', isEqualTo: true)
          .get();

      if (schedulesSnapshot.docs.isEmpty) {
        throw Exception('Jadwal dokter tidak ditemukan');
      }

      final queueSnapshot = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', whereIn: [
            'menunggu',
            'waiting',
            'dipanggil',
            'ongoing',
            'rescheduled',
          ])
          .get();

      if (queueSnapshot.docs.isEmpty) {
        throw Exception('Tidak ada antrean aktif pada sesi ini');
      }

      final affectedQueues = queueSnapshot.docs;
      final scheduleCounts = <String, int>{};
      for (final doc in affectedQueues) {
        final scheduleId = doc.data()['schedule_id'] ?? '';
        if (scheduleId.isNotEmpty) {
          scheduleCounts[scheduleId] = (scheduleCounts[scheduleId] ?? 0) + 1;
        }
      }

      await _firestore.runTransaction((transaction) async {
        for (final scheduleDoc in schedulesSnapshot.docs) {
          final scheduleDoctorId = scheduleDoc.data()['doctor_id'] ?? '';
          if (scheduleDoctorId != user.uid) {
            throw Exception('Dokter hanya dapat membatalkan jadwal miliknya');
          }
        }

        final scheduleCurrentPatients = <String, int>{};
        for (final scheduleId in scheduleCounts.keys) {
          final scheduleDoc = await transaction.get(
            _firestore.collection('schedules').doc(scheduleId),
          );
          scheduleCurrentPatients[scheduleId] =
              (scheduleDoc.data()?['current_patients'] as num?)?.toInt() ?? 0;
        }

        for (final doc in affectedQueues) {
          transaction.update(doc.reference, {
            'status': 'cancelled_by_doctor',
            'cancellation_reason': reason,
            'cancelled_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }

        for (final entry in scheduleCounts.entries) {
          final current = scheduleCurrentPatients[entry.key] ?? 0;
          final next = current - entry.value;
          transaction.update(
            _firestore.collection('schedules').doc(entry.key),
            {'current_patients': next > 0 ? next : 0},
          );
        }
      });

      await notifyAffectedPatients(affectedQueues, reason);
      await _loadQueueStats();

      Get.snackbar(
        'Berhasil',
        '${affectedQueues.length} pasien terdampak dan sudah diberi notifikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return affectedQueues.length;
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

  Future<void> notifyAffectedPatients(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> queues,
    String reason,
  ) async {
    final batch = _firestore.batch();
    for (final queueDoc in queues) {
      final queue = queueDoc.data();
      final notificationRef = _firestore.collection('patient_notifications').doc();
      batch.set(notificationRef, {
        'patient_id': queue['patient_id'] ?? '',
        'queue_id': queueDoc.id,
        'doctor_id': queue['doctor_id'] ?? '',
        'doctor_name': queue['doctor_name'] ?? doctorName,
        'schedule_id': queue['schedule_id'] ?? '',
        'title': 'Jadwal Dokter Dibatalkan',
        'message':
            'Jadwal dokter dibatalkan. Silakan lakukan penjadwalan ulang melalui aplikasi.',
        'reason': reason,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
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
