import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/usecases/get_queue_history.dart';

class QueueHistoryController extends GetxController {
  final GetQueueHistory getQueueHistory;

  QueueHistoryController({required this.getQueueHistory});

  final RxList<QueueEntity> _history = <QueueEntity>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _errorMessage = ''.obs;

  List<QueueEntity> get history => _history.toList();
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _errorMessage.value = 'Pengguna tidak ditemukan';
        return;
      }

      final result = await getQueueHistory(user.uid);
      _history.value = result;
    } catch (e) {
      _errorMessage.value = 'Gagal memuat riwayat: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Gagal memuat riwayat antrean',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
