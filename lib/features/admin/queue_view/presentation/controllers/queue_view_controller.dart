import 'package:get/get.dart';
import 'dart:async';
import '../../domain/entities/queue_admin_entity.dart';
import '../../domain/usecases/get_today_queues.dart';

class QueueViewController extends GetxController {
  final GetQueuesByDate getQueuesByDate;

  QueueViewController({required this.getQueuesByDate});

  // Observable variables
  final RxList<QueueAdminEntity> _queues = <QueueAdminEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedStatus = 'Semua'.obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  // Stream subscription
  StreamSubscription? _queuesSubscription;

  // Getters
  List<QueueAdminEntity> get queues => _queues;
  bool get isLoading => _isLoading.value;
  String get selectedStatus => _selectedStatus.value;
  DateTime get selectedDate => _selectedDate.value;

  // Filtered queues based on selected status
  List<QueueAdminEntity> get filteredQueues {
    if (_selectedStatus.value == 'Semua') {
      return _queues;
    }
    return _queues.where((queue) {
      return queue.statusText.toLowerCase() == _selectedStatus.value.toLowerCase();
    }).toList();
  }

  // Statistics
  int get totalQueues => _queues.length;
  int get waitingQueues => _queues.where((q) => q.status == 'menunggu').length;
  int get calledQueues => _queues.where((q) => q.status == 'dipanggil').length;
  int get completedQueues => _queues.where((q) => q.status == 'selesai').length;
  int get cancelledQueues => _queues.where((q) => q.status == 'dibatalkan').length;

  @override
  void onInit() {
    super.onInit();
    _setupRealtimeListener();
  }

  @override
  void onClose() {
    _queuesSubscription?.cancel();
    super.onClose();
  }

  // Setup realtime listener for selected date queues
  void _setupRealtimeListener() {
    _isLoading.value = true;
    _queuesSubscription?.cancel();
    
    _queuesSubscription = getQueuesByDate(_selectedDate.value).listen(
      (queues) {
        _queues.value = queues;
        _isLoading.value = false;
      },
      onError: (error) {
        _isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat data antrean: $error',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // Change selected date
  void changeSelectedDate(DateTime date) {
    _selectedDate.value = date;
    _setupRealtimeListener();
  }

  // Change status filter
  void changeStatusFilter(String status) {
    _selectedStatus.value = status;
  }

  // Refresh data
  Future<void> refreshData() async {
    _setupRealtimeListener();
  }

  // Check if selected date is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.value.year, _selectedDate.value.month, _selectedDate.value.day);
    return today == selected;
  }

  // Get selected date formatted
  String getFormattedDate() {
    final date = _selectedDate.value;
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
