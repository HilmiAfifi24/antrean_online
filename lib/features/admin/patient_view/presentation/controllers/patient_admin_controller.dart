import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:antrean_online/features/auth/data/models/user_model.dart';

class PatientAdminController extends GetxController {
  final FirebaseFirestore firestore;
  PatientAdminController({required this.firestore});

  var patients = <UserModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      isLoading.value = true;
      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();
      patients.value = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data pasien: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
