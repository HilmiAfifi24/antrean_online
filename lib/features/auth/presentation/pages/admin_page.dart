import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(child: Text("Halo Admin")),
    );
  }
}

class DokterDashboard extends StatelessWidget {
  const DokterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dokter Dashboard"),
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(child: Text("Halo Dokter")),
    );
  }
}

class PasienDashboard extends StatelessWidget {
  const PasienDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pasien Dashboard"),
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(child: Text("Halo Pasien")),
    );
  }
}
