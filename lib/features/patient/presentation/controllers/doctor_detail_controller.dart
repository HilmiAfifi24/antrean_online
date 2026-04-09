import 'package:get/get.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_doctor_schedules.dart';

class DoctorDetailController extends GetxController {
  final GetDoctorSchedules getDoctorSchedules;

  DoctorDetailController({required this.getDoctorSchedules});

  // Doctor passed via navigation arguments
  late final DoctorEntity doctor;

  // Schedules
  final RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is DoctorEntity) {
      doctor = args;
      _loadSchedules();
    }
  }

  Future<void> _loadSchedules() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await getDoctorSchedules(doctor.id);

      // Sort schedules: group by days, sorted alphabetically
      result.sort((a, b) {
        final aDays = (a['days_of_week'] as List<String>).join(', ');
        final bDays = (b['days_of_week'] as List<String>).join(', ');
        return aDays.compareTo(bDays);
      });

      schedules.value = result;
    } catch (e) {
      error.value = 'Gagal memuat jadwal dokter';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => _loadSchedules();

  /// Format time string "HH:mm" for display
  String formatTime(String time) {
    if (time.isEmpty) return '-';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}';
  }

  /// Get a friendly label for the days list
  String formatDays(List<String> days) {
    if (days.isEmpty) return '-';
    return days.join(', ');
  }
}
