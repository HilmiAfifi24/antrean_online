import '../entities/doctor_entity.dart';
import '../entities/queue_entity.dart';

abstract class DoctorRepository {
  Future<DoctorEntity> getDoctorProfile(String doctorId);
  Stream<List<QueueEntity>> getTodayQueues(String doctorId);
  Future<void> callNextPatient(String doctorId);
  Future<void> skipCurrentPatient(String doctorId);
  // Tambahkan method lain sesuai kebutuhan
}
