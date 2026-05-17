import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/doctor_controller.dart';

class DoctorSessionCancellationPage extends StatefulWidget {
  const DoctorSessionCancellationPage({super.key});

  @override
  State<DoctorSessionCancellationPage> createState() =>
      _DoctorSessionCancellationPageState();
}

class _DoctorSessionCancellationPageState
    extends State<DoctorSessionCancellationPage> {
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorController>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Batalkan Sesi'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Batalkan Sesi & Reschedule',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => Text(
                      DateFormat('EEEE, d MMMM y', 'id_ID')
                          .format(controller.selectedDate),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Semua antrean aktif pada sesi ini akan dibatalkan oleh dokter dan pasien akan diminta menjadwalkan ulang lewat aplikasi.',
                    style: TextStyle(color: Colors.grey[700], height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Alasan pembatalan',
                hintText: 'Contoh: dokter ada tindakan darurat',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Alasan pembatalan wajib diisi';
                }
                if (value.trim().length < 8) {
                  return 'Alasan terlalu singkat';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isLoading
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final confirmed = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Konfirmasi Pembatalan'),
                            content: const Text(
                              'Apakah Anda yakin ingin membatalkan sesi praktik ini?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Ya, Batalkan'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        final affected = await controller.cancelDoctorSession(
                          reasonController.text.trim(),
                        );
                        if (affected > 0) Get.back();
                      },
                icon: controller.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.event_busy_rounded),
                label: const Text('Batalkan Sesi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
