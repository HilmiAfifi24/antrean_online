import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_admin_controller.dart';

class PatientAdminPage extends StatelessWidget {
  const PatientAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pasien'),
      ),
      body: GetBuilder<PatientAdminController>(
        init: PatientAdminController(firestore: Get.find()),
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.patients.isEmpty) {
            return const Center(child: Text('Tidak ada data pasien'));
          }
          return ListView.builder(
            itemCount: controller.patients.length,
            itemBuilder: (context, index) {
              final pasien = controller.patients[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(pasien.email),
                  subtitle: Text('ID: ${pasien.id}'),
                  trailing: Text(pasien.role),
                ),
              );
            },
          );
        },
      ),
    );
  }
}