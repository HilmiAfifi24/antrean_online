import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/usecases/get_completed_queues.dart';

class DoctorHistoryController extends GetxController {
  late final GetCompletedQueues getCompletedQueues;

  DoctorHistoryController({
    required this.getCompletedQueues,
  });

  final RxList<QueueEntity> completedQueues = <QueueEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  
  late DateTime selectedDate;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    
    // Retrieve date from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    selectedDate = _resolveSelectedDate(args?['date']);

    _loadHistory();
  }

  DateTime _resolveSelectedDate(dynamic rawDate) {
    if (rawDate is DateTime) {
      return rawDate;
    }
    if (rawDate is Timestamp) {
      return rawDate.toDate();
    }
    if (rawDate is String && rawDate.isNotEmpty) {
      return DateTime.tryParse(rawDate) ?? DateTime.now();
    }
    return DateTime.now();
  }

  void _loadHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      error.value = 'User tidak ditemukan';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    _subscription?.cancel();
    _subscription = getCompletedQueues(user.uid, selectedDate).listen(
      (queues) {
        completedQueues.value = queues;
        isLoading.value = false;
      },
      onError: (e) {
        error.value = 'Gagal memuat riwayat: $e';
        isLoading.value = false;
      },
    );
  }

  void refreshData() {
    _loadHistory();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
