import 'package:antrean_online/features/admin/doctor_view/data/datasources/doctor_admin_remote_datasource.dart';
import 'package:antrean_online/features/admin/doctor_view/data/repositories/doctor_admin_repository_impl.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/repositories/doctor_admin_repository.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/add_doctor.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/delete_doctor.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_all_doctors.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_doctor_by_id.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/get_spesializations.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/search_doctors.dart';
import 'package:antrean_online/features/admin/doctor_view/domain/usecases/update_doctor.dart';
import 'package:antrean_online/features/admin/doctor_view/presentation/controllers/doctor_admin_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    // Data Layer
    Get.put<DoctorAdminRemoteDatasource>(
      DoctorAdminRemoteDatasource(
        firestore: Get.find<FirebaseFirestore>(),
        auth: Get.find<FirebaseAuth>(),
      ),
      permanent: true,
    );

    // Repository Layer
    Get.put<DoctorAdminRepository>(
      DoctorAdminRepositoryImpl(Get.find<DoctorAdminRemoteDatasource>()),
      permanent: true,
    );

    // Use Cases Layer
    Get.put(GetAllDoctors(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(GetDoctorById(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(AddDoctor(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(UpdateDoctor(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(DeleteDoctor(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(SearchDoctors(Get.find<DoctorAdminRepository>()), permanent: true);
    Get.put(
      GetSpecializations(Get.find<DoctorAdminRepository>()),
      permanent: true,
    );

    // Controller Layer
    Get.put(
      DoctorAdminController(
        getAllDoctors: Get.find(),
        getDoctorById: Get.find(),
        addDoctor: Get.find(),
        updateDoctor: Get.find(),
        deleteDoctor: Get.find(),
        searchDoctors: Get.find(),
        getSpecializations: Get.find(),
      ),
      permanent: true,
    );
  }
}
