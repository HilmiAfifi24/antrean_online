import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _loadDoctorData();
    _loadQueueStats();
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

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login', parameters: {'role': 'doctor'});
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

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Get all queues for this doctor today
      final queuesSnapshot = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      final total = queuesSnapshot.docs.length;
      final completed = queuesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'selesai')
          .length;
      final waiting = queuesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'menunggu')
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
      if (user == null) return;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Find next waiting patient
      final waitingQueues = await _firestore
          .collection('queues')
          .where('doctor_id', isEqualTo: user.uid)
          .where('appointment_date', isEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'menunggu')
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
      if (user == null) return;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

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

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

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

      // Update status back to 'menunggu'
      final queueDoc = calledQueues.docs.first;
      await _firestore.collection('queues').doc(queueDoc.id).update({
        'status': 'menunggu',
        'skipped_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Info',
        'Pasien dilewati',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh stats
      await _loadQueueStats();
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
}
